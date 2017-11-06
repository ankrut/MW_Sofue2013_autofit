% find beta0 with dynamical theta0 and W0
function varargout = nlinfitCoreHalo(vm,CONFIGS,varargin)
% destructure
LIST = CONFIGS.list.main;

% set solution function
fSolution = @(vm) script.findCoreHalo(vm,CONFIGS);

% set nlinfit options
opts				= statset('nlinfit');
opts.FunValCheck	= 'off';
opts.MaxIter		= 20;

% searcg for solution
[varargout{1:nargout}] = script.nlinfit.beta0(vm,LIST,...
	'fSolution',	fSolution,...
	'options',		opts,...
	varargin{:} ...
);