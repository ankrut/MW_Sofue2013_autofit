function Z=trapz_seq(X,Y)
Z = zeros(size(X));

Z(1) = trapz(X(1:2),Y(1:2));
for ii=2:numel(X)
	Z(ii) = Z(ii-1) + trapz(X(ii-1:ii),Y(ii-1:ii));
end