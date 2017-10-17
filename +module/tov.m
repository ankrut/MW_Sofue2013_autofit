classdef tov < module.ProfileData
	methods
		function obj=tov(varargin)
			obj = obj@module.ProfileData(varargin{:});
		end
	end
	
	
	% HELPERS: ode solver ------------------------------------------------
	methods (Static)
		function [R, NU, M] = ode_solver_logeta(ETA0,frho,fp,XMIN,XMAX,options)
			% ICS: [nu-nu0, M/R]
			ics		= [0, ETA0];
			fode	= @(r,y) module.tov.odeLnEta(r,y,frho,fp);
			[R,Y]	= ode45(fode,log([XMIN,XMAX]),ics,options); 

			R		= exp(R);
			NU		= Y(:,1);
			M		= Y(:,2).*R;
			
			% remove artefacts in the beginning
			R  = R(10:end);
			NU = NU(10:end);
			M  = M(10:end);
		end
	end
	
	
	% ODE FUNCTIONS ------------------------------------------------------
	methods (Static)
		function dy=odeLnEta(x,y,frho,fp)
			dy = zeros(2,1);
			
			% x			ln(r/R)
			% y(1)		nu(r) - nu0
			% y(2)		M(r)/M * R/r
			
			% frho		density function rho(r)/rho_r
			% fp		pressure function P(r)/(rho_r c²)
			
			R		= exp(x);
			NU		= y(1);
			ETA		= y(2);
			
			RHO		= frho(R,NU);			% density rho(r)/rho_r
			P		= fp(R,NU);				% pressure P(r)/(rho_r c²)

			% calculate derivatives
			dy(1) = (ETA + R^2*P)/(1 - ETA);	% metric potential
			dy(2) = R^2*RHO - ETA;				% mass parameter M(r)/M * R/r
		end
	end
end