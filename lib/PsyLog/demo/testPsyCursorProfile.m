% testPsyCursorProfile

nRep = 299;
for ii = 1:nRep
    get(Mouse);
    update(Cursor);
    
    add(Cursor.log);
    draw(Cursor);
    flip(Scr);
end

