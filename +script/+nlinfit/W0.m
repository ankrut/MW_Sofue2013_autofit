% find solution (W0) for given theta0, beta0 and particle mass m
function varargout = W0(vm,list,varargin)
module.constraints

% set iteration print function
sPrec	= '%1.12e';
sStrong = ['<strong>' sPrec '</strong>'];
sFormat = strjoin({sPrec,sPrec,sPrec,sStrong,'%1.3e\n'},'\t');
fLog	= @(SOL) fprintf(sFormat,SOL.data.m/keVcc,SOL.data.beta0,SOL.data.theta0,SOL.data.W0,list.chi2(SOL));

% set update function
fUpdate = @(b,vm) struct(...
	'param', struct(...
		'm',		vm.param.m,...
		'beta0',	vm.param.beta0,...
		'theta0',	vm.param.theta0,...
		'W0',		b(1) ...
	),...
	'options',	vm.options ...
);

% set model function
fModel = @(SOL) struct(...
	'param', struct(...
		'm',		SOL.data.m,...
		'beta0',	SOL.data.beta0,...
		'theta0',	SOL.data.theta0,...
		'W0',		SOL.data.W0 ...
	),...
	'options',	vm.options ...
);

[varargout{1:nargout}] = model.tov.rar.nlinfit.W0(vm,list,...
	'fUpdate',			fUpdate,...
	'fModel',			fModel,...
	'fLog',				fLog,...
	varargin{:} ...
);