function varargout = nlinfitCoreHalo(vm,CONFIGS,varargin)
% destructure
LIST		= CONFIGS.list;

% set solution function
fSolution = @(vm) script.findCoreHalo(vm,CONFIGS);

% set nlinfit options
opts				= statset('nlinfit');
opts.FunValCheck	= 'off';
opts.MaxIter		= 20;

% searcg for solution
[varargout{1:nargout}] = model.tov.rar.nlinfit.m(vm,LIST.main,...
	'fSolution',	fSolution,...
	'options',		opts,...
	varargin{:} ...
);