function yaxis(AY,varargin)
if nargin == 2
	PROFILES = varargin{1};
else
	PROFILES = module.array();
end

ah = gca;
set(ah.YLabel,'Interpreter','latex');

if isfield(AY,'scale')
	set(ah,'YScale',AY.scale);
end

% set y lim
if isfield(AY,'clip')
	switch(class(AY.clip))
		case 'module.ProfileClip'
		case_profileclip(AY,PROFILES)
			
		case 'double'
		ylim(AY.clip)
	end
end

if(isfield(AY,'format'))
	lib.view.plot.ylabel(AY.model,AY.format);
else
	set(gca,'ylabel',[]);
end

% cache user data
ah.UserData.y = AY;

function case_profileclip(AY,PROFILES)
if PROFILES.length > 0
	lib.view.plot.ylim(PROFILES, AY.model, AY.clip);
end