EXPORT.radius = module.ProfileMapping(...
	@(obj) obj.data.radius,...
	'r' ...
);

EXPORT.mass = module.ProfileMapping(...
	@(obj) obj.data.mass,...
	'M(r)'...
);

EXPORT.potential = module.ProfileMapping(...
	@(obj) obj.data.potential,...
	'\nu(r) - \nu_0'...
);

EXPORT.dnudlnr = module.ProfileMapping(...
	@(obj) (obj.data.mass./obj.data.radius + obj.data.radius.^2.*obj.data.pressure)./(1 - obj.data.mass./obj.data.radius),...
	'{\rm d}\nu/{\rm d}\ln r'...
);

EXPORT.compactness = module.ProfileMapping(...
	@(obj) obj.data.mass./obj.data.radius,...
	'\varphi(r)' ...
);

% ATTENTION: this is actually the proper velocity (celerity)
% (change "velocity" to "celerity" in future)
fw = @(x) sqrt(x./(2 - x));
EXPORT.velocity = module.ProfileMapping(...
	@(obj) fw(EXPORT.dnudlnr.map(obj)),...
	'v(r)'...
);


% SECONDARY (prelimary)
EXPORT.density = module.ProfileMapping(...
	@(obj) obj.data.density,...
	'\rho(r)'...
);

EXPORT.pressure = module.ProfileMapping(...
	@(obj) obj.data.pressure,...
	'P(r)'...
);

EXPORT.velocity_dispersion = module.ProfileMapping(...
	@(obj) sqrt(obj.data.pressure./obj.data.density),...
	'\sigma(r)'...
);

% speed of sound
EXPORT.velocitySOS = module.ProfileMapping(...
	@(obj) sqrt(obj.data.pressure.*obj.data.radius.^3./obj.data.mass),...
	'\varsigma(r)'...
);

% centripetal acceleration
EXPORT.acceleration = module.ProfileMapping(...
	@(obj) EXPORT.velocity.map(obj).^2./obj.data.radius,...
	'a(r)'...
);

EXPORT.massDiff = module.ProfileMapping(...
	@(obj) obj.data.radius.^2.*EXPORT.density.map(obj),...
	'M''(r)'...
);