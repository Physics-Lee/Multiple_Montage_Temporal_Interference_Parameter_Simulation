function SIMNIBS_LF_tet(dataRoot,subMark)
tdcs_lf = sim_struct('TDCSLEADFIELD');
% Head mesh
tdcs_lf.fnamehead = fullfile(dataRoot,subMark,[subMark '.msh']);
% Output directory
tdcs_lf.pathfem = fullfile(dataRoot,subMark,'leadfield_tet');
tdcs_lf.map_to_surf = false;
tdcs_lf.tissues = 1:6;
run_simnibs(tdcs_lf);
end
