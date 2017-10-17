function h=profile_xy(X,Y,varargin)
h=plot(X.axis.map(X.profile),Y.axis.map(Y.profile),varargin{:});