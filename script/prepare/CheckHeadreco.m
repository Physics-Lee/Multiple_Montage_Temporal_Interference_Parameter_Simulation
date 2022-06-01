function [status,headMeshFile] = CheckHeadreco(dataRoot,subMark,level)
headMeshFile = fullfile(dataRoot,subMark,[subMark '.msh']);
fileStr = 'head mesh';
%%
if exist(headMeshFile,'file')~=2
    switch level
        case 1
            status = false;
            disp(['The ' fileStr ' file does not exist.']);
        case 2
            app = HeadrecoQuery_GUI;
            uiwait(app.UIFigure);
            action = evalin('base', 'action');
            if action
                try
                    SIMNIBS_headreco(dataRoot,subMark);
                    disp(['The ' fileStr ' file is created now!']);
                    status = true;
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

