function [SOL,vm] = gosect(varargin)
% default options
opts.tau		= 1E-9;
opts.rtau		= 1E-4;
opts.MaxIter	= 50;

% contract arguments with default values (if not set)
S = module.struct(...
	'options', opts,...
	varargin{:} ...
);

% destructure
TOL			= eps;					% x tolerance
TAU			= S.options.tau;		% response tolerance
RTAU		= S.options.rtau;		% relative response tolerance
imax		= S.options.MaxIter;	% max iterations

Xint		= S.Xint;				% search interval
vm			= S.model;				% initial model struct

fResponse	= S.fResponse;			% solution			-> double
fSolution	= S.fSolution;			% model				-> solution
fModel		= S.fModel;				% solution			-> model
fUpdate		= S.fUpdate;			% (vector,model)	-> model

fLog		= S.fLog;				% solution -> print

% init
PHI			= (1 + sqrt(5))/2;		% golden ratio
bCalcLeft	= 1;
bCalcRight	= 1;
Y			= [];

% ASSUMPTION: in a narrow window fY has a parabolic shape
sLeft.model		= fUpdate(Xint(1),vm);
sRight.model	= fUpdate(Xint(2),vm);

for ii=1:imax
	% break criteria
	if diff(Xint) < TOL ...
		|| (numel(Y) > 1 && abs(1 - Y(end-1)/Y(end)) < RTAU)
		break
	end

	% check new interval border
	if bCalcLeft
		% set left border
		sLeft.x			= Xint(2) - diff(Xint)/PHI;
		
		% set model for left border
		sLeft.model		= fUpdate(sLeft.x,sLeft.model);
		
		% calculate solution
		% NOTE: the solution sRight.solution and sLeft.model may be not equivalent anymore
		sLeft.solution	= fSolution(sLeft.model);
		
		% therefore update model of left border
		sLeft.model		= fModel(sLeft.solution);
		
		% calculate function value
		sLeft.response	= fResponse(sLeft.solution);
		
		% cache response
		Y(end+1) = sLeft.response;
		
		% logging
		fLog(sLeft.solution);

		% check tolerance
		SOL = sLeft.solution;
		vm  = sLeft.model;
		
		if sLeft.response < TAU
			break;
		end
		
		% flag left border (calculated)
		bCalcLeft = 0;
	end
	
	if bCalcRight
		% set right border
		sRight.x		= Xint(1) + diff(Xint)/PHI;
		
		% set model for right border
		sRight.model	= fUpdate(sRight.x,sRight.model);
		
		% calculate solution
		% NOTE: the solution sRight.solution and sRight.model may be not equivalent anymore
		sRight.solution	= fSolution(sRight.model);
		
		% therefore update model of right border
		sRight.model	= fModel(sRight.solution);
		
		% calculate function value
		sRight.response	= fResponse(sRight.solution);
		
		% cache response
		Y(end+1) = sRight.response;
		
		% logging
		fLog(sRight.solution);

		% check tolerance
		SOL = sRight.solution;
		vm  = sRight.model;
		
		if sRight.response < TAU
			break;
		end
		
		% flag right border (calculated)
		bCalcRight = 0;
	end

	% shift interval borders
	if isnan(sLeft.response) && isnan(sRight.response)
		error('badly chosen interval. Interval edges give NaN.')
	elseif isnan(sLeft.response) || isnan(sRight.response)
		Xint = S.onNaN(Xint,sLeft,sRight);
		bCalcRight	= 1;
		bCalcLeft	= 1;
	elseif sLeft.response == sRight.response
		Xint = S.onEqual(Xint,sLeft,sRight);
		bCalcRight	= 1;
		bCalcLeft	= 1;
	elseif sLeft.response > sRight.response
		Xint(1) = sLeft.x;
		
		% right border becomes left border in next iteration
		sLeft = sRight;

		 % calculate only right border in next iteration
		bCalcRight = 1;
	else
		Xint(2) = sRight.x;
		
		% left border becomes right border in next iteration
		sRight = sLeft;

		% calculate only left border in next iteration
		bCalcLeft = 1;
	end
end