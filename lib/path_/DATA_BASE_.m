function res = DATA_BASE_(ptn_code, ptn_data)
% Find out data base pattern from CODE_BASE_

persistent data_base
if isempty(data_base)
    if nargin == 0, ptn_code = '/Code/'; end
    if nargin <  2, ptn_data = '/Data/'; end
    
    code_base = [CODE_BASE_, filesep];
    
    data_base = strrep(code_base, ptn_code, ptn_data);
    
    data_base = data_base(1:(end-1));
end

res = data_base;
end