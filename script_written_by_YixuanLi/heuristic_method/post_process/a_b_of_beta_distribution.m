a_pre = zeros(1,25);
a_post = zeros(1,25);
b_pre = zeros(1,25);
b_post = zeros(1,25);
count = 1;
for i = 1:26
    % jump 11
    if i == 11
        continue;
    end
    
    % pre
    load(['E:\beta_distribution_pre_mat\beta_distribution_' num2str(i) '.mat']);
    a_pre(1,count) = beta_distribution.a;
    b_pre(1,count) = beta_distribution.b;
    
    % post
    load(['E:\beta_distribution_post_mat\beta_distribution_' num2str(i) '.mat']);
    a_post(1,count) = beta_distribution.a;
    b_post(1,count) = beta_distribution.b;
    
    % count
    count = count + 1;
end

a_subtraction = a_post - a_pre;
b_subtraction = b_post - b_pre;

save('E:\a_b\a_pre.mat','a_pre');
save('E:\a_b\a_post.mat','a_post');
save('E:\a_b\a_subtraction.mat','a_subtraction');
save('E:\a_b\b_pre.mat','b_pre');
save('E:\a_b\b_post.mat','b_post');
save('E:\a_b\b_subtraction.mat','b_subtraction');