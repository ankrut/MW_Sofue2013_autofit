% find beta0 with dynamical theta0 and W0
function varargout = gosectCoreHalo(vm,CONFIGS,varargin)
% destructure
LIST = CONFIGS.list.main; % requires subfields "main", "core" and "halo"

% set solution function
fSolution = @(vm) script.findCoreHalo(vm,CONFIGS);

% set search interval
Xint(1) = vm.param.beta0*(1 - 2E-1);
Xint(2) = vm.param.beta0*(1 + 2E-1);

[varargout{1:nargout}] = script.gosect.beta0(vm,LIST,...
	'Xint',			log(Xint),...
	'fSolution',	fSolution,...
	varargin{:} ...
);