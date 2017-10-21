function [SOL,vm] = gosect(vm1,vm2,S)
% destructure
TOL			= S.options.tol;		% tolerance
imax		= S.options.MaxIter;	% max iterations

fY			= S.fY;
fSolution	= S.fSolution;			% model				-> solution
fModel		= S.fModel;				% solution			-> model
fVector		= S.fVector;			% model				-> vector
fUpdate		= S.fUpdate;			% (vector,model)	-> model

fLog		= S.fLog;

% init
PHI			= (1 + sqrt(5))/2;		% golden ratio
bCalcLeft	= 1;
bCalcRight	= 1;
ii			= 0;

% ASSUMPTION: in a narrow window fY has a parabolic shape
ab(1) = fVector(vm1);
ab(2) = fVector(vm2);

while diff(ab) > eps || ii < imax
	ii = ii + 1;

	% check new interval border
	if bCalcLeft
		% set model for left border
		vm1		= fUpdate(ab(2) - diff(ab)/PHI,vm1);
		
		% calculate solution
		% NOTE: the solution SOL1 and vm1 may be not equivalent anymore
		SOL1	= fSolution(vm1);
		
		% therefore update model of left border
		vm1		= fModel(SOL1);
		
		% calculate function value
		Y(1)	= fY(SOL1);
		
		% logging
		fLog(SOL1);

		% check tolerance
		SOL = SOL1;
		vm  = vm1;
		if Y(1) < TOL
			break;
		end
		
		% flag left border (calculated)
		bCalcLeft = 0;
	end
	
	if bCalcRight
		% set model for right border
		vm2		= fUpdate(ab(1) + diff(ab)/PHI,vm2);
		
		% calculate solution
		% NOTE: the solution SOL2 and vm2 may be not equivalent anymore
		SOL2	= fSolution(vm2);
		
		% therefore update model of right border
		vm2		= fModel(SOL2);
		
		% calculate function value
		Y(2)	= fY(SOL2);
		
		% logging
		fLog(SOL2);

		% check tolerance
		SOL = SOL2;
		vm  = vm2;
		if Y(2) < TOL
			break;
		end
		
		% flag right border (calculated)
		bCalcRight = 0;
	end

	% shift interval borders
	if Y(1) > Y(2)
		ab(1) = fVector(vm1);
		
		% right border becomes left border in next iteration
		Y(1) = Y(2);
		vm1 = vm2;

		 % calculate only right border in next iteration
		bCalcRight = 1;
	else
		ab(2) = fVector(vm2);
		
		% left border becomes right border in next iteration
		Y(2) = Y(1);
		vm2 = vm1;

		% calculate only left border in next iteration
		bCalcLeft = 1;
	end
end