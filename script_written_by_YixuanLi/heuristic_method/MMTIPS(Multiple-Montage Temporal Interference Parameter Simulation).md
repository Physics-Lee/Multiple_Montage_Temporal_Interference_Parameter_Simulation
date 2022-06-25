MMTIPS(Multiple-Montage Temporal Interference Parameter Simulation)

main process

1. run generate_multi_cfg_at_one_time.m to generate a cfg.mat for each subject

2. run generate_multi_elec4_at_one_time.m to generate a elec4.mat for each subject

3. run my_main.m to generate montage_coupled.mat for each subject

post process

1. quantitative: run post_process_percentage.m to calculate percentage for group average
2. quantitative: run post_process_hist.m to calculate histogram for group average
3. qualitative: run plot_slice to draw hot graph of each subject

