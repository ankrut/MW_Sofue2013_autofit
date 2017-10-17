function SOL = beta0(S)

% set inital vector X0 (model => nlinfit vector)
fVector = @(SOL) [
	SOL.data.beta0
];



% set model wrapper (nlinfit vector => model)
fModel = @(b,SOL) struct(...
	'param', struct(...
		'beta0',	b(1),...
		'theta0',	SOL.data.beta0,...
		'W0',		SOL.data.W0 ...
	),...
	'options',	S.model.options ...
);

SOL = lib.fitting.nlinfit(lib.struct.merge(struct(...
	'fVector',		fVector,...
	'fModel',		fModel ...
),S));