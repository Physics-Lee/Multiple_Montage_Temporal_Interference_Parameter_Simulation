function [GMstatus,WMstatus] = CheckOrientation(dataRoot,subMark,level)
orientationMark = 'orientation';
GMntFile = fullfile(dataRoot,subMark,orientationMark,'nt_elem_GM.mat');
WMntFile = fullfile(dataRoot,subMark,orientationMark,'nt_elem_WM.mat');
GMfileStr = 'GRAY matter orientation';
WMfileStr = 'WHITE matter orientation';
%%
switch level
    case 1
        if exist(GMntFile,'file')~=2
            GMstatus = false;
            disp(['The ' GMfileStr ' file does not exist.']);
        else
            GMstatus = true;
            disp(['The ' GMfileStr ' has already existed.']);
        end
        if exist(WMntFile,'file')~=2
            WMstatus = false;
            disp(['The ' WMfileStr ' file does not exist.']);
        else
            WMstatus = true;
            disp(['The ' WMfileStr ' has already existed.']);
        end
    case 2
        %% GM
        if exist(GMntFile,'file')~=2
            app = GMntQuery_GUI;
            uiwait(app.UIFigure);
            action = evalin('base', 'action');
            if action
                try
                    GMNT(dataRoot,subMark);
                    disp(['The ' GMfileStr ' file is created now!']);
                    GMstatus = true;
                catch
                    disp(['The ' GMfileStr ' file creation failed!']);
                    GMstatus = false;
                end
            else
                GMstatus = false;
                disp(['Not to create the ' GMfileStr ' file.']);
            end
        else
            GMstatus = true;
            disp(['The ' GMfileStr ' has already existed.']);
        end
        %% WM
        if exist(WMntFile,'file')~=2
            app = WMntQuery_GUI;
            uiwait(app.UIFigure);
            action = evalin('base', 'action');
            switch action
                case 1
                    try
                        WMNT(app.mainApp.dataRoot,app.mainApp.subMark,1);
                        disp(['The ' WMfileStr ' file is created now!']);
                        WMstatus = true;
                    catch
                        disp(['The ' WMfileStr ' file creation failed!']);
                        WMstatus = false;
                    end
                case 2
                    try
                        WMNT(app.mainApp.dataRoot,app.mainApp.subMark,2);
                        disp(['The ' WMfileStr ' file is created now!']);
                        WMstatus = true;
                    catch
                        disp(['The ' WMfileStr ' file creation failed!']);
                        WMstatus = false;
                    end
                case 0
                    WMstatus = false;
                    disp(['Not to create the ' WMfileStr ' file.']);
            end
            
        else
            WMstatus = true;
            disp(['The ' WMfileStr ' has already existed.']);
        end
end
end


