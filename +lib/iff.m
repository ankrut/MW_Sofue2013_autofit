function result = iff(condition,trueResult,falseResult)
if condition
	if(lib.isfunc(trueResult))
		result = trueResult();
	else
		result = trueResult;
	end
else
	if(lib.isfunc(falseResult))
		result = falseResult();
	else
		result = falseResult;
	end
end