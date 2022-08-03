% sum across different dimensions and then squeeze results
% useful for collapsing dimensions of images

function o = sumch(i,d)
    o = i;
    
    for di=1:length(d)
        o = sum(o,d(di));
    end
    
    o = squeeze(o);