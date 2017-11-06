% find solution (beta0,theta0) for given W0 and particle mass m
function varargout = beta0_theta0(vm,list,varargin)
module.constraints

% set iteration print function
sPrec	= '%1.12e';
sStrong = ['<strong>' sPrec '</strong>'];
sFormat = strjoin({sPrec,sStrong,sStrong,sPrec,'%1.3e\n'},'\t');
fLog	= @(SOL) fprintf(sFormat,SOL.data.m/keVcc,SOL.data.beta0,SOL.data.theta0,SOL.data.W0,list.chi2(SOL));

% set vector function 
fVector = @(vm) [
	log(vm.param.beta0)
	vm.param.theta0
];

% set update function
fUpdate = @(b,vm) struct(...
	'param', struct(...
		'm',		vm.param.m,...
		'beta0',	exp(b(1)),...
		'theta0',	b(2),...
		'W0',		vm.param.W0 ...
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

[varargout{1:nargout}] = model.tov.rar.nlinfit.beta0_theta0(vm,list,...
	'fVector',			fVector,...
	'fUpdate',			fUpdate,...
	'fModel',			fModel,...
	'fLog',				fLog,...
	varargin{:} ...
);