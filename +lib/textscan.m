function DATA=textscan(FILEPATH,FORMAT_SPEC,varargin)
	fid = fopen(FILEPATH,'r');
	DATA = cell2struct(...
			textscan(fid,[FORMAT_SPEC{:,2}],varargin{:}),...
			FORMAT_SPEC(:,1), 2);
	fclose(fid);
end