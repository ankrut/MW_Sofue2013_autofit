% default values are given for
%	fModel, fSolution, fLog, onNaN, options
%
% required parameter
%	model struct <vm>
%	response <list>
%	search interval <Xint>
%	chi2 function <fY>
%	update function <fUpdate>

function varargout = gosect(vm,list,varargin)
% set iteration print function
sPrec	= '%1.15e';
sFormat = strjoin({sPrec,sPrec,sPrec,'%1.3e\n'},'\t');
fLog	= @(SOL) fprintf(sFormat,SOL.data.beta0,SOL.data.theta0,SOL.data.W0,list.chi2(SOL));

% set model function (solution => struct)
fModel = @(SOL) struct(...
	'param', struct(...
		'beta0',	SOL.data.beta0,...
		'theta0',	SOL.data.theta0,...
		'W0',		SOL.data.W0 ...
	),...
	'options', vm.options ...
);

% set solution function (struct => solution)
fSolution = @(vm) model.tov.rar.quick(vm);

% search for solution
[varargout{1:nargout}] = lib.fitting.gosect(...
	'model',		vm,...
	'fModel',		fModel,...
	'fSolution',	fSolution,...
	'fLog',			fLog,...
	'onNaN',		@onNaN,...
	'onEqual',		@onEqual,...
	varargin{:} ...
);

function Xint = onNaN(Xint,sLeft,sRight)
if isnan(sLeft.response) && isnan(sRight.response)
	Xint = [sRight.x, Xint(2)];
elseif isnan(sLeft.response)
	Xint = [sLeft.x, Xint(2)];
else % sRight.response has to be a NaN
	Xint = [Xint(1), sRight.x];
end

function Xint = onEqual(Xint,sLeft,sRight)
Xint = [sRight.x, Xint(2)];
