function T = create(T,BETA0,vm,CONFIGS)

for ii=1:numel(BETA0)
	beta0 = BETA0(ii);
	
	fprintf('\n--- [%d/%d : %4E] -------------------------\n',ii,numel(BETA0),beta0);
	
	% check if solution for given beta0 exists already
	% (with 12 digits accuracy)
	cell = T.find(@(t) round(log(t.model.param.beta0),12) == round(log(beta0),12));
	
	if isempty(cell)
		% update model
		vm.param.beta0	= beta0;
		
		findAndPush(T,vm,CONFIGS);
	elseif cell.chi2 > CONFIGS.tau
		kk = T.indexOf(@(t) t.model.param.beta0 == cell.model.param.beta0);
		findAndUpdate(T,kk,CONFIGS);
	end
end


function findAndPush(T,vm,CONFIGS)
% estimate other parameters
if T.length > 2
	vm = script.fixed_beta0.estimateModelStruct(vm,T,3);
end
		
try [~,vm,chi2] = script.fixed_beta0.findSolution(vm,CONFIGS);
	
	T.push(struct(...
		'model',	vm,...
		'chi2',		chi2 ...
	));
catch
	fprintf('NO SOLUTION FOUND :(\n');
end


function findAndUpdate(T,jj,CONFIGS)
% select model
vm = T.data{jj}.model;

% estimate other parameters
if T.length > 2
	vm = script.fixed_beta0.estimateModelStruct(vm,T,3);
end

% find solution and update if succesfull
try [~,vm,chi2] = script.fixed_beta0.findSolution(vm,CONFIGS);
	
	fprintf(' --- BETTER SOLUTION FOUND for id %d: %4.1E -> %4.1E :) ---\n', jj, T.data{jj}.chi2, chi2);
	
	T.data{jj}.model	= vm;
	T.data{jj}.chi2		= chi2;

catch
	fprintf('NO BETTER SOLUTION FOUND :(\n');
end
