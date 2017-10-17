function finetuning(TBL,list,list_core,response_halo)
module.constraints

TAU = 1E-6;

for ii=1:TBL.length
	vm	= TBL.data{ii}.model;
	
	% log
	fprintf('\n--- [%d/%d : %1.15f] -------------------------\n',ii,TBL.length,vm.param.m/1E3/eVcc);
	
	% skip if accuracy is good enough
	if ~isnan(TBL.data{ii}.chi2) && TBL.data{ii}.chi2 < TAU
		continue
	end

	% try normal autofind method
	fprintf(' === autofind (normal) ===\n');
	[SOL, vm] = script.autofind(vm,list);
	chi2 = list.chi2(SOL);
	
	% try mean values of two neighbors
	fprintf(' === autofind (mean neighbors) ===\n');
	if chi2 > TAU && ii > 1 && ii < TBL.length
		[SOL, vm] = calcMean(vm,TBL.data{ii-1}.model,TBL.data{ii+1}.model,list);
		chi2 = list.chi2(SOL);
	end
	
	% try to shake a bit initial parameter
	if chi2 > TAU && ii > 1 && ii < TBL.length
		for jj=1:5
			fprintf(' === autofind (shake %d/%d) ===\n',jj,5);
			try
				[SOL, vm] = calcShake(vm,5E-3,list);
				chi2 = list.chi2(SOL);
			catch
				continue
			end
			
			if ~isnan(chi2) && chi2 < TAU
				break
			end
		end
	end
	
	% try 2step method
	fprintf(' === autofind (2step) ===\n');
	if isnan(chi2) || chi2 > TAU
		% if result is still not good enough try 2step method
		try
			[SOL, vm] = script.autofind_2step(vm,list,list_core,response_halo);
			chi2 = list.chi2(SOL);
		end
	end

	% push to list (compressed information)
	if isnan(TBL.data{ii}.chi2) || TBL.data{ii}.chi2 > chi2
		fprintf(' --- NEW SOLUTION FOUND!\n');
		
		TBL.data{ii} = struct(...
			'model',	vm,...
			'chi2',		chi2 ...
		);
	end
end


function [SOL, vm] = calcMean(vm,vm1,vm2,list)
% try mean value of two neighbours
vm.param.beta0	= mean([vm1.param.beta0,	vm2.param.beta0]);
vm.param.theta0 = mean([vm1.param.theta0,	vm2.param.theta0]);
vm.param.W0		= mean([vm1.param.W0,		vm2.param.W0]);

SOL = script.autofind(vm,list);


function [SOL, vm] = calcShake(vm,q,list)
% try other initial condition (little shake q)
vm.param.beta0	= vm.param.beta0*lib.rand(1 - q,1 + q);
% vm.param.theta0 = vm.param.theta0*lib.rand(1 - q,1 + q);
% vm.param.W0		= vm.param.W0*lib.rand(1 - q,1 + q);

[SOL, vm] = script.autofind(vm,list);
