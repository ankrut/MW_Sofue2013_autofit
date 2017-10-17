# MW_Sofue2013_autofit
Milky Way rotation curve data (Sofue 2013) is fitted automatically by the RAR model for given particle mass.

The constraints are 

1. Mc = 4.2E6 Msun
2. Mh = 1.75E11 Msun
3. rh = 2.53 kpc
4. M(12kpc) = 5.0E10 Msun
5. M(50kpc) = 2.3E11 Msun

## load data
````matlab
load('data/TBL.mat');
````
This will load the solutions (variable *TBL*) with particle masses in the range 10 to 60 keV.

## calculate solution
*TBL* is an array of the type module.array. Each element is a structure with the fields *model* and *chi2*. The field *model* has information about the parameter (field *param*) and options for the solution solver (field *options*). To calculate a solution use the code

```matlab
vm = TBL.data{1}.model;
p = model.tov.rar.quick(vm);
```
or as a list

```matlab
P = TBL.map(@(t) model.tov.rar.quick(t.model));
```

## calculate density profile
First load the axis package for astronomical units (predifined)

```matlab
AXIS = lib.require(@model.tov.rar.axes.astro);
```

Then, the density for a solution *p* is given by 

```matlab
RHO = AXIS.density.model.map(p);
```
