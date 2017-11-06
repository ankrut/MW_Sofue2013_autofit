function varargout = findSolution(vm,CONFIGS)
module.constraints

% destructure
LIST	= CONFIGS.list; % requires subfields "main", "core" and "halo"
fChi2	= CONFIGS.fChi2;
TAU		= CONFIGS.tau;

% set nlinfit options (for autofind)
opts				= statset('nlinfit');
opts.FunValCheck	= 'off';
opts.MaxIter		= 50;
opts.TolX			= 1E-12;

% set iteration print function
sPrec	= '%1.12e';
sStrong = ['<strong>' sPrec '</strong>'];
sFormat = strjoin({sStrong,sPrec,sStrong,sStrong,'%1.3e\n'},'\t');
fLog1	= @(SOL) fprintf(sFormat,SOL.data.m/keVcc,SOL.data.beta0,SOL.data.theta0,SOL.data.W0,fChi2(SOL));

sFormat = strjoin({sStrong,sPrec,sStrong,sPrec,'%1.3e\n'},'\t');
fLog2	= @(SOL) fprintf(sFormat,SOL.data.m/keVcc,SOL.data.beta0,SOL.data.theta0,SOL.data.W0,fChi2(SOL));

% set halo solution function
fHaloSolution = @(vm) script.findHalo(vm,CONFIGS);

% set solution functions
fSolution		 = {};
fSolution{end+1} = @(vm) model.tov.rar.nlinfit.m_theta0_W0(vm,LIST.main,...
	'fLog',			fLog1,...
	'options',		opts ...
);

fSolution{end+1} = @(vm) model.tov.rar.nlinfit.m_theta0(vm,LIST.main,...
	'fSolution',	fHaloSolution,...
	'fLog',			fLog2,...
	'options',		opts ...
);

% fSolution{end+1} = @(vm) script.fixed_beta0.nlinfitCoreHalo(vm,CONFIGS,...
% 	'options',		opts ...
% );


% search for solution with chi2 accuracy of TAU
[varargout{1:nargout}] = script.findSolution(vm,fSolution,fChi2,TAU);