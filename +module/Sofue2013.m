classdef Sofue2013 < module.ProfileObservation
	methods
		function obj=Sofue2013(label)
			obj=obj@module.ProfileObservation(label);
		end

		function obj=load(obj,filepath)
			SPARC_FORMAT_SPEC = [...
				'%f ',...		Galactocentric radius				[kpc]
				'%f ',...		Galactocentric radius error			[kpc]
				'%f ',...		Observed circular velocity			[km/s]
				'%f ',...		Observed circular velocity error	[km/s]
			];

			SPARC_ROW_HEADINGS = {
				'radius'
				'radius_error'
				'velocity_obs'
				'velocity_obs_error'
			};

			fid = fopen(filepath,'r');
			OBSERVATION = cell2struct(textscan(fid,SPARC_FORMAT_SPEC), SPARC_ROW_HEADINGS, 2);
			fclose(fid);
			
			obj.set('radius',			OBSERVATION.radius);
			obj.set('radius_error',		OBSERVATION.radius_error);
			obj.set('velocity',			OBSERVATION.velocity_obs);
			obj.set('velocity_error',	OBSERVATION.velocity_obs_error);
		end
		
		function p=filter(obj,f)
			kk = f(obj);
			
			p = module.Sofue2013(obj.label)...
				.set('radius',			obj.data.radius(kk))...
				.set('radius_error',	obj.data.radius_error(kk))...
				.set('velocity',		obj.data.velocity(kk))...
				.set('velocity_error',	obj.data.velocity_error(kk));
		end
	end
end