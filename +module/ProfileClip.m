classdef ProfileClip < handle
	properties
		fA		% function handle (with module.ProfileAnchor)
		fB		% function handle (with module.ProfileAnchor)
		qa		% padding lower bound (relative to width)
		qb		% padding upper bound (relative to width)
		d		% extra padding (upper/lower absolute magnitudes)
	end
	
	methods
		function obj=ProfileClip(fA,fB,qa,qb,d)
			obj.fA = fA;
			obj.fB = fB;
			obj.qa = qa;
			obj.qb = qb;
			obj.d = d;
		end
		
		function clip = map(obj,profile,axis,scale)
			% helpers
			flin = @(xmin,xmax,dx,qa,qb,d) [(xmin - qa*dx - d), (xmax + qb*dx + d)];
			flog = @(xmin,xmax,dx,qa,qb,d) 10.^[(log10(xmin) - qa*dx - d), (log10(xmax) + qb*dx + d)];

			% map values
			X = axis.map(profile);
			
% 			% filter values if log scale
% 			if strcmp(scale,'log')
% 				X = X(X>0);
% 			end
				
			if(lib.isfunc(obj.fA))
				xmin = obj.fA(profile, X);
			else
				xmin = obj.fA;
			end

			if(lib.isfunc(obj.fB))
				xmax = obj.fB(profile, X);
			else
				xmax = obj.fB;
			end

			switch scale
				case 'log'
				% calc log10 difference
				dx = log10(xmax) - log10(xmin);
				clip = flog(xmin,xmax,dx,obj.qa,obj.qb,obj.d);

				case 'linear'
				% calc linear difference
				dx = xmax - xmin;
				clip = flin(xmin,xmax,dx,obj.qa,obj.qb,obj.d);
			end
		end
	end
end