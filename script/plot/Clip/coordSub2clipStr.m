function clipStr = coordSub2clipStr(coord)
clipStr = cell(3,1);
for i = 1:3
    clipStrPost = num2str(round(coord(i)));
    switch i
        case 1
            clipStrPre = 'x=';
        case 2
            clipStrPre = 'y=';
        case 3
            clipStrPre = 'z=';
    end
    clipStr{i} = [clipStrPre clipStrPost];
end

