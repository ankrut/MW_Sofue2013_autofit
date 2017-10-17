function farea(fupper,flower,C,varargin)
XLIM = get(gca,'XLim');

if strcmp(get(gca,'XScale'),'log')
	XLIM = log10(XLIM);
	xpoints = logspace(XLIM(1),XLIM(2),100);
else
	xpoints = linspace(XLIM(1),XLIM(2),100);
end

upper = fupper(xpoints);
lower = flower(xpoints);

lib.view.plot.area(xpoints,upper,lower,C,varargin{:})