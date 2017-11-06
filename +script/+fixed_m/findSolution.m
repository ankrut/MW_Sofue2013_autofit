function varargout = findSolution(vm,CONFIGS)
% destructure
LIST	= CONFIGS.list; % requires subfields "main", "core" and "halo"
fChi2	= CONFIGS.fChi2;
TAU		= CONFIGS.tau;

% set nlinfit options (for autofind)
opts				= statset('nlinfit');
opts.FunValCheck	= 'off';
opts.MaxIter		= 50;
opts.TolX			= 1E-12;

fSolution = {
	@(vm) script.nlinfit.beta0_theta0_W0(vm,LIST.main,'options', opts)
	@(vm) script.fixed_m.nlinfitHalo(vm,CONFIGS)
% 	@(vm) script.fixed_m.nlinfitCoreHalo(vm,CONFIGS)
};

[varargout{1:nargout}] = script.findSolution(vm,fSolution,fChi2,TAU);