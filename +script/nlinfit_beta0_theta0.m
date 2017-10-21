function varargout = nlinfit_beta0_theta0(vm,list,varargin)
% set nlinfit options
opts = statset('nlinfit');

% set logging function
fLog = @(model,SOL,list) fprintf('<strong>%1.15e</strong>\t<strong>%1.15e</strong>\t%1.15e\t%1.3e\n',SOL.data.beta0,SOL.data.theta0,SOL.data.W0,list.chi2(SOL));

% set model wrapper (nlinfit vector => model)
fModel = @(b,SOL) struct(...
	'param', struct(...
		'm',		SOL.data.m,...
		'beta0',	b(1),...
		'theta0',	b(2),...
		'W0',		SOL.data.W0 ...
	),...
	'options',	vm.options ...
);

% set arguments
arg = lib.struct.merge(struct(...
	'model',			vm,...
	'fModel',			fModel,...
	'fSolution',		@(vm) model.tov.rar.quick(vm), ...
	'list',				list,...
	'debug',			fLog,...
	'opts',				opts ...
),struct(varargin{:}));

% find solution for given particle mass
[varargout{1:nargout}] = model.tov.rar.autofind.beta0_theta0(arg);