# MMTIPS (Multiple Montage Temporal Interference Parameter Simulation)

Arthur: Yixuan Li (hyperdunk2019@mail.ustc.edu.cn), Zhang Wei(weisheep@mail.ustc.edu.cn).

Check the pdf document of this repository [here](https://bruce-yixuan-li.github.io/2022/06/01/Bachelor_Thesis/).

## Goal

This toolbox aims to find the suitable montages which have a complementary effect. The suitable montages will be showed in montage_coupled.mat.

## Result

<img src="https://github.com/Physics-Lee/Multiple_Montage_Temporal_Interference_Parameter_Simulation/assets/68525696/1bdeea55-ffd5-445d-931f-1940bfb2f7ed" width="418" height="682">

The circle indicates the ROI. A: sagittal plane, B: coronal plane, C: horizontal plane. Pre means the first montage of the original ranking. Post means 10 montages together. The blue area represents E < 0.2 V/m while the red area represents E > 0.2 V/m.

## Workflow

* main process

1. run generate_multi_cfg_at_one_time.m to generate a cfg.mat for each subject

2. run generate_multi_elec4_at_one_time.m to generate a elec4.mat for each subject

3. run my_main.m to generate montage_coupled.mat for each subject

* post process: run percentage.m to calculate percentage for group average
