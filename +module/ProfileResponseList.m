classdef ProfileResponseList < module.array
	methods
		function obj = ProfileResponseList(varargin)
			obj = obj@module.array(varargin{:});
		end
		
		function value=chi2(obj,profile)
			fCHI2 = @(elm) elm.weight.*(elm.response.map(profile) - elm.prediction).^2;
			value = sum(obj.accumulate(fCHI2));
		end
	end
end