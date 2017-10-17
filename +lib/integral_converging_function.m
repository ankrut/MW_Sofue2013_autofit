function f=integral_converging_function(X0,DX,func,TAU)
N = 500;	% number of points for partiell integration
kmax = 20;  % max iteration

f = 0;
for kk=1:kmax
	% using fast trapz method with ARBITRARRY high N
	E  = linspace(X0,X0 + DX,N);
	df = trapz(E,func(E));

	% alternative slow but SMART integral method
% 	df = integral(func,X0,X0+DX,'RelTol',TAU,'AbsTol',1E-12);

	f  = f + df;

	if(df/f < TAU)
		break
	else
		X0 = X0 + DX;
	end
end