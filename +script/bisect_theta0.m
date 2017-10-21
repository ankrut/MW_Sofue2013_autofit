function varargout = bisect_theta0(vm,response,varargin)
% relative distance function
fY = @(SOL) 1 - response.map(SOL)/response.prediction;

% set logging function
sLog = struct(...
	'fInit', @(SOL) fprintf('%21s\t%21s\t%21s\t%9s\n','beta0','theta0','W0','chi2'),...
	'fIter', @(SOL) fprintf('%1.15e\t<strong>%1.15e</strong>\t%1.15e\t%1.3e\n',SOL.data.beta0,SOL.data.theta0,SOL.data.W0,response.chi2(SOL)) ...
);

% set bisect configs
opts = struct(...
	'tau',				1E-6,...
	'iteration_number', 40 ...
);

% set model wrapper
fModel = @(b,SOL) struct(...
	'param', struct(...
		'm',		SOL.data.m,...
		'beta0',	SOL.data.beta0,...
		'theta0',	b(1),...
		'W0',		SOL.data.W0 ...
	),...
	'options',	vm.options ...
);

% set arguments
arg = lib.struct.merge(struct(...
	'fY',			fY,...
	'Xint',			vm.param.theta0 + [-10,10],...
	'model',		vm,...
	'fModel',		fModel,...
	'fSolution',	@(vm) model.tov.rar.quick(vm),...
	'onNaN',		@onNaN,...
	'options',		opts,...
	'log',			sLog ...
),struct(varargin{:}));

% find solution for given particle mass
[varargout{1:nargout}] = model.tov.rar.bisect.theta0(arg);

function [Xint,dY] = onNaN(Xint,dY)
if isnan(dY(1)) && isnan(dY(3))
	error('badly chosen interval. Interval edges give NaN.')
elseif isnan(dY(1))
	if sign(dY(2)) == sign(dY(3)) && abs(dY(2)) < abs(dY(3))
		Xint = [Xint(1), mean(Xint)];
		dY(3) = dY(2);
	else
		Xint = [mean(Xint), Xint(2)];
		dY(1) = dY(2);
	end
end

