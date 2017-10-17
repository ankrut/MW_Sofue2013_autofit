function y0=interp1_log(X,Y,x0,varargin)
A = log(X);
B = log(Y);
kk = ~isnan(A) & ~isinf(A) & ~isnan(B) & ~isinf(B);
y0 = exp(interp1(A(kk),B(kk),log(x0),varargin{:}));