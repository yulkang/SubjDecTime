function name = getUserName ()
    if ismac()
        [~, name] = system('echo "$USER"'); % YK        
    elseif isunix() 
        name = getenv('USER'); 
    else 
        name = getenv('username'); 
    end
    
    name = remove_trailing_whitespace(name);
end