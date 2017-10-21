classdef ProfileResponse < module.ProfileMapping
	properties
		prediction
		weight
	end
	
	methods
		function obj = ProfileResponse(fmap,prediction,varargin)
			obj = obj@module.ProfileMapping(fmap);
			
			obj.prediction	= prediction;
			
			if nargin == 2
				obj.weight = 1./prediction.^2;
			else
				obj.weight = varargin{1};
			end
		end
		
		function x=chi2(obj,profile)
			x = obj.weight*(obj.map(profile) - obj.prediction)^2;
		end
	end
end
