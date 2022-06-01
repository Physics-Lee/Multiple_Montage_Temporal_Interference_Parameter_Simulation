function hdf5 = upload_hdf5(cfg)
dataRoot = cfg.dataRoot;
subMark = cfg.subMark;
hdf5_directory = [fullfile(dataRoot,subMark,'leadfield_tet\') subMark '_leadfield_EEG10-10_UI_Jurak_2007.hdf5'];
hdf5 = mesh_load_hdf5(hdf5_directory); % load hdf5
end