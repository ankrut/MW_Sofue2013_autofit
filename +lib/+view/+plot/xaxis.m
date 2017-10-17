function xaxis(AX,varargin)
if nargin == 2
	PROFILES = varargin{1};
else
	PROFILES = module.array();
end

ah = gca;
set(ah.XLabel,'Interpreter','latex');

if isfield(AX,'scale')
	set(ah,'XScale',AX.scale);
end

% set xlim
if isfield(AX,'clip')
	switch(class(AX.clip))
		case 'module.ProfileClip'
		case_profileclip(AX,PROFILES)
			
		case 'double'
		xlim(AX.clip)
	end
end

% set labels
if(isfield(AX,'format'))
	lib.view.plot.xlabel(AX.model,AX.format);
else
	set(gca,'xlabel',[]);
end

% cache user data
ah.UserData.x = AX;

function case_profileclip(AX,PROFILES)
if PROFILES.length > 0
	lib.view.plot.xlim(PROFILES, AX.model, AX.clip);
end
	