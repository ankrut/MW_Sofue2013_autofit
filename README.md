# MW_Sofue2013_autofit
Milky Way data is fitted automatically by the RAR model fulfilling the constraints

1. Mc = 4.2E6 Msun (Gillessen et al. 2009)
2. M(12kpc) = 5.0E10 Msun (Sofue 2013)
3. M(40kpc) = 2.0E11 Msun (Gibbons et al. 2014)

These are consistent with

4. Mh = 1.75E11 Msun
5. rh = 2.53 kpc
6. M(50kpc) = 2.4E11 Msun

The core (e.g. Mc) is defined at the first maxima of the rotation curve. The halo (e.g. Mh and rh) is defined at the second maxima of the rotation curve.

## Install
Nothing special to do. Just clone or download the repository.

## Load data
````matlab
load('data/TBL_CORE_HALO.mat');
````
This will load all solutions (into variable *TBL_CORE_HALO*) with particle masses in the range 10 to 345 keV.

## Calculate solution
*TBL_CORE_HALO* is an array of the type module.array. Each element is a structure with the fields *model* and *chi2*. The field *model* has information about the parameter (field *param*) and options for the solution solver (field *options*). To calculate a solution use the code

```matlab
vm = TBL_CORE_HALO.data{1}.model;
p = model.tov.rar.quick(vm);
```
or as a list

```matlab
P = TBL_CORE_HALO.map(@(t) model.tov.rar.quick(t.model));
```

## Calculate density profile
First load the axis package for astronomical units (predifined)

```matlab
AXIS = lib.require(@model.tov.rar.axes.astro);
```

Then, the density for a solution *p* is given by 

```matlab
RHO = AXIS.density.model.map(p);
```

## Plot density profile
Load the figure for radius vs. density (predefined)

```matlab
figure(lib.require(@model.tov.rar.figure.astro.radius_density));
```

Plot a particular solution *p* with

```matlab
lib.view.plot.curve2D(p,AXIS.radius.model,AXIS.mass.model,'LineWidth',2);
```

or a list *P* with

```matlab
P.forEach(@(t) lib.view.plot.curve2D(t,AXIS.radius.model,AXIS.density.model));
```

## Parameter fitting
There are mainly three methods how to fit the RAR parameter:

1. Matlab's native nlinfit
2. golden section search
3. bisection search

Matlab's native nlinfit method is very powerful. It handles multiple constraints (response functions), can fit several parameter simutanously and converges also very fast to a minumum. However, the experience is that the provided responses (function handles) should not be too sensitive to a parameter change. But this is the case for strong evaporation (W0 small enough such that it affects the halo). Then little variations of beta0, theta0 or W0 cause huge changes to the halo. Also, the provided responses have to be well defined for all parameter values. Again, for very strong evaporation the definition of the halo may cause problems: W0 is so small that no defined halo (second maxima) is formed. Then, the response function would respond with a NaN what nlinfit cannot handle if it happens too often. Therefore, two more search methods are provided which can handle NaN much better. The golden section search which accept multiple constraints but fits only one parameter. The bisection search accepts only one constraints and fits also only one parameter. The convergence of the golden section search is a little bit worse than of the bisection search. In most cases, especially when the inital parameters are close to the solution, Matlab's nlinfit method is sufficient. But in some cases it may be trapped in a local minimum. Then it is possible to change the configurations for the nlinfit method or to try a combination of the provided search methods. The latter proved to be more robust, although much slower.

All methods require an initial model struct (usally labeled *vm*) and a configuration struct with information what and how to fit. There are two configurations struct already provided. One which focuses on the core and the halo (constraints 1,4 and 5). The other focuses on the observables (1,2 and 3) where the core mass is defined at the plateau (first minima of the mass derivitation curve). So, let's load the configurations via 

```matlab
CONFIGS = lib.require(@configs.fittingConfigs);
```

The variable *CONFFIGS* has to fields: *CoreHalo* and *PlateauHalo*. In following, the fitting methods will be domenstrated with the first *CoreHalo* configuration.

### Matlab's non-linear fitting (nlinfit)
Let's start with the simplest method: Matlab's nlinfit method. We don't call directly the nlinfit function. Instead, we call a wrapper because we work with the objects rather than with vectors and function handles. There are various predefined shorthand methods at *model.tov.rar.nlinfit*. Some of the shorthands focus only on the three configuration parameter (beta0, theta0, W0). But we need also the particle mass m. Therefore the appropiate wrappers are at *script.nlinfit*. Then, with the predefined configuration (*CONFIGS.CoreHalo*) and an initial model struct, e.g.

```matlab
% initial parameter for mc² = 10 keV (approx)
opts  = struct('xmin', 1E-7, 'xmax', 1E20, 'tau', 1E-16, 'rtau', 1E-4);
param = struct('m', 1.783e-32, 'beta0', 2.047057135387006e-07, 'theta0', 3.158325528289777e+01, 'W0', 5.857191547865187e+01);
vm    = struct('param', param, 'options', opts);
```

we fit the configuration parameter (for a given particle mass) via

```matlab
[p,vm] = script.nlinfit.beta0_theta0_W0(vm,CONFIGS.CoreHalo.list.main);
```

Here, *p* is the solution (class type *model.tov.rar.profile*) with all necessary data (radius, mass, ...) and *vm* is the compressed information (model struct) of the solution.

Sometimes, the convergence (and accuracy) improves by fitting the particle mass m, theta0 and W0 for a given beta0.  In this case we find the solution via 

```matlab
[p,vm] = model.tov.rar.nlinfit.m_theta0_W0(vm,CONFIGS.CoreHalo.list.main);
```

### Golden section search (gosect)
The syntax for the golden section search is analogue to the nlinfit method. Just keep in mind that this method can fit only one parameter. A typical application is to find the core first and then the halo. This is possible because W0 affects mainly the halo and has no effect on the core. In this case the core is mainly described through the particle mass, beta0 and theta0. For  given m and beta0 (and W0) we can first find the corresponding theta0 which fulfills the core constraint. Just take care to choose in this step a W0 value which does not affect the core (something like W0 = 200 should be fine in most cases). Then the solution is obtained via

```matlab
[p,vm] = script.gosect.theta0(vm,CONFIGS.CoreHalo.list.core);
```

The next step is to find the right halo (described mainly through W0) for a given core (described by m, beta0 and theta0 which was just fitted). So, something like

```matlab
[p,vm] = script.gosect.W0(vm,CONFIGS.CoreHalo.list.halo);
```

Of course, we have fitted the core and the halo seperately. There is no guarantee that all constraints are fulfilled now. This we can check through the chi-square value.

```matlab
chi2 = CONFIGS.CoreHalo.fChi2(p);
```

If the chi-square value *chi2* is not good enough, we simply have to vary the particle mass and/or beta0. Instead of fitting theta0 in the first step (core) it is possible to fit beta0 because the core mass depends only on the product beta0*theta0.


### Bisection search (bisect)
The syntax for the bisection search method is analogue to the others. It can fit only one parameter just like the golden section search. The difference is that this method can handle only one constraint. The convention is that the first element (response object) is chosen of the provided response list (e.g. *CONFIGS.CoreHalo.list.halo* is a response list with two elements). The two step strategy as described for the golden section search would be then 

```matlab
[p,vm] = script.bisect.theta0(vm,CONFIGS.CoreHalo.list.core);
[p,vm] = script.bisect.W0(vm,CONFIGS.CoreHalo.list.halo);
chi2 = CONFIGS.CoreHalo.fChi2(p);
```

Note, that only the path *script.gosect* has been changed to *script.bisect*.


### Search chain
For low evaporation (W0 does not or affect or affects only little the halo) Matlab's non-linear fitting method does a good job (either *script.nlinfit.beta0_theta0_W0* or *model.tov.rar.nlinfit.m_theta0_W0*). However, a more robust method (in particular for strong evaporation) proved to be a chain of search methods. The two step strategy (core-halo) with Matlab's non-linear fitting method would be 

```matlab
[p,vm] = script.nlinfit.beta0_theta0(vm,CONFIGS.CoreHalo.list.core);
[p,vm] = script.nlinfit.W0(vm,CONFIGS.CoreHalo.list.halo);
```

Note, that in the first step we may now fit beta0 and theta0 simutanously (for a given particle mass m and W0). The critical step is then to find the halo where *nlinfit* may cause problems because of NaN responses. This we can catch and try the golden section search instead 

```matlab
try
  [p,vm] = script.nlinfit.W0(vm,CONFIGS.CoreHalo.list.halo);
catch
  [p,vm] = script.gosect.W0(vm,CONFIGS.CoreHalo.list.halo);
end
```

But what if golden section search also fails? In this case we could build a nested try-catch construct. But more than two or three this will become very messy. Therefore there is an (experimental) function *script.findSolution* which tries different solution search methods (function handles) and returns a solution with sufficient or best accuracy (if succesful).

```matlab
% set solution functions
fHaloSolution = [
  @(vm) script.nlinfit.W0(vm,CONFIGS.CoreHalo.list.halo)
  @(vm) script.gosect.W0(vm,CONFIGS.CoreHalo.list.halo)
  @(vm) script.bisect.W0(vm,CONFIGS.CoreHalo.list.halo)
];

% find solution (with accuracy 1E-8)
[p,vm] = script.findSolution(vm,fHaloSolution,CONFIGS.CoreHalo.fChi2,1E-8);
```

This code will try the solution search methods in the same order and will stop once a method finds a solution above the demanded accuracy (e.g. 1E-8). A shorthand of the above code to find the halo is 

```matlab
[p,vm] = script.findHalo(vm,CONFIGS.CoreHalo);
```

Study the file *script.findHalo.m* for details. And modify if necessary for optimization.

Let's assume *script.findHalo* finds a solution. In sum, the two step approach is looks now like 

```matlab
[p,vm] = script.nlinfit.beta0_theta0(vm,CONFIGS.CoreHalo.list.core);
[p,vm] = script.findHalo(vm,CONFIGS.CoreHalo);
```

We simply exchanged *script.nlinfit.W0* by *script.findHalo*. Now, we still need manually to check if solution fulfilles all constraints (via *CONFIGS.CoreHalo.fChi2*). What usually happens with this strategy is that in the first step *nlinfit* finds a core with incredible accuracy (e.g. better than 1E-20!) but with a wrong theta0 such that it is impossible to fit the halo with W0. A solution would be to relax the first step and find the core for a given theta0.

```matlab
[p,vm] = script.nlinfit.beta0(vm,CONFIGS.CoreHalo.list.core);
[p,vm] = script.findHalo(vm,CONFIGS.CoreHalo);
```

In the case this strategy does not find a sufficient solution which fits core and halo we simply would need to choose another theta0. Manually! But we want the computer to do to work. Everything should be automatized. Another magic word here is *nested search*.

### Nested search
A search chain has the problem that at the end of the chain the solution does not fulfill necessary all constraints because at every step only a supset of the constraints is considered (e.g. core or halo). To understand the strategy think of the search chain backwards. The last step in the search chain strategy is to find the halo (W0) for given particle mass m, beta0 and theta0. Then after we found the halo we have to find the core by varying particle mass m, beta0 and/or theta0. Exactly this varying can be done through the given search methods. In other words, when we search for the core we have to make sure that in every step (!) the halo is fitted. This is done simply by overwriting the solution function (a function handle) of the *nlinfit* methods. The default solution function just calculates the profile, e.g. 

```matlab
fHaloSolution = @(vm) model.tov.rar.quick(vm);
```

But we need

```matlab
fHaloSolution = @(vm) script.findHalo(vm,CONFIGS.CoreHalo);
[p,vm] = script.nlinfit.beta0_theta0(vm,CONFIGS.CoreHalo.list.main,'fSolution', fHaloSolution);
```

Now, in every step of *script.nlinfit.beta0_theta0* the nlinfit wrapper calls the solution function *fHaloSolution* which searches for the halo (for given particle mass m, beta0 and theta0). This nested search strategy can be described with two layers. The first layer (main) searches for beta0 and theta0. In every step this layer passes the model struct (with modifed beta0 and theta0 only!) to the next layer (halo). The halo layer then searches for W0 and passes the result (solution with modified W0) back to the layer in the hierarchy (the main layer). The main layer updates the model struct (here, updates W0) and checks the chi-square value. Note that here the main layer now checks all constraints (*CONFIGS.CoreHalo.list.main*) instead of the core only (*CONFIGS.CoreHalo.list.core*). Based on all the response values and comparison with the predictions (e.g. chi-square) the nlinfit method (and any other search method) decides how to vary the parameter.

The nested search strategy proved to be very robust, especially for strong evaporation.

### Parameter estimation
Matlab's non-linear fitting method works the better the closer the initial model struct is to the solution. Therefore, a further optimization is to estimate the model struct (m, beta0, theta0, W0) before searching for the solution. Assume some solutions (model structs) for particle masses between 10 and 20 keV are already given as a list in the variable *TBL*. We want now to estimate the parameter (beta0, theta0, W0) mc² = 15 keV. We choose a model struct which is most close to 15 keV, update the particle mass to 15 keV and estimate the other parameter with a parabolic polynom,

```matlab
vm.param.m = 2.6745e-32 % in kg
vm = script.fixed_m.estimateModelStruct(vm,TBL,3);
```

The last argument (3) says that the three closest points (solutions) should be considers for the estimation. There is also an estimator for given beta0, e.g. 

```matlab
vm.param.beta0 = 1E-5;
vm = script.fixed_beta0.estimateModelStruct(vm,TBL,3);
```
