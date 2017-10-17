% DESCRIPTION: this model describes a data set of astronomical
% observations. That means radius is given in kpc, velocities in km/s, mass
% in solar masses (Msun), etc.
classdef ProfileObservation < module.ProfileData
	
	properties (SetAccess = private, Dependent)
		length
	end
	
	methods
		function obj=ProfileObservation(label)
			obj = obj@module.ProfileData(label);
		end
		
		function n=get.length(obj)
			list = fieldnames(obj.data);
			
			if(numel(list) == 0)
				n = 0;
			else			
				n = numel(obj.data.(list{1}));
			end
		end
		
		function x=chi2(obj,PROFILE)
			MAP		= lib.require(@model.SPARC.map);
			SCALE	= lib.require(@model.SPARC.scale);

			AXIS_V = module.ProfileAxis(MAP.velocity, SCALE.astro.velocity);
			AXIS_W = module.ProfileAxis(MAP.weight, SCALE.astro.weight);
			
			x = sum(AXIS_W.map(obj).*(AXIS_V.map(obj) - AXIS_V.map(PROFILE)).^2);
		end

		function fit = nlinfit(obj,fModelWrap,fParamWrap,fB0,PARAMSET,opts,varargin)
			% load map and scale models
			MAP		= lib.matlab.require(@configs.model.SPARC.map);
			SCALE	= lib.matlab.require(@configs.model.SPARC.scale);

			% set axis, predictors (X = radius) and response (Y = velocity)
			AX		= module.ProfileAxis(MAP.radius, SCALE.astro.radius_kpc);
			AY		= module.ProfileAxis(MAP.velocity, SCALE.astro.velocity);

			% set weights axis (reciprocal to the variance)
			AW		= module.ProfileAxis(MAP.weight, SCALE.astro.weight);
			
			% convert PARAMSET to vector (MATLAB's nlinfit needs it so)
			B0 = fB0(PARAMSET);

			% set logicals (which parameters are fixed)
			if isempty(varargin)
				Q = false(1,numel(B0));
			else
				Q = logical(varargin{1});
			end

			% set parameter filler
			f = @(b) fParamWrap(arrayfun(@(ii)lib.num.iff(Q(ii), B0(ii), @() b(ii - sum(Q(1:ii)))),1:numel(B0)));

			% find param (weighted least squares)
			fit = nlinfit@module.ProfileData(obj,AX,AY,AW,@(b,x) fModelWrap(f(b),x),B0(~Q),opts);
			
			% full result
			fit.result = f(fit.beta);

			% chi square
			R = AX.map(obj);
			Y = fModelWrap(fit.result,R);
			fit.chi2 = sum(AW.map(obj).*(AY.map(obj) - Y).^2);
			
			% do next logical level if available
			if(numel(varargin) > 1)
				fit2 = obj.nlinfit(fModelWrap,fParamWrap,fB0,fit.result,varargin{2:end});
				
				% repeat until absolute chi square change is negligle
				while abs(fit.chi2 - fit2.chi2) > 1E-6
					fit = obj.nlinfit(fModelWrap,fParamWrap,fB0,fit2.result,varargin{:});
				end
			end
		end
	end
end