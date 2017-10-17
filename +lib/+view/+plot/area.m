function h = area(xpoints,upper,lower,C,varargin)
X = [xpoints,fliplr(xpoints)];
Y = [upper,fliplr(lower)];
h = fill(X,Y,C,varargin{:});