function s1=merge(s1,s2)       
list = fieldnames(s2);

for ii=1:numel(list)
	key = list{ii};

	if isfield(s1,key) && isstruct(s1.(key)) && isstruct(s2.(key))
		s1.(key) = lib.struct.merge(s1.(key),s2.(key));
	else
		s1.(key) = s2.(key);
	end
end

	