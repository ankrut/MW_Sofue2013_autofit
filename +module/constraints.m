% physical constants
c		= 299792458;			% m/s
kB		= 1.3806488E-23;		% J/K
hbar	= 1.054571726E-34;		% J/s
h		= 2*pi*hbar;
G		= 6.67384E-11;			% kg m^3/s^2
eV		= 1.602176565E-19;		% J
H0		= 67.74;				% km/s/Mpc

% Planck scales
lp		= 1.61619997E-35;		% m (Planck length)
mp		= 2.17647051E-8;		% kg (Planck mass)

% scales
a		= 31556926;				% s (one year)
parsec	= 3.0856776E16;			% m
kpc		= 1E3*parsec;			% m
AU		= 149597870700;			% m
ly		= 9.461E15;				% m (light year)
lh		= 1079252848.8E3;		% m (light hour)
eVcc	= 1.783E-36;			% eV/c²
keVcc	= 1E3*eVcc;				% eV/c²

% observations
Msun	= 1.9884E30;			% kg
Lsun	= 3.846E26;				% W

% Mbhmw	= 4.31E6*Msun;			% kg
% DMbhmw	= 0.38E6*Msun;			% kg
% Sigma0	= 120*Msun/parsec^2;	% kg/m^2;

% comparable density
rhoNucleus	= 3E17;				% kg/m^3 (density of an atomic nucleus)
rhoEarth	= 5.515*1E-3/1E-6;	% kg/m^3 (mean density of Earth)

% particle degeneracy for fermions
g = 2;

% magnitudes
MAGNITUDE = struct(...
	'n',	1E-9,...
	'mu',	1E-6,...
	'm',	1E-3,...
	'c',	1E-2,...
	'd',	1E-1,...
	'SI',	1,...
	'k',	1E3,...
	'M',	1E6,...
	'G',	1E9,...
	'T',	1E12 ...
);

