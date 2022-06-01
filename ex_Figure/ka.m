delete(findall(gcf,'Type','light'))
lighting gouraud;
if ~iscell(hlink)
    for i = 1:length(hlink.Targets)
        material(hlink.Targets(i),'dull');
        camlight(hlink.Targets(i),'headlight');
    end
else
    for i = 1:length(hlink{1}.Targets)
        material(hlink{1}.Targets(i),'dull');
        camlight(hlink{1}.Targets(i),'headlight');
    end
end
