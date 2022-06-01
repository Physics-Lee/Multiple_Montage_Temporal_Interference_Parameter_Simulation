function SIMNIBS_GMS(dataRoot,subMark)
tdcs_lf = sim_struct('TDCSLEADFIELD');
% Head mesh
tdcs_lf.fnamehead = fullfile(dataRoot,subMark,[subMark '.msh']);
% Output directory
tdcs_lf.pathfem = fullfile(dataRoot,subMark,'leadfield');
run_simnibs(tdcs_lf)
