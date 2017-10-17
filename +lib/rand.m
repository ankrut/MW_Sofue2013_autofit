function n=rand(a,b,varargin)
if nargin == 2
	n = a + (b-a)*rand;
else
	n = a + (b-a).*rand(varargin{1});
end