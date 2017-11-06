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
fCoreMass	= @(obj) log(ANCH.velocity_core.map(obj,AXIS.mass));
fPlatMass	= @(obj) log(ANCH.mass_plateau.map(obj,AXIS.mass));
fHaloMass	= @(obj) log(ANCH.velocity_halo.map(obj,AXIS.mass));
fHaloRadius = @(obj) log(ANCH.velocity_halo.map(obj,AXIS.radius));

fMass12		= @(obj) lib.iff(ANCH.surface.map(obj,AXIS.radius) > prediction.M12(1),...
	@() interp1(log(AXIS.radius.map(obj)),log(AXIS.mass.map(obj)),log(prediction.M12(1)),'spline'),...
	@() log(ANCH.surface.map(obj,AXIS.mass)) ...
);

fMass40		= @(obj) lib.iff(ANCH.surface.map(obj,AXIS.radius) > prediction.M40(1),...
	@() interp1(log(AXIS.radius.map(obj)),log(AXIS.mass.map(obj)),log(prediction.M40(1)),'spline'),...
	@() log(ANCH.surface.map(obj,AXIS.mass)) ...
);

fMass50		= @(obj) lib.iff(ANCH.surface.map(obj,AXIS.radius) > prediction.M50(1),...
	@() interp1(log(AXIS.radius.map(obj)),log(AXIS.mass.map(obj)),log(prediction.M50(1)),'spline'),...
	@() log(ANCH.surface.map(obj,AXIS.mass)) ...
);

% define responses
Mc				= module.ProfileResponse(fCoreMass,		log(prediction.Mc));
Mp				= module.ProfileResponse(fPlatMass,		log(prediction.Mc));
Mh				= module.ProfileResponse(fHaloMass,		log(prediction.Mh));
Rh				= module.ProfileResponse(fHaloRadius,	log(prediction.rh));
M12				= module.ProfileResponse(fMass12,		log(prediction.M12(2)));
M40				= module.ProfileResponse(fMass40,		log(prediction.M40(2)));
M50				= module.ProfileResponse(fMass50,		log(prediction.M50(2)));

% set response-prediction pairs
EXPORT.core			= module.ProfileResponseList(Mc);
EXPORT.halo			= module.ProfileResponseList(Mh,Rh);
EXPORT.core_halo	= module.ProfileResponseList(Mc,Mh,Rh);
EXPORT.data			= module.ProfileResponseList(Mp,M12,M40);
EXPORT.all			= module.ProfileResponseList(Mc,Mh,Rh,M12,M40);