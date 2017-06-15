function reorder(h, opOrig)
% REORDER Reorder objects in an axes object.
%
% reorder(h, 'top');
% reorder(h, 'bottom');

if iscell(opOrig)
    op = opOrig;
elseif ischar(opOrig)
    op = repmat({opOrig}, [1, length(h)]);
else
    error('op should be either char or cell!');
end

for ii  = 1:length(h)
    cH  = h(ii);
    cOp = op{ii};
    
    cParent = get(cH, 'Parent');
    cChild  = get(cParent, 'Children');
    
    switch cOp
        case 'top'
            resH = [cH; cChild(cChild~=cH)];
            
        case 'bottom'
            resH = [cChild(cChild~=cH); cH];
    end
    
    set(gca, 'Children', resH);
end