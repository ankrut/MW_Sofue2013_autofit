% load packages
ANCH			= lib.require(@model.tov.rar.anchor);
MAP				= lib.require(@model.tov.rar.map);
SCALE			= lib.require(@model.tov.rar.scale);

% load predictions (radius in pc and mass in Msun)
prediction		=  lib.require(@configs.predictions);

% define axis (radius in pc and mass in Msun)
AXIS.radius		= module.ProfileAxis(MAP.radius,	SCALE.astro.radius);
AXIS.mass		= module.ProfileAxis(MAP.mass,		SCALE.astro.mass);

% define responses
Mc				= module.ProfileMapping(@(obj) ANCH.velocity_core.map(obj,AXIS.mass));
Mh				= module.ProfileMapping(@(obj) ANCH.velocity_halo.map(obj,AXIS.mass));
Rh				= module.ProfileMapping(@(obj) ANCH.velocity_halo.map(obj,AXIS.radius));
M12				= module.ProfileMapping(@(obj) exp(interp1(log(AXIS.radius.map(obj)),log(AXIS.mass.map(obj)),log(prediction.M12(1)),'spline')));
M50				= module.ProfileMapping(@(obj) exp(interp1(log(AXIS.radius.map(obj)),log(AXIS.mass.map(obj)),log(prediction.M50(1)),'spline')));

% set response-prediction pairs
EXPORT.core = module.ProfileResponseList([
	module.ProfileResponse(Mc,	prediction.Mc)
]);

EXPORT.halo = module.ProfileResponseList([
	module.ProfileResponse(Mh,	prediction.Mh)
	module.ProfileResponse(Rh,	prediction.rh)
]);

EXPORT.core_halo = module.ProfileResponseList([
	module.ProfileResponse(Mc,	prediction.Mc)
	module.ProfileResponse(Mh,	prediction.Mh)
	module.ProfileResponse(Rh,	prediction.rh)
]);

EXPORT.data = module.ProfileResponseList([
	module.ProfileResponse(M12,	prediction.M12(2))
	module.ProfileResponse(M50,	prediction.M50(2))
]);

EXPORT.all = module.ProfileResponseList([
	module.ProfileResponse(Mc,	prediction.Mc)
	module.ProfileResponse(Mh,	prediction.Mh)
	module.ProfileResponse(Rh,	prediction.rh)
	module.ProfileResponse(M12,	prediction.M12(2))
	module.ProfileResponse(M50,	prediction.M50(2))
]);