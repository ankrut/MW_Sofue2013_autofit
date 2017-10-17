classdef ProfileMapping < handle
	properties
		fmap		% function handle
		var			% label of mapping (e.g. '\theta_0')
	end
	
	methods
		function obj=ProfileMapping(fmap,varargin)
			obj.fmap = fmap;
			
			if nargin == 2
				obj.var  = varargin{1};
			end
		end
		
		function data=map(obj,profile)
			data = obj.fmap(profile);
		end
	end
end