function EXPORT_MERGE=require(varargin)
if nargin == 1
	varargin{1}()
	EXPORT_MERGE = EXPORT;
else
	EXPORT_MERGE = struct();
	for ii = 1:nargin
		varargin{ii}();
		EXPORT_MERGE = lib.struct.merge(EXPORT_MERGE,EXPORT);
	end
end
