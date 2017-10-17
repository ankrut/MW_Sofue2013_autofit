function t=ylabel(axis,format)
t=ylabel(sprintf(format,axis.mapmodel.var,axis.scalemodel.unit));