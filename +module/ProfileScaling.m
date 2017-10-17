classdef ProfileScaling < handle
	properties
		fmap
		unit
	end
	
	methods
		function obj=ProfileScaling(fmap,unit)
			if(lib.isfunc(fmap))
				obj.fmap = fmap;
			else
				obj.fmap = @(obj) fmap;
			end
			
			obj.unit = unit;
		end
		
		function q=map(obj,profile)
			q = obj.fmap(profile);
		end
	end
end