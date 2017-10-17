function SOL = bisect(S)
% destructure
fY			= S.fY;
Xint		= S.Xint;
imax		= S.options.iteration_number;
tau			= S.options.tau;

% init values
SOL			= S.fSolution(S.model);

% init logging
if isfield(S,'log')
	S.log.fInit(SOL);
end

% left bound
vm			= S.fModel(Xint(1),SOL);
SOL			= S.fSolution(vm);
dY(1)		= fY(SOL);

if isfield(S,'log')
	S.log.fIter(SOL);
end

% right bound
vm			= S.fModel(Xint(2),SOL);
SOL			= S.fSolution(vm);
dY(3)		= fY(SOL);

if isfield(S,'log')
	S.log.fIter(SOL);
end

for ii=1:imax
	% next bisection point
	X = mean(Xint);
		
	% create model struct with given new X and solution SOL
	vm = S.fModel(X,SOL);

	% calculate new solution
	SOL = S.fSolution(vm);
	
	% get relative distance
	dY(2) = fY(SOL);
	
	% iteration logging
	if isfield(S,'log')
		S.log.fIter(SOL);
	end

	% get new X (if necessary)
	if sum(isnan(dY)) > 0 % if any is NaN consider specific case
		[Xint,dY] = S.onNaN(Xint,dY);
	elseif abs(dY(2)) > tau % when below accuracy
		if sign(dY(1)) == sign(dY(2)) % if same sign as left bound
			% shift left bound
			Xint(1) = X;
			dY(1)	= dY(2);
		else
			% else shift right bound
			Xint(2) = X;
			dY(3)	= dY(2);
		end
	else % when above accuracy exit iteration
		break
	end
end