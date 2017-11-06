function p = beta0_theta0_omega(S)
% destructure
model		= S.model;
fSolution	= S.solution;

% set vector wrapper (model => nlinfit vector)
fVector = @(model) [
	model.param.logbeta0
	model.param.theta0
	model.param.omega
];

% set model wrapper (nlinfit vector => model)
fParam = @(b)  struct(...
	'beta0',	10^b(1),...
	'theta0',	b(2),...
	'W0',		1.73*b(2) + 1.07 + 10^b(3) ...
);

fModel = @(b) struct(...
	'param',	fParam(b),...
	'options',	model.options ...
);

% set options
opts = statset('nlinfit');

fprintf('chi2    \tbeta0                 \ttheta0               \tomega            \n');
p = lib.nlinfit(struct(...
	'beta0',		fVector(model),...
	'fModel',		fModel,...
	'fSolution',	fSolution,...
	'debug',		@(model,list) fprintf('%1.3e\t%1.15e\t%1.15e\t%1.15e\n',list.chi2,model.param.beta0,model.param.theta0,model.param.W0),...
	'list',			S.list,...
	'opts',			opts ...
));