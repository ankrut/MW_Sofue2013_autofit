function str=sprintf(formatSpec,varargin)
str = sprintf(lib.escape(formatSpec),varargin{:});

% EXPERIMENTAL !!!
% replace E+x by \times 10^{xx}
% str = regexprep(str, '[eE]([+-])0*(\d+)', '\\times 10^{$1$2}');