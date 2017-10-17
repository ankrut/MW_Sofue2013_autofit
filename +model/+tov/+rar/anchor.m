% load FD anchors
EXPORT = lib.require(@model.tov.fd.anchor);

% extend RAR anchors
MAP = lib.require(@model.tov.rar.map);

EXPORT.surface = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) obj.data.radius(end)...
);
