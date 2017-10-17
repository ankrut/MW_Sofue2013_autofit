function [SOL, vm] = autofind_halo(vm,list,varargin)
% set nlinfit options
opts = statset('nlinfit');
% opts.Display = 'iter';
% opts.MaxIter = 15;

% set logging function
fLog = @(model,SOL,list) fprintf('%1.15e\t%1.15e\t<strong>%1.15e</strong>\t%1.3e\n',SOL.data.beta0,SOL.data.theta0,SOL.data.W0,list.chi2(SOL));

% set model wrapper (nlinfit vector => model)
fModel = @(b,SOL) struct(...
	'param', struct(...
		'm',		vm.param.m,...
		'beta0',	vm.param.beta0,...
		'theta0',	vm.param.theta0,...
		'W0',		b(1) ...
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
fprintf('%21s\t%21s\t%21s\t%9s\n','beta0','theta0','W0','chi2')
SOL = model.tov.rar.autofind.W0(arg);

% update model
vm.param.W0		= SOL.data.W0;