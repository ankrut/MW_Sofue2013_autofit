classdef profile < module.tov
	methods
		function obj=profile(varargin)
			obj = obj@module.tov(varargin{:});
		end
		
		function obj=define(obj,s)
			module.array(fieldnames(s)).forEach(@(key) ...
				obj.set(key,s.(key)) ...
			);
		end
		
		function obj=calc(obj,opts)
			% destructor
			THETA0	= obj.data.theta0;
			BETA0	= obj.data.beta0;
			XMIN	= opts.xmin;
			XMAX	= opts.xmax;
			TAU		= opts.tau;		% absolute error for ode solver
			RTAU	= opts.rtau;	% relative error for ode solver
			
			% substitution
			ALPHA0	= 1 + THETA0*BETA0;
			
			% define density and pressure function handles
			frho = @(r,nu) 4/sqrt(pi)*model.tov.fd.profile.fermi_integral2_trapz(ALPHA0*exp(-nu./2),BETA0*exp(-nu./2),1E-6);
			fp   = @(r,nu) 4/3/sqrt(pi)*model.tov.fd.profile.fermi_integral4_trapz(ALPHA0*exp(-nu./2),BETA0*exp(-nu./2),1E-6);

			% set OPTIONS (for ODE solver)
			options	= odeset('RelTol',RTAU,'AbsTol',[TAU TAU]);
			
			% call ode solver for theta(r)
			[R, NU, M] = module.tov.ode_solver_logeta(0,frho,fp,XMIN,XMAX,options);
			
			obj.data.radius			= R;
			obj.data.potential		= NU;
			obj.data.mass			= M;
			
			% cache time consuming magnitudes
			obj.data.density		= frho(R,NU);
			obj.data.pressure		= fp(R,NU);
		end
	end
	
	methods (Static)
		function obj=fProfile(p)
			obj = model.tov.fd.profile().define(p.param).calc(p.options);
		end
	end

	% CORRESPONDING PROFILES ---------------------------------------------
	methods
		function p = get_core(obj)
			if(obj.data.theta0 <= 0)
				display(sprintf('WARNING: profile (THETA0 = %f) has no fully degenerate core',obj.data.theta0));
			end
			
			param = struct(...
				'fermi_energy', 1 + obj.data.theta0*obj.data.beta0,...
				'theta0',		obj.data.theta0,...
				'beta0',		obj.data.beta0 ...
			);
		
			opts = struct(...
				'xmin', obj.data.radius(1),...
				'xmax', obj.data.radius(end),...
				'tau',  1E-16,...
				'rtau', 1E-8 ...
			);
		
			p = classes.profile.tov.Core().define(param).calc(opts);
			
		end
		
		function p = get_halo(obj)
			p = model.tov.fd.profile();
			
			opts = struct(...
				'xmin', obj.data.radius(1), ...
				'xmax', obj.data.radius(end), ...
				'tau',  1E-16,...
				'rtau', 1E-6 ...
			);

			if obj.data.theta0 > -5
				ANCH	= lib.require(@model.tov.fd.anchor);
				MAP		= lib.require(@model.tov.fd.map);
				
				param = struct(...
					'theta0', ANCH.velocity_plateau.map(obj,MAP.degeneracy),...
					'beta0',  ANCH.velocity_plateau.map(obj,MAP.temperature) ...
				);	
			else
				param = struct(...
					'theta0', obj.data.theta0,...
					'beta0',  obj.data.beta0 ...
				);
			end
			
			p.define(param).calc(opts);
		end
	end
	
	% FERMI INTEGRALS ----------------------------------------------------
	methods (Static)
		function F=calc_velocityRMS(ALPHA,BETA)
			% preallocate (speed performance)
			F = zeros(size(ALPHA));
			
			% calculate fermi integral for each (theta,w,beta) set
			for ii = 1:length(ALPHA)
				alpha	= ALPHA(ii);
				beta	= BETA(ii);
				func1	= @(E) sqrt(E.^2 - 1)./E./(exp((E - alpha)./beta) + 1);
				func2	= @(E) sqrt(E.^2 - 1).*E./(exp((E - alpha)./beta) + 1);
				
				E0		= 1;
				DE		= max(10*beta,abs(ALPHA(ii)-1));	% 2nd exp. can be negative !!
				
				% integrate until the change is small enough because we
				% know that the distribtion function is converging to zero.
				F1 = lib.integral_converging_function(E0,DE,func1,1E-4);
				F2 = lib.integral_converging_function(E0,DE,func2,1E-4);
				
				F(ii) = sqrt(1-F1/F2);
			end
		end
		
		% integrate by energy, E = E(y) + 1
		% NOTE: integral function is unstable !!!
		function f=fermi_integral2(ALPHA,BETA,TAU)
			f = zeros(size(ALPHA));

			for ii = 1:length(ALPHA)
				alpha	= ALPHA(ii); % 1 + BETA*THETA
				beta	= BETA(ii);
				func	= @(E) sqrt(E.^2 - 1).*E.^2./(exp((E - alpha)./beta) + 1);
				
				% integrate to infinity
				f(ii) = integral(func,1,Inf,'RelTol',TAU,'AbsTol',1E-16);
			end
		end
		
		% integrate by energy, E = E(y) + 1
		% NOTE: integral function is unstable !!!
		function f=fermi_integral4(ALPHA,BETA,TAU)
			f = zeros(size(ALPHA));

			for ii = 1:length(ALPHA)
				alpha	= ALPHA(ii); % 1 + BETA*THETA
				beta	= BETA(ii);
				func	= @(E) (E.^2 - 1).^(3/2)./(exp((E - alpha)./beta) + 1);
				
				% integrate to infinity
				f(ii) = integral(func,1,Inf,'RelTol',TAU,'AbsTol',1E-16);
			end
		end
		
		
		% for particle density
		function F=fermi_integral0_trapz(ALPHA,BETA,TAU)
			F = zeros(size(ALPHA));
			for ii = 1:length(ALPHA)
				alpha	= ALPHA(ii);
				beta	= BETA(ii);
				
				func	= @(E) sqrt(E.^2 - 1).*E./(exp((E - alpha)./beta) + 1);
				E0		= 1;
				DE		= max(10*beta,abs(ALPHA(ii) - 1));	% 2nd exp. can be negative !!
				
				% integrate until the change is small enough because we
				% know that the distribtion function is converging to zero.
				F(ii) = lib.integral_converging_function(E0,DE,func,TAU);
			end
		end

		% for mass density
		function F=fermi_integral2_trapz(ALPHA,BETA,TAU)
			F = zeros(size(ALPHA));
			for ii = 1:length(ALPHA)
				alpha	= ALPHA(ii);
				beta	= BETA(ii);
				
				func	= @(E) sqrt(E.^2 - 1).*E.^2./(exp((E - alpha)./beta) + 1);
				E0		= 1;
				DE		= max(10*beta,abs(ALPHA(ii) - 1));	% 2nd exp. can be negative !!
				
				% integrate until the change is small enough because we
				% know that the distribtion function is converging to zero.
				F(ii) = lib.integral_converging_function(E0,DE,func,TAU);
			end
		end
		
		% for pressure
		function F=fermi_integral4_trapz(ALPHA,BETA,TAU)
			F = zeros(size(ALPHA));
			for ii = 1:length(ALPHA)
				alpha	= ALPHA(ii);
				beta	= BETA(ii);
				
				func	= @(E) (E.^2 - 1).^(3/2)./(exp((E - alpha)./beta) + 1);
				E0		= 1;
				DE		= max(10*beta,abs(ALPHA(ii) - 1));	% 2nd exp. can be negative !!
				
				% integrate until the change is small enough because we
				% know that the distribtion function is converging to zero.
				F(ii) = lib.integral_converging_function(E0,DE,func,TAU);
			end
		end
		
		
% 		% split interval: first part numerical + second analytical
% 		function f=fermi_integral2_split(MU,BETA,FERMIN,FERMITAU)
% 			f = zeros(size(MU));
% 			
% 			func = @(mu,beta,Y) sqrt(1 + 2*Y.^2)./(exp((sqrt(1 + 2*Y.^2) - mu)./beta) + 1);
% 			fapx = @(mu,beta,b) sqrt(2)*b/exp((sqrt(2)*b - mu)./beta); % Y >> 1
% 
% 			for ii = 1:length(MU)
% 				mu		= 1 + MU(ii);
% 				beta	= BETA(ii);
% 				
% 				% first find sufficient large b
% 				b = abs(mu);
% 				while(abs(1 - fapx(mu,beta,b)/func(mu,beta,b)) >= FERMITAU)
% 					b = 2*b;
% 				end
% 
% 				% now calc relativistic fermi integral
% 				Y = linspace(0,b,FERMIN);
% 
% 				% integrate first part up to Ymax=b numerically
% 				f1 = trapz(Y,Y.^2.*func(mu,beta,Y));
% 
% 				% and (very small) rest of integration analytically
% 				f2 = (1/2)*sqrt(2)*beta*(3*beta^2*sqrt(2)*b+sqrt(2)*b^3+3*beta^3+3*b^2*beta)*exp(-(b*sqrt(2)-1-mu)/beta);
% 
% 				% sum integral parts
% 				f(ii) = f1 + f2;
% 			end
% 		end
% 		
% 		% split interval: first part numerical + second analytical
% 		function f=fermi_integral4_split(MU,BETA,FERMIN,FERMITAU)
% 			THETA = MU./BETA;
% 			f = zeros(size(THETA));
% 			
% 			func = @(theta,beta,Y) 1./sqrt(1 + 2*Y.^2)./(exp((sqrt(1 + 2*Y.^2) - 1 - theta)./beta) + 1);
% 			fapx = @(theta,beta,b) sqrt(2)*b/exp((sqrt(2)*b - 1 - theta)./beta); % Y >> 1
% 
% 			for ii = 1:length(THETA)
% 				theta = THETA(ii);
% 				beta  = BETA(ii);
% 				
% 				% first find sufficient large b
% 				b = abs(theta - 1);
% 				while(abs(1 - fapx(theta,beta,b)/func(theta,beta,b)) >= FERMITAU)
% 					b = 2*b;
% 				end
% 
% 				% now calc relativistic fermi integral
% 				Y = linspace(0,b,FERMIN);
% 
% 				% integrate first part up to Ymax=b numerically
% 				f1 = trapz(Y,Y.^4.*func(theta,beta,Y));
% 
% 				% and (very small) rest of integration analytically
% 				f2 = (1/4)*sqrt(2)*beta*(3*beta^2*sqrt(2)*b+sqrt(2)*b^3+3*beta^3+3*b^2*beta)*exp(-(b*sqrt(2)-1-theta)/beta);
% 
% 				% sum integral parts
% 				f(ii) = f1 + f2;
% 			end
% 		end
	end
end