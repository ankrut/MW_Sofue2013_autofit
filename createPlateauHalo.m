function T = createPlateauHalo(T)
% load constraint list
list = lib.require(@configs.constraint_list);

% set initial model parameter
if T.length == 0
	vm = vmInit();
else
	vm = T.data{end}.model;
end

% select constraint lists, chi3 function and accuarcy
CONFIGS.list.main	= list.data;
CONFIGS.list.core	= list.data.pick(1);
CONFIGS.list.halo	= list.data.pick([3,2]);
CONFIGS.fChi2		= @(SOL) list.data.chi2(SOL);
CONFIGS.tau			= 1E-10;

% --- STEP 1: vary bata0 first ----
BETA0 = logspace(-7,-2,200); % set beta0 grid
script.fixed_beta0.create(T,BETA0,vm,CONFIGS);

% --- STEP 2: vary particle mass ----
mGrid = 365:-2:120; % set particle mass grid (in keV)
script.fixed_m.create(T,mGrid,vm,CONFIGS);

function vm = vmInit()
module.constraints

% initial parameter for mc² = 10 keV
opts	= struct('xmin', 1E-5, 'xmax', 1E20, 'tau', 1E-16, 'rtau', 1E-4);
param	= struct('m', 10*keVcc, 'beta0', 2.047057135387006e-07, 'theta0', 3.158325528289777e+01, 'W0', 5.857191547865187e+01);
vm		= struct('param', param, 'options', opts);