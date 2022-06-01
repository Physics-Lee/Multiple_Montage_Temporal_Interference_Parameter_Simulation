function conduct=mat_conduct_simnibs(elem5)
% conduct=mat_conduct_simnibs(tetrahedron_regions)
% define the conduct of head from simNIBS mesh
% code by Z.W.
conduct=zeros(size(elem5,1),1);
conduct(elem5>=5)=0.465;%scalp
conduct(elem5==4)=0.01;%skull
conduct(elem5==3)=1.654;%csf
conduct(elem5==1)=0.126;%wm
conduct(elem5==2)=0.275;%gm