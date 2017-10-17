function SOL = beta0_theta0_W0(S)

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

SOL = lib.fitting.nlinfit(lib.struct.merge(struct(...
	'fVector',		fVector,...
	'fModel',		fModel ...
),S));