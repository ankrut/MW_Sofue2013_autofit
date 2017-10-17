function xlim(profiles,axis,clip)
scale = get(gca,'xscale');
	
lim = profiles.map(@(p) ...
	clip.map(p, axis, scale) ...
).reduce(@(a,b) [min(a(1),b(1)) max(a(2),b(2))],[nan,nan]);

xlim(lim);
