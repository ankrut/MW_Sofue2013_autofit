classdef ProfileResponse < handle
	properties
		response
		prediction
		weight
		
		% DEPRECATED
		response_value
	end
	
	methods
		function obj = ProfileResponse(fmap,prediction,varargin)
			obj.response	= fmap;
			obj.prediction	= prediction;
			
			if nargin == 2
				obj.weight = 1./prediction.^2;
			else
				obj.weight = varargin{1};
			end
		end
		
		function x=chi2(obj,profile)
			x = (1 - obj.response.map(profile)/obj.prediction)^2;
		end
		
		
		% DEPRECATED
		function obj=map(obj,profile)
			obj.response_value = obj.response.map(profile);
		end
		
		function b=is_smaller(obj)
			b = obj.response_value < obj.prediction;
		end
		
		function b=is_greater(obj)
			b = obj.response_value > obj.prediction;
		end
		
		function b=is_equal(obj,tau)
			b = abs(1 - obj.response_value/obj.prediction) < tau;
		end
	end
end
