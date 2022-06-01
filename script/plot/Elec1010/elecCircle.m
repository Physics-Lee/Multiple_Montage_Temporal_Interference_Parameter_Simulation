function elecCircle(Pos,Label,r,edgecolor,facecolor,linewidth,FontSize,curvature)
% 画圆函数,可以根据输入同时画N个半径等具体参数相同的圆
% 输入：Pos N*2 double，圆心的平面坐标[x,y]的位置
%       Label N*1 cell，圆内居中的label，可用来标记电极名称，可以为空
%       r 1*1 double，圆的半径
%       edgecolor RGB颜色，圆形的边线颜色
%       facecolor RGB颜色，圆形的填充颜色
%       linewidth 1*1 double，圆形的边线线宽
%       FontSize 1*1 double，标签的字号，如果有的话
rectangle('position',[Pos(1)-r,Pos(2)-r,r*2,r*2],'curvature',curvature,...
    'edgecolor',edgecolor,'facecolor',facecolor,'LineWidth',linewidth);
if ~isempty(Label)
    text(Pos(1),Pos(2),Label,'FontSize',FontSize,'HorizontalAlignment','center');
end

