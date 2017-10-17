function h=hline(y,varargin)
h = fplot(@(x) y, varargin{:});