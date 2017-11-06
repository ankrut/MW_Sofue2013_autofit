function varargout = findHalo(vm,CONFIGS,varargin)
% destructure
LIST	= CONFIGS.list.halo;
fChi2	= CONFIGS.fChi2;
TAU		= CONFIGS.tau;

% set halo solution function priority list
fHaloSolution = {
	@(vm) autofind(vm,LIST)
% 	@(vm) gosect(vm,LIST,16)
	@(vm) gosect(vm,LIST,1)
% 	@(vm) gosect(vm,LIST,0.1)
% 	@(vm) bisect(vm,LIST.data{1},16)
};

% search for solution
[varargout{1:nargout}] = script.findSolution(vm,fHaloSolution,fChi2,TAU,varargin{:});



function varargout = autofind(varargin)
fprintf(' --- try autofind halo ---\n');

opts				= statset('nlinfit');
opts.FunValCheck	= 'off';
opts.MaxIter		= 50;
opts.TolX			= 1E-12;

[varargout{1:nargout}] = script.nlinfit.W0(varargin{:},'options',opts);

function varargout = gosect(vm,LIST,DW0)
fprintf(' --- try golden section search. ---\n');

opts.rtau		= 1E-4;
opts.tau		= 1E-12;
opts.MaxIter	= 60;

[varargout{1:nargout}] = script.gosect.W0(vm,LIST,...
	'Xint',vm.param.W0 + [-1,1]*DW0,...
	'options',opts ...
);

function varargout = bisect(vm,response_halo,DW0)
fprintf(' --- try bisection search. ---\n');

[varargout{1:nargout}] = script.bisect.W0(vm,response_halo,'Xint',vm.param.W0 + [-1,1]*DW0);