MAP = lib.require(@model.tov.rar.map);

fcore = @(obj) lib.get_extrema(log(MAP.radius.map(obj)),log(MAP.velocity.map(obj)),1);


EXPORT.central			= @(obj,Y) Y(1);
EXPORT.velocity_core	= @(obj,Y) interp1(log(MAP.radius.map(obj)),Y,fcore(obj),'spline');