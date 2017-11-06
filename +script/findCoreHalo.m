function varargout = findCoreHalo(vm,CONFIGS)
% destructure
LIST	= CONFIGS.list;
fChi2	= CONFIGS.fChi2;
TAU		= CONFIGS.tau;

% set core solution function priority list
fCoreSolution = {
	@(vm) script.nlinfit.theta0(vm,LIST.core)
	@(vm) script.gosect.theta0(vm,LIST.core)
	@(vm) script.bisect.theta0(vm,LIST.core.data{1})
};

% find core (theta0)
fprintf('\n === 1/2 === find core\n')
[~,vm] = script.findSolution(vm,fCoreSolution,fChi2,TAU);


% set core solution function priority list
opts.rtau		= 1E-4;
opts.tau		= 1E-12;
opts.MaxIter	= 50;

fHaloSolution = {
	@(vm) script.nlinfit.W0(vm,LIST.halo)
	@(vm) script.gosect.W0(vm,LIST.halo,'options',opts)
	@(vm) script.bisect.W0(vm,LIST.halo.data{1})
};

% then find halo (W0) for given beta0 and theta0
fprintf(' === 2/2 === find halo\n')
[varargout{1:nargout}] = script.findSolution(vm,fHaloSolution,fChi2,TAU);