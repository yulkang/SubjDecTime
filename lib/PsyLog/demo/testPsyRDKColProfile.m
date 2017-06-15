for ii = 1:nRep
    get(Mouse);
    
    update(Cursor);
    update(RDKCol);
    
    draw(Cursor);
%     draw(RDKCol);
    
    flip(Scr);
end
