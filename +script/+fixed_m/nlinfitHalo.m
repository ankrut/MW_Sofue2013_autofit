function varargout = nlinfitHalo(vm,CONFIGS,varargin)
% destructure
LIST = CONFIGS.list.main;

% set halo solution function
fHaloSolution = @(vm) find_halo(vm,CONFIGS);

% set nlinfit options
opts				= statset('nlinfit');
opts.FunValCheck	= 'off';
opts.MaxIter		= 50;
opts.TolX			= 1E-12;

[varargout{1:nargout}] = script.nlinfit.beta0_theta0(vm,LIST,...
	'fSolution',	fHaloSolution,...
	'options',		opts,...
	varargin{:} ...
);

% wrapper
function varargout = find_halo(varargin)
fprintf('\n'); % new line
[varargout{1:nargout}] = script.findHalo(varargin{:});