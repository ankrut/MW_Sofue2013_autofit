function vm = estimateModelStruct(vm,TBL,kk)
% exclude model if exists with same particle mass
T0 = TBL.filter(@(t) t.model.param.m ~= vm.param.m);

if T0.length < 2
	error('not enough data points (n<2)');
end

% find the <kmax> closest solutions (at least 2, max kk)
kmax = min(kk,T0.length-1);
T0 = T0.map(@(t) t.model)...
	.sort(@(t) abs(round(log(t.param.m),12) - round(log(vm.param.m),12)) + abs(log(t.param.beta0) - log(vm.param.beta0)))...
	.pick(1:kmax);

% estimate model (polyfit)
vm = polyfitModelStruct(vm,T0);

function vm = polyfitModelStruct(vm,T)
M		= T.accumulate(@(t) t.param.m);
BETA0	= T.accumulate(@(t) t.param.beta0);
THETA0	= T.accumulate(@(t) t.param.theta0);
W0		= T.accumulate(@(t) t.param.W0);

% polynom degree (max 2)
nn = max(2,T.length-1);

p1 = polyfit(log(M),log(BETA0),nn);
p2 = polyfit(log(M),log(THETA0),nn);
p3 = polyfit(log(M),log(W0),nn);

vm.param.beta0	= exp(polyval(p1,log(vm.param.m)));
vm.param.theta0	= exp(polyval(p2,log(vm.param.m)));
vm.param.W0		= exp(polyval(p3,log(vm.param.m)));