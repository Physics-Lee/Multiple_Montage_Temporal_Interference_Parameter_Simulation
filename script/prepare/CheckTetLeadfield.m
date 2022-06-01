function [status,tetLFFile] = CheckTetLeadfield(dataRoot,subMark,level)
tetMark = 'leadfield_tet';
tetLFFile = fullfile(dataRoot,subMark,tetMark,[subMark '_leadfield_EEG10-10_UI_Jurak_2007.hdf5']);
fileStr = 'tetrahedron leadfield';
%%
if exist(tetLFFile,'file')~=2
    switch level
        case 1
            status = false;
            disp(['The ' fileStr ' file does not exist.']);
        case 2
            app = TetLeadfieldQuery_GUI;
            uiwait(app.UIFigure);
            action = evalin('base', 'action');
            if action
                try
                    SIMNIBS_LF_tet(dataRoot,subMark);
                    status = true;
                    disp(['The ' fileStr ' file is created now!']);
                catch
                    disp(['The ' fileStr ' file creation failed!']);
                    status = false;
                end
            else
                disp(['Not to create the ' fileStr ' file.']);
            end
    end
else
    status = true;
    disp(['The ' fileStr ' has already existed.']);
end
end


