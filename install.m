function install
mkdir('+configs')
mkdir('+view')
mkdir('export')
mkdir('data')

install_modules
install_models
install_lib


function install_modules
path = 'D:/Documents/PhD/code/modules/';

copy(path,'+module/',[
	struct('src', 'number/*.m',					'dest', '')
	struct('src', 'array/*.m',					'dest', '')
	struct('src', 'ProfileData/*.m',			'dest', '')
	struct('src', 'ProfileAxis/*.m',			'dest', '')
	struct('src', 'ProfileAnchor/*.m',			'dest', '')
	struct('src', 'ProfileClip/*.m',			'dest', '')
	struct('src', 'ProfileMapping/*.m',			'dest', '')
	struct('src', 'ProfileScaling/*.m',			'dest', '')
	struct('src', 'tov/*.m',					'dest', '')
	struct('src', 'constraints/*.m',			'dest', '')
	struct('src', 'Sofue2013/*.m',				'dest', '')
	struct('src', 'ProfileObservation/*.m',		'dest', '')
	struct('src', 'ProfileResponse/*.m',		'dest', '')
]);

function install_models
path = 'D:/Documents/PhD/code/models/';

copy(path,'+model/',[
	struct('src', '+clip/*.m',				'dest', '+clip/')
	struct('src', '+tov/*.m',				'dest', '+tov/')
	struct('src', '+tov/+fd/*',				'dest', '+tov/+fd/')
	struct('src', '+tov/+rar/*',			'dest', '+tov/+rar/')
]);

function install_lib
path = 'D:/Documents/PhD/code/lib/';

copy(path,'+lib/',[
	struct('src', '*.m',				'dest', '')
	struct('src', '+struct/*.m',		'dest', '+struct/')
	struct('src', '+fitting/*.m',		'dest', '+fitting/')
	struct('src', '+color/*.m',			'dest', '+color/')
	struct('src', '+view/+file/*.m',	'dest', '+view/+file/')
	struct('src', '+view/+plot/*.m',	'dest', '+view/+plot/')
]);

function copy(path_src,path_dest,list)
for ii=1:numel(list)
	copyfile([path_src list(ii).src],[path_dest list(ii).dest]);
	disp([path_src list(ii).src]);
end