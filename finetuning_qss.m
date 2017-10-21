function finetuning_qss(T)
module.constraints

% load constraint list
list = lib.require(@configs.constraint_list);

for ii=1:T.length
	vm = T.data{ii}.model;
	
	fprintf('\n--- [%d/%d : %1.15f] -------------------------\n',ii,T.length,vm.param.m/keVcc);
	
	if T.data{ii}.chi2 < 1E-5
		continue
	end
	
	% try 2step bisection method (slower but more robust)
	try
		[SOL, vm] = script.gosect_2step(...
			vm,...
			list.core_halo,...
			list.core,...
			list.halo.data{1}...
		);

		chi2 = list.core_halo.chi2(SOL);
		
		T.data{ii} = struct(...
			'model',	vm,...
			'chi2',		chi2 ...
		);
	catch
		fprintf(' --- 2step method FAILED ---\n');
	end
end