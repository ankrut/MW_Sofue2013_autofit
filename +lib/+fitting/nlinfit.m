% A wrapper for the built-in nlinfit function. It works with structs rather
% than with a list of arguments.
% COUPLINGS: lib.array, classes.ProfileMapping
function varargout = nlinfit(S,varargin)
	% load default values
	S = lib.struct.merge(struct(...
		'opts', statset('nlinfit'),...
		'dt',	3600 ...
	),S);

	% destructor
	fVector		= S.fVector;
	fModel		= S.fModel;
	fSolution	= S.fSolution;
	list		= S.list;
	opts		= S.opts;
	dt			= S.dt;		% max execution time in sec
	tt			= cputime;	% start timing;
	
	% init
	SOL			= fSolution(S.model);

	% wrap response function to wrap nlinfit vector into model (fVector),
	% pass through response list
	% and detect execution time limit
	function response_values = fResponseWrap(b,response_list)
		if cputime-tt > dt
			error('Execution time exceeded');
		end

		% calc solution
		MODEL	= fModel(b,SOL);
		SOL		= fSolution(MODEL);
		
		% calc response values
		response_values = response_list.accumulate(@(elm) elm.map(SOL))';
		
		if isfield(S,'debug')
			S.debug(MODEL,SOL,response_list);
		end
	end

	predictions = list.accumulate(@(elm) elm.prediction)';
	weights		= list.accumulate(@(elm) elm.weight)';

	[varargout{1:nargout}] = nlinfit(...
		list,...
		predictions,...
		@fResponseWrap,...
		fVector(SOL),...
		opts,...
		'Weight', weights,...
		varargin{:} ...
	);

	% wrap output (nlinfit vector > model > solution)
	varargout{1} = fSolution(fModel(varargout{1},SOL));
end