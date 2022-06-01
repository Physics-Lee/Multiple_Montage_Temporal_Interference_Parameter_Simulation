function  showTR(TR,varargin)
%%
default_facecolor = [1,1,1];
default_edgecolor = [.12,.56,.7];
%% input
p = inputParser;
addRequired(p,'TR',@(x)isa(x,'triangulation'));
attributes = {'ncols',3};
validColor = @(x) validateattributes(x,{'numeric'},attributes);
addParameter(p,'facecolor',default_facecolor,validColor);
addParameter(p,'edgecolor',default_edgecolor,validColor);
addParameter(p,'limit',[],@(x)ischar(x)&&~isempty(regexp(x,'[x-zX-Z]', 'once')) && ~isempty(regexp(x,'[><=&|]', 'once')));
parse(p,TR,varargin{:})

%%
node = TR.Points;
face = TR.ConnectivityList;
edgecolor = p.Results.edgecolor;
facecolor = p.Results.facecolor;
%%
if ~isempty(p.Results.limit)
    limit = p.Results.limit;
    x = node(:,1);
    y = node(:,2);
    z = node(:,3);
%     c = str2sym(limit)
    idx=eval(['find(' limit ')']);
    face_idx = any(ismember(face,idx),2);
    face = face(face_idx,:);  
end
%% plot
trimesh(face,node(:,1),node(:,2),node(:,3),'EdgeColor',edgecolor,...
    'FaceColor', facecolor,'FaceAlpha',1);
rotate3d;
axis equal;
% axis manual;
grid off;
box on;
xlabel('X');
ylabel('Y');
zlabel('Z');
set(gcf,'units','normalized','outerposition',[0 0 1 1])
end

% range = [min(node(:,1)),min(node(:,2)),min(node(:,3));
%     max(node(:,1)),max(node(:,2)),max(node(:,3))];





