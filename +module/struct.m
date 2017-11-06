% a wrapper for the native struct function of matlab which can handle
% dublicate fieldnames by setting only the field with the last entry.
function s = struct(varargin)
s = struct();

for ii=1:2:nargin
	s.(varargin{ii}) = varargin{ii+1};
end