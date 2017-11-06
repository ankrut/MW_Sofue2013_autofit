function h=table2D(TBL,ax,ay,varargin)

% get x data
switch(class(ax))
	case 'function_handle'
		X = TBL.accumulate(ax);
end

% get y data
switch(class(ay))
	case 'function_handle'
		Y = TBL.accumulate(ay);
end

% plot curve
h = plot(X,Y);

% set style
if nargin > 3
	set(h, varargin{:});
end