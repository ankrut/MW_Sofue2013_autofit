function f=trapz(func,BETA,ALPHA,EC,NN)
	% preallocate (speed performance)
	f = zeros(size(ALPHA));

	% calculate fermi integral for each (theta,w,beta) set
	for ii = 1:length(ALPHA)
		E = linspace(1,EC(ii),NN);
		f(ii) = trapz(E,func(E,BETA(ii),ALPHA(ii),EC(ii)));
	end
end