TI仿真计算的GUI界面

OpenTIPS是主界面
Dialog_ROI和Dialog_Penalty分别是ROI和Penalty参数设置界面

目前三个界面间的通信在常规操作下是可以进行的，还没有系统的进行错误操作的debug和提示

主界面数据输入路径相当于[dataRoot subMark]
输出路径相当于 workSpace

计算方法 “快速”对应 tri数据；“精确”对应tet数据

未完成部分
“模型建立”：从T1 T2数据到头模型或者leadfield
“开始计算”：生成cfg数据run main函数
右侧的绘图框计划是每添加一行参数，显示当前定义的ROI和Penalty区域