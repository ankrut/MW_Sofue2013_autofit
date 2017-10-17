function arr = arrayfun_wb(func,PARAMSET)
h = waitbar(0);
N = length(PARAMSET);
for ii=1:N
	arr(ii) = func(PARAMSET(ii));
	waitbar(ii/N,h);
end

if(N==0)	
	arr = [];
end
close(h);