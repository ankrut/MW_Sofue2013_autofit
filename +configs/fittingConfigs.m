list = lib.require(@configs.constraint_list);

EXPORT.CoreHalo.list.main		= list.core_halo;
EXPORT.CoreHalo.list.core		= list.core;
EXPORT.CoreHalo.list.halo		= list.halo;
EXPORT.CoreHalo.fChi2			= @(SOL) list.core_halo.chi2(SOL);
EXPORT.CoreHalo.tau				= 1E-10;

EXPORT.PlateauHalo.list.main	= list.data;
EXPORT.PlateauHalo.list.core	= list.data.pick(1);
EXPORT.PlateauHalo.list.halo	= list.data.pick([3,2]);
EXPORT.PlateauHalo.fChi2		= @(SOL) list.data.chi2(SOL);
EXPORT.PlateauHalo.tau			= 1E-10;