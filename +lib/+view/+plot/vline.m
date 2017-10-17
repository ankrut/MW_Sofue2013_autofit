function h=vline(x,varargin)
h=line([x x],get(gca,'YLim'),varargin{:});