% REQUIERMENTS
%	module.tov
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
			W0		= obj.data.W0;
			BETA0	= obj.data.beta0;
			XMIN	= opts.xmin;
			XMAX	= opts.xmax;
			TAU		= opts.tau;		% absolute error for ode solver
			RTAU	= opts.rtau;	% relative error for ode solver
			
			tt = cputime;
			dt = 10; % sec;
			
			function [value,isterminal,direction] = fMaxExecutionTime()
				value		= dt - (cputime - tt);
				isterminal	= 1;
				direction	= 0;
			end
			
			function [value,isterminal,direction] = fEventNegative(x)
				value      = real(x);
				isterminal = 1;    % stop the integration
				direction  = -1;   % positive direction only
			end
			
			function [value,isterminal,direction] = fEvent(x)
				[value(1),isterminal(1),direction(1)] = fMaxExecutionTime();
				[value(2),isterminal(2),direction(2)] = fEventNegative(x);
			end
			
			% substitution
			ALPHA0	= 1 + THETA0*BETA0;
			EC0		= 1 + W0*BETA0;
			
			% define density and pressure function handles
			func_rho	= @(E,beta,alpha,ec) sqrt(E.^2 - 1).*E.^2.*(1 - exp((E - ec)./beta))./(exp((E - alpha)./beta) + 1);
			func_p		= @(E,beta,alpha,ec) (E.^2 - 1).^(3/2).*(1 - exp((E - ec)./beta))./(exp((E - alpha)./beta) + 1);
			frho		= @(r,nu) real(4/sqrt(pi)*model.tov.rar.integral.trapz(func_rho,BETA0*exp(-nu./2),ALPHA0*exp(-nu./2),EC0*exp(-nu./2),500));
			fp			= @(r,nu) real(4/3/sqrt(pi)*model.tov.rar.integral.trapz(func_p,BETA0*exp(-nu./2),ALPHA0*exp(-nu./2),EC0*exp(-nu./2),500));
			
			% set OPTIONS (for ODE solver)
			fevent	= @(r,y) fEvent(EC0*exp(-y(1)/2) - 1); % check cutoff condition
			options	= odeset('RelTol',RTAU,'AbsTol',TAU*[1 1],'Event',fevent);
			
			% call ode solver for theta(r)
			[R, NU, M] = module.tov.ode_solver_logeta(0,frho,fp,XMIN,XMAX,options);
			
			obj.data.radius			= R;
			obj.data.potential		= NU;
			obj.data.mass			= M;
			
			% cache time consuming magnitudes (often needed)
			obj.data.density		= frho(R,NU);
			obj.data.pressure		= fp(R,NU);
		end
	end
	
	
	% CORRESPONDING PROFILES ---------------------------------------------
	methods
		function p = get_vacuum(obj,XMAX)
			XMIN	= obj.data.radius(end);
			M0		= obj.data.mass(end);
			
			p = model.elementary.pointlike.profile(M0).set('radius', linspace(XMIN,XMAX));
		end
		
% % % 		% TODO (I need the relativistic version, Newtonian version does not work due to the beta0 parameter)
% % % 		function p=get_king(obj)
% % % 			% calc classic King profile
% % % 			% use the corresponding central degeneracy at the degeneracy
% % % 			% plateau (defined as first minima of rotation curve)
% % % 			% (this way it works amazingly good!)
% % % 			pnt		= lib.get_extrema(obj.data.radius,-obj.data.velocity,1);
% % % 			W0		= interp1(obj.data.radius,obj.data.cutoff,pnt,'spline');
% % % 			THETA0	= interp1(obj.data.radius,obj.data.degeneracy,pnt,'spline');
% % % 			p		= classes.profile.newton.rar.profile(W0,obj.data.radius(1),obj.data.radius(end),1E-6);
% % % 
% % % 			classes.profile.newton.rar.profile.fermionic_rescale(p,THETA0,W0);
% % % 		end
	end
end