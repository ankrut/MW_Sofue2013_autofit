function figure(FIGURE,PREFIX,varargin)
mime = lib.iff(isempty(varargin), 'pdf', @() varargin{1});
saveas(FIGURE,[PREFIX '-' FIGURE.FileName '.' mime]);