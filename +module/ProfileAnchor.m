classdef ProfileAnchor < handle
	
	properties (Access = private)
		lastProfile
		lastX
		lastPnt
	end
	
	properties
		fmap
		fanchor
	end
	
	methods
		function obj=ProfileAnchor(fmap,fanchor)
			obj.fmap	= fmap;
			obj.fanchor = fanchor;
		end
		
		% varargin		[module.ProfileAxis]
		function [varargout] = map(obj,profile,varargin)
			% get anchor point (x-value)
			X		= obj.fmap(profile);
			PNT		= obj.fanchor(profile,X);

			% preallocate
			varargout = cell(size(varargin));
			
			% collect other values (y-values)
			for ii=1:length(varargin)
				switch class(varargin{ii})
					case 'char'
					ykey = varargin{ii};
					Y = profile.data.(ykey);
				
					case {'module.ProfileAxis','module.ProfileMapping'}
					Y = varargin{ii}.map(profile);
				
					otherwise
					Y = varargin{ii};
				end
				
				varargout{ii} = interp1(X,Y,PNT,'spline');
			end
		end
		
		function [varargout] = MAP(obj,profile,varargin)
			persistent OBJ PROFILE X PNT
			
			% cache
			if isempty(OBJ) || OBJ ~= obj || profile ~= PROFILE
				OBJ		= obj;
				PROFILE = profile;
				X		= obj.fmap(profile);
				PNT		= obj.fanchor(profile,X);
			end
			

			% preallocate
			varargout = cell(size(varargin));
			
			% collect other values
			for ii=1:length(varargin)
				switch class(varargin{ii})
					case 'char'
					ykey = varargin{ii};
					Y = profile.data.(ykey);
				
					case {'module.ProfileAxis','module.ProfileMapping'}
					Y = varargin{ii}.map(profile);
				
					otherwise
					Y = varargin{ii};
				end
				
				varargout{ii} = interp1(X,Y,PNT,'spline');
			end
		end
	end
end