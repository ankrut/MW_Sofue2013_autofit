function import_data
package = [
	struct('src', '../MW_Sofue2013_db_import/data/PROFILE_SOFUE2013.mat',	'dest', 'PROFILE_SOFUE2013.mat')
];

for ii=1:numel(package)
	copyfile(package(ii).src,['data/' package(ii).dest]);
	disp(package(ii).src);
end