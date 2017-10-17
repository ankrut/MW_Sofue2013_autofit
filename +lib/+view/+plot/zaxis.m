function zaxis(AZ,varargin)
if nargin == 2
	PROFILES = varargin{1};
else
	PROFILES = module.array();
end

ah = gca;
set(ah.ZLabel,'Interpreter','latex');

if isfield(AZ,'scale')
	set(ah,'ZScale',AZ.scale);
end

% set xlim
if isfield(AZ,'clip')
	switch(class(AZ.clip))
		case 'module.ProfileClip'
		case_profileclip(AZ,PROFILES)
			
		case 'double'
		zlim(AZ.clip)
	end
end

% set labels
if(isfield(AZ,'format'))
	lib.view.plot.zlabel(AZ.model,AZ.format);
else
	set(gca,'zlabel',[]);
end

% cache user data
ah.UserData.z = AZ;

function case_profileclip(AZ,PROFILES)
if PROFILES.length > 0
	lib.view.plot.zlim(PROFILES, AZ.model, AZ.clip);
end
	