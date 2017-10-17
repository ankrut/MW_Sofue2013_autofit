function [SOL,varargout] = theta0(S)

% set inital vector X0 (model => nlinfit vector)
fVector = @(SOL) [
	SOL.data.theta0
];



% set model wrapper (nlinfit vector => model)
fModel = @(b,SOL) struct(...
	'param', struct(...
		'beta0',	SOL.data.beta0,...
		'theta0',	b(1),...
		'W0',		SOL.data.theta0 ...
	),...
	'options',	S.model.options ...
);

SOL = lib.fitting.bisect(lib.struct.merge(struct(...
	'fVector',		fVector,...
	'fModel',		fModel ...
),S));

varargout{1} = fModel(fVector(SOL),SOL);