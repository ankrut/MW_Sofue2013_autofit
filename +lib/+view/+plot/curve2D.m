function h=curve2D(profile,ax,ay,varargin)

% get x data
switch(class(ax))
	case 'function_handle'
		X = ax(profile);
		
	case {'module.ProfileMapping', 'module.ProfileAxis'}
		X = ax.map(profile);
end

% get y data
switch(class(ay))
	case 'function_handle'
		Y = ay(profile);
		
	case {'module.ProfileMapping', 'module.ProfileAxis'}
		Y = ay.map(profile);
end

% plot curve
h = plot(X,Y);

% set label if available
if isfield(profile,'label')
	set(h,'DisplayName', profile.label);
end

% set style
if nargin > 3
	set(h, varargin{:});
end