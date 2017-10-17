function f=matlab(func,BETA,ALPHA,EC,TAU)
	% preallocate (speed performance)
	f = zeros(size(ALPHA));

	% calculate fermi integral for each (theta,w,beta) set
	for ii = 1:length(ALPHA)
		f(ii) = integral(@(E) func(E,BETA(ii),ALPHA(ii),EC(ii)),1,EC(ii),'RelTol',TAU);
	end
end