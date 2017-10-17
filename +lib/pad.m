function str=pad(str,n)
if numel(str < n)
	str = [str repmat(' ',1,n - numel(str))];
end