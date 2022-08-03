function xls = ind2xls(idx)

        idx1 = char('`'+mod(idx-1,26)+1);
        if ceil(idx/26)-1~=0,
            idx2 = char('`'+ceil((idx)/26)-1);
        else
            idx2 = '';
        end
           
        xls = [idx2 idx1];