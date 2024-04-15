# MMTIPS (Multiple Montage Temporal Interference Parameter Simulation)

Arthur: Yixuan Li (hyperdunk2019@mail.ustc.edu.cn)

## Goal

This toolbox aims to find the suitable montages which have a complementary effect. The suitable montages will be showed in montage_coupled.mat.

## Workflow

* main process

1. run generate_multi_cfg_at_one_time.m to generate a cfg.mat for each subject

2. run generate_multi_elec4_at_one_time.m to generate a elec4.mat for each subject

3. run my_main.m to generate montage_coupled.mat for each subject

* post process: run percentage.m to calculate percentage for group average
