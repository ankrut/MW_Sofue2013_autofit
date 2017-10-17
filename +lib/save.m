% simplyfied version of Matlab's save method
% It automatically adds the '-struct' argument if the variable is a struct
function save(filename,elm,varargin)
if isstruct(elm)
	save(filename,'-struct','elm')
elseif isa(elm,'module.array')
	save_array(filename,elm,struct(varargin{:}));
else
	save(filename,'elm',varargin{:});
end

function save_array(filename,arr,options)
options
for ii=1:(options.chunksize):arr.length
	imax = min(ii+options.chunksize-1,arr.length);
	elm = arr.data(ii:imax);
	save([options.path num2str(ii) '-' num2str(imax) filename],'elm');
end