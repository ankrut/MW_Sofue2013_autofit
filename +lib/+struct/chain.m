function s=chain(elm,varargin)
if nargin > 1
	s.(varargin{1}) = lib.struct_chain(elm,varargin{2:end});
else
	s  = elm;
end