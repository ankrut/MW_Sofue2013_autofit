% helpers
fmaxn = @(X,Y,n) lib.get_extrema(X,Y,n);
fminn = @(X,Y,n) lib.get_extrema(X,-Y,n);

findgmax = @(x) find(findpeaks(x)==max(findpeaks(x)));
findgmin = @(x) find(-findpeaks(-x)==min(-findpeaks(-x)));

fcore		= @(X,Y) lib.get_extrema(X, Y, 1);
foutercore	= @(X,Y) lib.get_extrema(X, Y, findgmin(Y));
fplateau	= @(X,Y) lib.get_extrema(X,-Y, findgmin(Y));
fhalo		= @(X,Y) lib.get_extrema(X, Y, findgmin(Y)+1);

MAP = lib.require(@model.tov.fd.map);



EXPORT.center = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) obj.data.radius(1)...
);

% EXPORT.merafina = module.ProfileAnchor(...
% 	@(obj) MAP.radius.map(obj),...
% 	@(obj,X) fzero(@(x) interp1(X,obj.datadegeneracy,x,'spline'),fmaxn('radius','velocity',1))...
% );

EXPORT.velocity_core = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fcore(X,MAP.velocity.map(obj))...
);

EXPORT.velocity_outercore = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) foutercore(X,MAP.velocity.map(obj))...
);

EXPORT.velocity_plateau = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fplateau(X,MAP.velocity.map(obj))...
);

EXPORT.velocity_halo = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fhalo(X,MAP.velocity.map(obj))...
);



EXPORT.mass_core = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fcore(X,MAP.massDiff.map(obj))...
);

EXPORT.mass_outercore = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) foutercore(X,MAP.massDiff.map(obj))...
);

EXPORT.mass_plateau = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fplateau(X,MAP.massDiff.map(obj))...
);

EXPORT.mass_halo = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fhalo(X,MAP.massDiff.map(obj))...
);



EXPORT.degeneracy_core = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fcore(X,-MAP.degeneracyDiff.map(obj))...
);

EXPORT.degeneracy_outercore = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) foutercore(X,-MAP.degeneracyDiff.map(obj))...
);

EXPORT.degeneracy_plateau = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fplateau(X,-MAP.degeneracyDiff.map(obj))...
);

EXPORT.degeneracy_halo = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fhalo(X,-MAP.degeneracyDiff.map(obj))...
);



EXPORT.schwarzschild_core = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fcore(X,-MAP.schwarzschild.map(obj))...
);

EXPORT.schwarzschild_outercore = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) foutercore(X,-MAP.schwarzschild.map(obj))...
);

EXPORT.schwarzschild_plateau = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fplateau(X,-MAP.schwarzschild.map(obj))...
);

EXPORT.schwarzschild_halo = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fhalo(X,-MAP.schwarzschild.map(obj))...
);



EXPORT.potential_core = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fcore(X,MAP.potentialDiff.map(obj))...
);

EXPORT.potential_outercore = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) foutercore(X,MAP.potentialDiff.map(obj))...
);

EXPORT.potential_plateau = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fplateau(X,MAP.potentialDiff.map(obj))...
);

EXPORT.potential_halo = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fhalo(X,MAP.potentialDiff.map(obj))...
);




EXPORT.rvmax1 = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fmaxn(X,MAP.schwarzschild.map(obj),1)...
);

EXPORT.rvmax2 = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fmaxn(X,MAP.schwarzschild.map(obj),2)...
);

EXPORT.rvmax3 = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fmaxn(X,MAP.schwarzschild.map(obj),3)...
);




EXPORT.rvmin1 = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fminn(X,MAP.schwarzschild.map(obj),1)...
);

EXPORT.rvmax2 = module.ProfileAnchor(...
	@(obj) MAP.radius.map(obj),...
	@(obj,X) fminn(X,MAP.schwarzschild.map(obj),2)...
);


fDensity		 = @(obj) MAP.density.map(obj) - 0.5*EXPORT.velocity_plateau.MAP(obj,MAP.density);
% fRadius			 = @(obj) 2.274572894241457*sqrt(2*EXPORT.velocity_plateau.MAP(obj,MAP.temperature)/EXPORT.velocity_plateau.MAP(obj,MAP.density));
fRadius = @(obj) [
	EXPORT.velocity_plateau.map(obj,MAP.radius)
	EXPORT.velocity_halo.map(obj,MAP.radius)
];
fHalfLightRadius = @(obj) fzero(@(x) interp1(obj.data.radius, fDensity(obj),x,'spline'),fRadius(obj));

EXPORT.half_light = module.ProfileAnchor(...
	@(obj) obj.data.radius,...
	@(obj,X)  interp1(obj.data.radius,X,fHalfLightRadius(obj),'spline') ...
);