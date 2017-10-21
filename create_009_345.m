function T = create_009_345(T)
% load physical constants
module.constraints

% load constraint list
list = lib.require(@configs.constraint_list);

% preallocate
chi2(1:2) = nan;

% set initial model parameter
if T.length == 0
	vm(1:2) = vmInit();
else
	vm(1:2) = T.data{end}.model;
end

% set nlinfit options (for autofind)
opts = statset('nlinfit');
opts.MaxIter = 50;

% define particle mass grid (in keV)
m = 9:1:345;

for ii=T.length+1:numel(m)
	% reset chi2
	chi2(:) = nan;
	
	% log
	fprintf('\n--- [%d/%d : %1.15f] -------------------------\n',ii,numel(m),m(ii));
	
	% set particle mass
	vm(1).param.m = m(ii)*keVcc;
	vm(2).param.m = m(ii)*keVcc;
	
	% find solution and set model parameter for next iteration
	% (next solution should be close to the found one if dm is small enough)
	try
		fprintf('%21s\t%21s\t%21s\t%9s\n','beta0','theta0','W0','chi2');

		[SOL(1), vm(1)] = script.nlinfit(...
			estimate_model(vm(1),T),...
			list.core_halo,...
			struct(...
				'opts', opts ...
			)...
		);
	
		chi2(1) = list.core_halo.chi2(SOL(1));
	catch
		fprintf(' --- autofind FAILED ---\n');
		chi2(1) = Inf;
	end
	
	if chi2(1) > 1E-3
		try
			fprintf('%21s\t%21s\t%21s\t%9s\n','beta0','theta0','W0','chi2');

			vm(1) = estimate_model(vm(1),T);
			[SOL(1), vm(1)] = script.nlinfit_core(vm(1),list.core);
			[SOL(1), vm(1)] = script.bisect_W0(vm(1),list.halo.data{1});
			[SOL(1), vm(1)] = script.nlinfit(...
				vm(1),...
				list.core_halo,...
				struct(...
					'opts', opts ...
				)...
			);

			chi2(1) = list.core_halo.chi2(SOL(1));
		catch
			fprintf(' --- autofind core-halo FAILED ---\n');
			chi2(1) = Inf;
		end
	end
	
	if chi2(1) > 1E-3
		% try 2step bisection method (slower but more robust)
		try
			[SOL(2), vm(2)] = script.gosect_2step(...
				estimate_model(vm(2),T,2),...
				list.core_halo,...
				list.core,...
				list.halo.data{1}...
			);
		
			chi2(2) = list.core_halo.chi2(SOL(2));
		catch
			fprintf(' --- 2step method FAILED ---\n');
			chi2(2) = Inf;
		end
	end
	
% 	if chi2(1) > 1E-3
% 		% try another method (faster but less robust)
% 		try
% 			[SOL(2), vm(2)] = script.nlinfit_2step(...
% 				estimate_model(vm(2),T),...
% 				list.core_halo,...
% 				list.core,...
% 				list.halo.data{1}...
% 			);
% 		
% 			chi2(2) = list.core_halo.chi2(SOL(2));
% 		catch
% 			fprintf(' --- 2step method FAILED ---\n');
% 			chi2(2) = Inf;
% 		end
% 	end

	% push best solution to list (compressed information)
	kk = lib.iff(chi2(1) < chi2(2),1,2);
	
	T.push(struct(...
		'model',	vm(kk),...
		'chi2',		chi2(kk) ...
	));
end

function vm = vmInit()
% initial parameter for mc² = 10 keV
opts	= struct('xmin', 1E-5, 'xmax', 1E20, 'tau', 1E-16, 'rtau', 1E-4);
param	= struct('beta0', 2.047057135387006e-07, 'theta0', 3.158325528289777e+01,	'W0', 5.857191547865187e+01);
vm		= struct('param', param, 'options', opts);

% EXPERIMENTAL
function vm = estimate_model(vm,T,kk)
nn = T.length;
n0 = min(nn,kk);

if n0 > 1
	vm = extrapolate_model(vm,T.pick(nn-n0:nn-1));
end


function vm = extrapolate_model(vm,T)
M		= T.accumulate(@(t) t.model.param.m);
BETA0	= T.accumulate(@(t) t.model.param.beta0);
THETA0	= T.accumulate(@(t) t.model.param.theta0);
W0		= T.accumulate(@(t) t.model.param.W0);

p1 = polyfit(log(M),log(BETA0),1);
p2 = polyfit(log(M),log(THETA0),1);
p3 = polyfit(log(M),log(W0),1);

vm.param.beta0	= exp(polyval(p1,log(vm.param.m)));
% vm.param.theta0	= exp(polyval(p2,log(vm.param.m)));
% vm.param.W0		= exp(polyval(p3,log(vm.param.m)));