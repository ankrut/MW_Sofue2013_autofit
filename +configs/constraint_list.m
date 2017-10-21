% load packages
ANCH			= lib.require(@model.tov.rar.anchor);
MAP				= lib.require(@model.tov.rar.map);
SCALE			= lib.require(@model.tov.rar.scale);

% load predictions (radius in pc and mass in Msun)
prediction		=  lib.require(@configs.predictions);

% define axis (radius in pc and mass in Msun)
AXIS.radius		= module.ProfileAxis(MAP.radius,	SCALE.astro.radius);
AXIS.mass		= module.ProfileAxis(MAP.mass,		SCALE.astro.mass);

% defines anchors
fCoreMass	= @(obj) ANCH.velocity_core.map(obj,AXIS.mass);
fHaloMass	= @(obj) ANCH.velocity_halo.map(obj,AXIS.mass);
fHaloRadius = @(obj) ANCH.velocity_halo.map(obj,AXIS.radius);
fMass12		= @(obj) exp(interp1(log(AXIS.radius.map(obj)),log(AXIS.mass.map(obj)),log(prediction.M12(1)),'spline'));
fMass40		= @(obj) exp(interp1(log(AXIS.radius.map(obj)),log(AXIS.mass.map(obj)),log(prediction.M40(1)),'spline'));
fMass50		= @(obj) exp(interp1(log(AXIS.radius.map(obj)),log(AXIS.mass.map(obj)),log(prediction.M50(1)),'spline'));

% define responses
Mc				= module.ProfileResponse(fCoreMass,		prediction.Mc);
Mh				= module.ProfileResponse(fHaloMass,		prediction.Mh);
Rh				= module.ProfileResponse(fHaloRadius,	prediction.rh);
M12				= module.ProfileResponse(fMass12,		prediction.M12(2));
M40				= module.ProfileResponse(fMass40,		prediction.M40(2));
M50				= module.ProfileResponse(fMass50,		prediction.M50(2));

% set response-prediction pairs
EXPORT.core			= module.ProfileResponseList(Mc);
EXPORT.halo			= module.ProfileResponseList(Mh,Rh);
EXPORT.core_halo	= module.ProfileResponseList(Mc,Mh,Rh);
EXPORT.data			= module.ProfileResponseList(M12,M40);
EXPORT.all			= module.ProfileResponseList(Mc,Mh,Rh,M12,M40);