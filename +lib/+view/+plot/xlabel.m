function t=xlabel(axis,format)
t=xlabel(sprintf(format,axis.mapmodel.var,axis.scalemodel.unit));