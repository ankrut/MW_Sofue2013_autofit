function p = polyfit_loglog(X,Y,n)
p = polyfit(log(X),log(Y),n);