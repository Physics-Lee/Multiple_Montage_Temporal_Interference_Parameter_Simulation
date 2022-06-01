function elecReplaceList = elecReplace(mut_elec_p,elecTemplate,n)
N = size(mut_elec_p,1);
elecReplaceList = int32(zeros(N,n));
for i = 1:N
    elecReplaceList(i,:) = randsample(elecTemplate(i,:),n,true,mut_elec_p(i,:));
end
end

