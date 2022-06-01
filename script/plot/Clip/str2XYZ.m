function [XYZmark,XYZvalue,dof] = str2XYZ(str)
% [XYZmark,XYZvalue] = str2XYZ(str)
% learn from plotmesh in iso2mesh
% written by Wei Zhang, 2021
if(ischar(str))
    if(~isempty(regexp(str,'[x-zX-Z]', 'once')) && ~isempty(regexp(str,'[=]', 'once')))
        expr=regexp(str,'(.+)=(.+)','tokens','once'); %regexp(str,'=','split');
        XYZvalue = str2double(expr{2});
        switch expr{1}
            case 'x'
                XYZmark = 1;
            case 'y'
                XYZmark = 2;
            case 'z'
                XYZmark = 3;
        end
    else
        error('not in a regular XYZ plane');
    end
else
    error('Input not in a regular string, like x = 0.');
end
dof = setdiff([1,2,3],XYZmark);


