function T = create(T,mm,vm,CONFIGS)
% load physical constants
module.constraints

for ii=1:numel(mm)
	m = mm(ii)*keVcc;
	
	fprintf('\n--- [%d/%d : %5f] -------------------------\n',ii,numel(mm),mm(ii));
	
	% check if solution for given particle mass m exists already
	% (with 12 digits accuracy)
	cell = T.find(@(t) round(log(t.model.param.m),12) == round(log(m),12));
	
	if isempty(cell)
		% update particle mass
		vm.param.m = m;

		findAndPush(T,vm,CONFIGS);
	elseif cell.chi2 > CONFIGS.tau
		kk = T.indexOf(@(t) t.model.param.m == cell.model.param.m);
		findAndUpdate(T,kk,CONFIGS);
	end
end


function findAndPush(T,vm,CONFIGS)
% estimate other parameters
if T.length > 2
	vm = script.fixed_m.estimateModelStruct(vm,T,3);
end

try [~,vm,chi2] = script.fixed_m.findSolution(vm,CONFIGS);
	
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
	vm = script.fixed_m.estimateModelStruct(vm,T,3);
end

% find solution and update if succesfull
try [~,vm,chi2] = script.fixed_m.findSolution(vm,CONFIGS);
	
	fprintf(' --- BETTER SOLUTION FOUND for id %d: %4.1E -> %4.1E :) ---\n', jj, T.data{jj}.chi2, chi2);
	
	T.data{jj}.model	= vm;
	T.data{jj}.chi2		= chi2;

catch
	fprintf('NO BETTER SOLUTION FOUND :(\n');
end



