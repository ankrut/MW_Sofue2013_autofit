function lh=legend(arr,varargin)
% hide lines objects Displayname
objs = get(gca,'Children');
for ii=1:numel(objs)
	CURVE = objs(ii);
	
	if ~isprop(CURVE,'Annotation')
		continue;
	elseif isempty(CURVE.DisplayName)
		CURVE.Annotation.LegendInformation.IconDisplayStyle = 'off';
	else
		CURVE.Annotation.LegendInformation.IconDisplayStyle = 'on';
	end
end


lh = legend(arr);
set(lh,'Interpreter','latex','box','off',varargin{:});
set(lh.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[1;1;1;.8]));