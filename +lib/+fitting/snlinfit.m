% simplified nlinfit with weighting
function [p,db] = snlinfit(X,Y,modelfun,x0,varargin)
[p,R,J] = nlinfit(X,Y,modelfun,x0);
ci = nlparci(p,R,'Jacobian',J,varargin{:});
db = diff(ci')/2;