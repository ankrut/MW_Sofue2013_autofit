% find nth extrema of a xy-curve
function [R,ypnt,coeff] = get_extrema(X,Y,n,varargin)
% find closest point of extrema
[pks,loc] = findpeaks(Y,varargin{:});

if n < 0
	n = length(pks) - n;
end

% find nth extrema if it exists
if(~isempty(n) ...			make sure n is an integer (n>0)
 && length(pks) >= n ...	make sure nth extrema exists
 && loc(n) > 1 ...			make sure extrema is not the first point
 )
	% better approx. by extrema of parabolic fit (3 points needed)
	% f(x) = a x² + b x + c
	k = loc(n);

	x1 = X(k-1);
	x2 = X(k);
	x3 = X(k+1);

	b = zeros(3,1);
	b(1) = Y(k-1);
	b(2) = Y(k);
	b(3) = Y(k+1);

	A = [x1^2 x1 1; x2^2 x2 1; x3^2 x3 1];
	x = linsolve(A,b); % solution of parabolic parameters [a,b,c]

	% calc extrema position
	R = -x(2)/x(1)/2;
	
	% extra information
	ypnt = interp1([x1 x2 x3],b,R,'spline');
	coeff = x;
else
	R = nan;
	ypnt = nan;
	coeff = nan;
end