function [SOL,varargout] = findSolution(vm,fSolution,fChi2,TAU)
nn			= numel(fSolution);
chi2(1:nn)	= nan;

for ii = 1:nn
	if isnan(min(chi2)) || min(chi2) > TAU
		try
			[SOL(ii),VM(ii)] = fSolution{ii}(vm);
			chi2(ii)		 = fChi2(SOL(ii));
		end
	end
end

if isnan(min(chi2))
	error('no solution found')
end

% select best solution
kk				= chi2 == min(chi2);
SOL				= SOL(kk);
varargout{1}	= VM(kk);
varargout{2}	= chi2(kk);