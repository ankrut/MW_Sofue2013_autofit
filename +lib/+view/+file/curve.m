function curve(filepath,P,AXES,varargin)
label = fieldnames(AXES);
symbol = module.array(struct2array(AXES)).map(@(t) t.mapmodel.var).data;
unit = module.array(struct2array(AXES)).map(@(t) regexprep(t.scalemodel.unit,'\\mathrm\{([\w\/]+)\}','$1')).data;
A = module.array(struct2array(AXES)).accumulate(@(t) t.map(P)');
formatSpecHeader = ['#%12s' repmat(' %12s',[1, numel(label)-1]) '\r\n'];
formatSpecData	 = [repmat(' %E',[1, numel(label)]) '\r\n'];

fh = fopen(filepath,'w');
fprintf(fh,formatSpecHeader,label{:});
fprintf(fh,formatSpecHeader,symbol{:});
fprintf(fh,formatSpecHeader,unit{:});
fprintf(fh,formatSpecData,A);
fclose(fh);