function thename = name4diary(path4save)
% 按照当前时刻为 diary文件生成名字，避免后来的文件把之前的覆盖
start = datestr(now);
m_time = datevec(start);
n_time1 = m_time(1).*10000 + m_time(2).*100 + m_time(3);
n_time2 = m_time(4).*10000 + m_time(5).*100 + m_time(6);
s_time1 = num2str(n_time1);
s_time2 = num2str(n_time2);
thename = fullfile(path4save,['log_' s_time1 '_' s_time2 '.txt']);