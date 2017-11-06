% A wrapper for the built-in nlinfit function. It works with structs rather
% than with a list of arguments.
% COUPLINGS: module.array, module.struct, module.ProfileReponseList
function varargout = nlinfit(varargin)
	% contract arguments with default values if not set
	S = module.struct(...
		'options',	statset('nlinfit'),...
		varargin{:} ...
	);

	% destructor
	vm			= S.model;
	fResponse	= S.fResponse;
	fUpdate		= S.fUpdate;
	fModel		= S.fModel;
	fSolution	= S.fSolution;

	% response function hook
	function response_values = ResponseWrap(b,~)
		% update model
		vm	= fUpdate(b,vm);
		
		% calc solution
		SOL	= fSolution(vm);
		
		% update model for next iteration
		vm = fModel(SOL);
		
		% calc response values
		response_values = fResponse(SOL);
		
		if isfield(S,'fLog')
			S.fLog(SOL);
		end
	end

	% search for solution
	b = nlinfit(...
		[],...
		S.predictions,...
		@ResponseWrap,...
		S.fVector(vm),...
		S.options,...
		'Weight', S.weights ...
	);

	% set output
	varargout{1} = SOL;
	varargout{2} = fModel(SOL);
end