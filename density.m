load('data\TBL_MW_10_350.mat');
AXIS = lib.require(@model.tov.rar.axes.astro);

figure_density = lib.require(@model.tov.rar.figure.astro.radius_density);
figure(figure_density);

P = TBL.pick(1:20:161).map(@(t) model.tov.rar.quick(t.model));
P.forEach(@(t) lib.view.plot.curve2D(t,AXIS.radius.model,AXIS.density.model));

xlim([1E-10,1E6]);
lib.view.file.figure(figure_density,'data/mw');

