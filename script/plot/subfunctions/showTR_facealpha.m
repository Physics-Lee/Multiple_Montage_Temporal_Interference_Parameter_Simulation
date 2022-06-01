function  showTR_facealpha(TR,TR_ROI,Color,varargin)
% 可以设置透明度的showTR函数

%%
default_facecolor = [1,1,1];
% default_edgecolor = [.12,.56,.7];
%% input
p = inputParser;
addRequired(p,'TR',@(x)isa(x,'triangulation'));
attributes = {'ncols',3};
validColor = @(x) validateattributes(x,{'numeric'},attributes);
addParameter(p,'facecolor',default_facecolor,validColor);
% addParameter(p,'edgecolor',default_edgecolor,validColor);
addParameter(p,'Parent',gcf);
addParameter(p,'limit',[],@(x)ischar(x)&&~isempty(regexp(x,'[x-zX-Z]', 'once')) && ~isempty(regexp(x,'[><=&|]', 'once')));
parse(p,TR,varargin{:})

%%
node = TR.Points;
face = TR.ConnectivityList;
node_ROI = TR_ROI.Points;
face_ROI = TR_ROI.ConnectivityList;
% edgecolor = p.Results.edgecolor;
facecolor = p.Results.facecolor;
%%
if ~isempty(p.Results.limit)
    limit = p.Results.limit;
    x_ROI = node_ROI(:,1);
    y_ROI = node_ROI(:,2);
    z_ROI = node_ROI(:,3);
    x = node(:,1);
    y = node(:,2);
    z = node(:,3);
%     c = str2sym(limit)
    idx=eval(['find(' limit ')']);
    face_idx = any(ismember(face,idx),2);
    face = face(face_idx,:);  
    face_ROI = face_ROI(face_idx,:); 
end
%% plot
trimesh(face,node(:,1),node(:,2),node(:,3),'EdgeColor','none',...
    'FaceColor', [130/255 130/255 130/255],'FaceAlpha',0.05);
hold on
trimesh(face_ROI,node_ROI(:,1),node_ROI(:,2),node_ROI(:,3),'EdgeColor','none',...
    'FaceColor', Color/255,'FaceAlpha',1);
rotate3d;
axis equal;
% axis manual;
grid off;
axis off;
% box on;
% xlabel('X');
% ylabel('Y');
% zlabel('Z');
% set(gcf,'units','normalized','outerposition',[0 0 1 1])
end

% range = [min(node(:,1)),min(node(:,2)),min(node(:,3));
%     max(node(:,1)),max(node(:,2)),max(node(:,3))];





