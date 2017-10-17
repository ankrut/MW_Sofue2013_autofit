function Y = polyval_loglog(p,X)
Y = exp(polyval(p,log(X)));