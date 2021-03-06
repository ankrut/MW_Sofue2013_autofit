FLABEL_UNIT		= '$%s\\quad[%s]$';
FLABEL_SCALE	= '$%s/%s$';
FLABEL_NULL		= '$%s%s$';

MAP		= lib.require(@model.tov.rar.map);
DMAP	= lib.require(@model.tov.fd.dynmap);
SCALE	= lib.require(@model.tov.rar.scale);
CLIP	= lib.require(@model.tov.rar.clip);

% define axis
AXIS.RADIUS			= module.ProfileAxis(MAP.radius,			SCALE.astro.radius);
AXIS.DENSITY		= module.ProfileAxis(MAP.cache.density,		SCALE.astro.density);
AXIS.PRESSURE		= module.ProfileAxis(MAP.cache.pressure,	SCALE.astro.pressure);
AXIS.MASS			= module.ProfileAxis(MAP.mass,				SCALE.astro.mass);
AXIS.VELOCITY		= module.ProfileAxis(MAP.velocity,			SCALE.astro.velocity);
AXIS.VELOCITYRMS	= module.ProfileAxis(MAP.velocityRMS,		SCALE.astro.velocity);
AXIS.DEGENERACY		= module.ProfileAxis(DMAP.degeneracy_plateau_offset);
AXIS.MASSDIFF		= module.ProfileAxis(MAP.massDiff,			SCALE.astro.massDiff);
AXIS.DEGENERACYDIFF	= module.ProfileAxis(MAP.degeneracyDiff,	SCALE.astro.degeneracyDiff);

% define axis views
EXPORT.radius = struct(...
	'model',	AXIS.RADIUS,...
	'format',	FLABEL_UNIT,...
	'clip',		CLIP.radius ...
);

EXPORT.density = struct(...
	'model',	AXIS.DENSITY,...
	'format',	FLABEL_UNIT,...
	'clip',		CLIP.density ...
);

EXPORT.pressure = struct(...
	'model',	AXIS.PRESSURE,...
	'format',	FLABEL_UNIT,...
	'clip',		CLIP.pressure ...
);

EXPORT.velocity = struct(...
	'model',	AXIS.VELOCITY,...
	'format',	FLABEL_UNIT,...
	'clip',		CLIP.velocity ...
);

EXPORT.velocityRMS = struct(...
	'model',	AXIS.VELOCITYRMS,...
	'format',	FLABEL_UNIT ...
);

EXPORT.mass = struct(...
	'model',	AXIS.MASS,...
	'format',	FLABEL_UNIT,...
	'clip',		CLIP.mass ...
);

EXPORT.degeneracy = struct(...
	'model',	AXIS.DEGENERACY,...
	'format',	FLABEL_NULL,...
	'clip',		CLIP.degeneracy ...
);

EXPORT.massDiff = struct(...
	'model',	AXIS.MASSDIFF,...
	'format',	FLABEL_UNIT,...
	'clip',		CLIP.massDiff ...
);

EXPORT.degeneracyDiff = struct(...
	'model',	AXIS.DEGENERACYDIFF,...
	'format',	FLABEL_UNIT ...
);