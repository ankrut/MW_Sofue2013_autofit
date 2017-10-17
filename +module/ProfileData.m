classdef ProfileData < handle
	properties
		label
		data
	end
    
    methods
		% constructor
		function obj = ProfileData(varargin)
			if(nargin == 1)
				obj.label = varargin{:};
			else
				obj.label = '';
			end

			obj.data = struct();
		end
		
		function obj=set_label(obj,str)
			obj.label = str;
		end
		
		% add/set new data (static)
		function obj=set(obj,key,data)
			if isa(data,'function_handle')
				obj.data.(key) = data(obj);
			else
				if isnumeric(data) || ischar(data)
					obj.data.(key) = data(:);
				else
					obj.data.(key) = data;
				end
			end
		end
		
		function data=get(obj,key)
			data = obj.data.(key);
		end
	end
end