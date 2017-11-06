function T = createCoreHalo(T)
% load constraint list
list = lib.require(@configs.constraint_list);

% set initial model parameter
if T.length == 0
	vm = vmInit();
else
	vm = T.data{end}.model;
end

% select constraint lists, chi3 function and accuarcy
CONFIGS.list.main	= list.core_halo;
CONFIGS.list.core	= list.core;
CONFIGS.list.halo	= list.halo;
CONFIGS.fChi2		= @(SOL) list.core_halo.chi2(SOL);
CONFIGS.tau			= 1E-10;

% --- STEP 1: vary bata0 first ----
BETA0 = logspace(log10(2E-7),-2,200); % set beta0 grid
script.fixed_beta0.create(T,BETA0,vm,CONFIGS);

% % --- STEP 2: vary particle mass ----
mGrid = 292:-2:10; % set particle mass grid (in keV)
script.fixed_m.create(T,mGrid,vm,CONFIGS);

function vm = vmInit()
module.constraints

% initial parameter for mc² = 10 keV
opts	= struct('xmin', 1E-7, 'xmax', 1E20, 'tau', 1E-16, 'rtau', 1E-4);
param	= struct('m', 10*keVcc, 'beta0', 2.047057135387006e-07, 'theta0', 3.158325528289777e+01, 'W0', 5.857191547865187e+01);
vm		= struct('param', param, 'options', opts);