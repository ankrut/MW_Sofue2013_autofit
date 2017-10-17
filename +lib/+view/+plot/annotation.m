function a=annotation(ax,ay,type,msg,varargin)

ss = struct();
for ii=1:2:numel(varargin)
	ss.(varargin{ii}) = varargin{ii+1};
end

pos = get(gca,'position');
axlim = pos(3);
aylim = pos(4);

xlim = get(gca,'xlim');
ylim = get(gca,'ylim');

if(strcmp(get(gca,'xscale'),'linear'))
	x(1:2) = axlim/(xlim(2) - xlim(1))*(ax - xlim(1));
else
	x(1:2) = axlim/(log10(xlim(2)) - log10(xlim(1)))*(log10(ax) - log10(xlim(1)));
end

if(strcmp(get(gca,'yscale'),'linear'))
	y(1:2) = aylim/((ylim(2)) - (ylim(1)))*((ay) - (ylim(1)));
else
	y(1:2) = aylim/(log10(ylim(2)) - log10(ylim(1)))*(log10(ay) - log10(ylim(1)));
end

if(isfield(ss,'offset_arrow'))
	x = x + ss.offset_arrow(1);
	y = y + ss.offset_arrow(2);
end

if(isfield(ss,'offset_text'))
	x(1) = x(1) + ss.offset_text(1);
	y(1) = y(1) + ss.offset_text(2);
end

fx = pos(1) + x;
fy = pos(2) + y;

a=annotation(type,fx,fy,'String',msg,'units','normalized','interpreter','latex');