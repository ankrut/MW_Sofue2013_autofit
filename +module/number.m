% REQUIEREMENTS
%	moduels.lib.sprintf
classdef number < handle
	properties
		value
	end
	
	methods
		function obj=number(val)
			obj.value = val;
		end
		
		% round to a given base
		function obj = round(obj,base)
			obj.value = round(obj.value./base).*base;
		end
		
		% constraints value within a boundary
		function obj = within(obj,a,b)
			if obj.value < a
				obj.value = a;
			elseif obj.value > b
				obj.value = b;
			end
		end
		
		% check if value if wihtin a range
		function bool = isbetween(obj,a,b)
			bool = (a <= obj.value) && (obj.value <= b);
		end
		
		% converts to scientific string format (maintisse x 10^dim)
		function str = to_log(obj,format)
			d = floor(log10(obj.value));
			m = obj.value*10^(-d);
			
			str = lib.sprintf([format '\times10^{%d}'],m,d);
		end
	end
end