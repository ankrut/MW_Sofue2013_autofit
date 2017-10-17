function T = create_62_350(T)
% load physical constants
module.constraints

% load constraint list
list = lib.require(@configs.constraint_list);

% initial parameter for mc² = 10 keV
opts	= struct('xmin', 1E-5, 'xmax', 1E20, 'tau', 1E-16, 'rtau', 1E-4);
param	= struct('beta0', 2.047057135387006e-07, 'theta0', 3.158325528289777e+01,	'W0', 5.857191547865187e+01);

if T.length == 0
	vm = struct('param', param, 'options', opts);
else
	vm = T.data{end}.model;
end

% define particle mass grid (in keV)
m = 62:2:350;

for ii=T.length+1:numel(m)
	% log
	fprintf('\n--- [%d/%d : %1.15f] -------------------------\n',ii,numel(m),m(ii));
	
	% set particle mass
	vm.param.m = m(ii)*1E3*eVcc;
	
% 	% interpolate model (approximation)
% 	vm = interpolate_model(vm,m(ii));

	SOL = script.autofind(vm,list);
	chi2 = list.chi2(SOL);
	
	if chi2 > 1E-6
		try
			SOL = script.autofind_2step(SOL.model,list.core_halo,list.core,list.halo.data{1});
			chi2 = list.chi2(SOL);
		end
	end

	% set parameter for next iteration
	% (next solution should be close to the found one if dm is small enough)
	vm = SOL.model;

	% push to list (compressed information)
	T.push(struct(...
		'model',	vm,...
		'chi2',		chi2 ...
	));
end

% EXPERIMENTAL
function vm = interpolate_model(vm,m)
% auxillary log(m)-log(beta0) relation (linear)
p1 = [2.602148537809196 -21.558978418043530];

% auxillary log(m)-log(theta0) relation (linear for m>30)
p2 = [0.054098356123053   3.397235427039469];

% auxillary log(m)-log(W0) relation (linear for m>30)
p3 = [1.652715645789050   3.880932875872007];
	
% set beta0(m)
vm.param.beta0 = exp(polyval(p1,log(m)));