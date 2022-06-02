load('E:\beta_distribution\a_b\a_pre.mat','a_pre');
load('E:\beta_distribution\a_b\a_post.mat','a_post');
load('E:\beta_distribution\a_b\b_pre.mat','b_pre');
load('E:\beta_distribution\a_b\b_post.mat','b_post');

x = 1:25;
[h_a,p_a] = ttest(a_pre,a_post);
[h_b,p_b] = ttest(b_pre,b_post);

figure(1)
scatter(x,a_pre,50,'filled','blue','o');
hold on;
scatter(x,a_post,50,'filled','red','o');
xlabel('subject number');
ylabel('a');
legend('a pre','a post');
title('若假定a服从均值等于零且方差未知的正态分布，则p值为',p_a);
Q
figure(2)
scatter(x,b_pre,50,'filled','blue','o');
hold on;
scatter(x,b_post,50,'filled','red','o');
xlabel('subject number');
ylabel('b');
legend('b pre','b post');
title('若假定b服从均值等于零且方差未知的正态分布，则p值为',p_b);