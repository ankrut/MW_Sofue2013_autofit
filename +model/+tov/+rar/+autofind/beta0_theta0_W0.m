function [SOL,varargout] = beta0_theta0_W0(S)

% set iteration print function
sPrec	= '%1.15e';
sStrong = ['<strong>' sPrec '</strong>'];
sFormat = strjoin({sStrong,sStrong,sStrong,'%1.3e\n'},'\t');
fLog	= @(model,SOL,list) fprintf(sFormat,SOL.data.beta0,SOL.data.theta0,SOL.data.W0,list.chi2(SOL));

% set vector wrapper (model => nlinfit vector)
fVector = @(SOL) [
	SOL.data.beta0
	SOL.data.theta0
	SOL.data.W0
];

% set model wrapper (nlinfit vector => model)
fModel = @(b,SOL) struct(...
	'param', struct(...
		'beta0',	b(1),...
		'theta0',	b(2),...
		'W0',		b(3) ...
	),...
	'options',	S.model.options ...
);

% set argument struct
S = lib.struct.merge(struct(...
	'fVector',		fVector,...
	'fModel',		fModel,...
	'fSolution',	@(vm) model.tov.rar.quick(vm),...
	'debug',		fLog ...
),S);

SOL				= lib.fitting.nlinfit(S);
varargout{1}	= S.fModel(S.fVector(SOL),SOL);