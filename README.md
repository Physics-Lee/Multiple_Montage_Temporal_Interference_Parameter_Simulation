# MMTIPS (Multiple Montage Temporal Interference Parameter Simulation)

Arthur: Yixuan Li (hyperdunk2019@mail.ustc.edu.cn)

This toolbox aims to find the suitable montages which have a complementary effect. The suitable montages will be showed in montage_coupled.mat.

---

* main process

1. run generate_multi_cfg_at_one_time.m to generate a cfg.mat for each subject

2. run generate_multi_elec4_at_one_time.m to generate a elec4.mat for each subject

3. run my_main.m to generate montage_coupled.mat for each subject

* post process: run percentage.m to calculate percentage for group average

# TIPS(temporal interference parameter simulation)

Authors: Zhang Wei(weisheep@mail.ustc.edu.cn) and Ma Ru (maru@mail.ustc.edu.cn)

This toolbox aims at temporal interference simulation (TIS) optimization with GPU acceleration.   
It helps experimenter to evaluate the individual TIS stimulation parameters, including electrode position and current intensity.
The evaluation needs the T1 and T2 MRI structural image of the subject to build tetrahedron brain mesh.This step is rely on SIMNIBS pipeline. 
    https://simnibs.github.io/simnibs/build/html/documentation/command_line/headreco.html?highlight=headreco
TIPS is based on MATLAB and CUDA. 

****
Computer recommended configuration
Memory > 8G 
SSD >= 256G (for virtual memory)
Platform: windows 10
GPU: NVIDIA, support CUDA, memory > 4G 

****
Installation steps (on Windows 10):
1. Install MSVC 2017 or 2019, then run the following command in MATLAB.
```
mex -setup
```
2. Install latest cuda runtime, then run the following command in MATLAB.

```
gpuDevice
```
3. Install SIMNIBS and include its MATLAB functions path. 
4. Download this toolbox. 
5. Run _first_AddPath.m_ to add path to MATLAB.
6. Run _first_CompileCUDA.m_ to compile the cuda script into mexw64 file.
7. For each subject, you could follow [_headreco_](https://simnibs.github.io/simnibs/build/html/documentation/command_line/headreco.html?highlight=headreco) to build individual brain mesh. 
    (Or you could run "SIMNIBS_headreco.m".)
8. For each subject, you could follow [_leadfield_](https://simnibs.github.io/simnibs/build/html/documentation/sim_struct/tdcsleadfield.html#tdcsleadfield-doc) to get gray matter middle surface.
    (Or you could run "SIMNIBS_GMS.m".)
9. For each subject, you could follow [_leadfield_](https://simnibs.github.io/simnibs/build/html/documentation/sim_struct/tdcsleadfield.html#tdcsleadfield-doc) to get tetrahdron leadfield.
    (Or you could run "SIMNIBS_LF_tet.m".) 

   You could use _first_Prepare.m_ as example for subject _ernie_.
10. Run _TIPSconfig_GUI.mlapp.m_ to set the optimal parameters. (Or you could use _TIPSconfig.m_). The configurations are stored in the "cfg" variable.
11. Run _OpenTIPS_ in command line to optimal TIs parameters.

    Setting the _optimalMethod_ variable in _OpenTIPS.m_ to use Genetic algorithm for fast speed.

12. For 8 electrode (4 electrodes in each high frequency) in all montage, only Genetic algorithm is supported.

13. Run  _post_plot.m_ file to plot results.
****
Note:
1. Some plot demo functions are in the folder "ex_Figures".
2. The first time runing optimization for each subject needs more time to prepare input leadfield for GPU. The prepared single float format leadfield is stored under subject folder.
3. The _dataRoot_ variable is the root directory of all the subjects. _subMark_ variable is name or mark of a subject under root directory. The leadfield and orientation (optional) files are stored in the 'TI_sim_result' folder under each subject directory.
Each TIS optimal configuration and result is stored under the 'TI_sim_result' folder, with folder name _simMark_ variable.
****
Citation
1. [_SIMNIBS_](https://simnibs.github.io/simnibs/build/html/index.html)
Saturnino, G. B., Siebner, H. R., Thielscher, A., & Madsen, K. H. (2019). Accessibility of cortical regions to focal TES: Dependence on spatial position, safety, and practical constraints. NeuroImage, 203, 116183.
2. [_ACID_](http://www.diffusiontools.com/index.html)
Ruthotto L, Kugel H, Olesch J, Fischer B, Modersitzki J, Burger M, and Wolters C H. Diffeomorphic Susceptibility Artefact Correction of Diffusion-Weighted Magnetic Resonance Images.Physics in Medicine and Biology, 57(18), 5715-5731; 2012, doi: 10.1088/0031-9155/57/18/5715.
3. [_AAL3_](https://www.gin.cnrs.fr/en/tools/aal/)
Automated anatomical labelling atlas 3. Rolls, E. T., Huang, C. C., Lin, C. P., Feng, J., & Joliot, M., Neuroimage, 2020, 206, 116189, doi:10.1016/j.neuroimage.2019.116189
****

