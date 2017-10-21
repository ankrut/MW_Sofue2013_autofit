function varargout = nlinfit_2step(vm,list,list_core,response_halo,varargin)
% find beta0 with dynamical theta0 and W0
try
	[varargout{1:nargout}] = autofind(vm,list,list_core,response_halo,varargin{:});
catch
	fprintf('\n --- 2step autofind FAILED. try 2step bisection ---\n');
	[varargout{1:nargout}] = bisect(vm,list_core,response_halo);
end


function varargout = autofind(vm,list,list_core,response_halo,varargin)
% set nlinfit options
opts = statset('nlinfit');
opts.MaxIter = 10;

% set logging function
fLog = @(model,SOL,list) fprintf('<strong>%1.15e</strong>\t%1.15e\t%1.15e\t%1.3e\n',SOL.data.beta0,SOL.data.theta0,SOL.data.W0,list.chi2(SOL));

% set model wrapper (nlinfit vector => model)
fModel = @(b,SOL) struct(...
	'param', struct(...
		'm',		SOL.data.m,...
		'beta0',	b(1),...
		'theta0',	SOL.data.theta0,...
		'W0',		SOL.data.W0 ...
	),...
	'options',	vm.options ...
);

% set arguments
arg = lib.struct.merge(struct(...
	'model',			vm,...
	'fModel',			fModel,...
	'fSolution',		@(vm) find_core(vm,list_core,response_halo), ...
	'list',				list,...
	'debug',			fLog,...
	'opts',				opts ...
),struct(varargin{:}));

% find solution (beta0,theta0,W0) for given particle mass
[varargout{1:nargout}] = model.tov.rar.autofind.beta0(arg);

function varargout = bisect(vm,list_core,response_halo)
[varargout{1:nargout}] = script.bisect_beta0(...
	vm,...
	response_halo,...
	'fSolution', @(vm) find_core(vm,list_core,response_halo)...
);


function SOL = find_core(vm,list_core,response_halo)
% find core (theta0) for given beta0 and W0
fprintf(' === 1/2 === find core\n')
[~, vm] = script.nlinfit_core(vm,list_core);

% then find halo (W0) for given beta0 and theta0
fprintf(' === 2/2 === find halo\n')
SOL = script.bisect_W0(vm,response_halo);