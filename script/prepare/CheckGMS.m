function [status,GMSFile] = CheckGMS(dataRoot,subMark,level)
GMSMark = 'leadfield';
GMSFile = fullfile(dataRoot,subMark,GMSMark,[subMark '_leadfield_EEG10-10_UI_Jurak_2007.hdf5']);
fileStr = 'gray matter middle surface';
%% questdlg
if exist(GMSFile,'file')~=2
    switch level
        case 1
            status = false;
            disp(['The ' fileStr ' file does not exist.']);
        case 2
            app = GMSQuery_GUI;
            uiwait(app.UIFigure);
            action = evalin('base', 'action');
            if action
                try
                    SIMNIBS_GMS(dataRoot,subMark);
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

