function C = csprintf2(fmt, varargin)
% Similar to csprintf but arguments are replicated both in row and column.
%
% C = csprintf2(fmt, args)
%
% EXAMPLE:
% >> csprintf2('%s_%d_%d', {'AA'}, (1:3)', (1:2))
% ans = 
%     'AA_1_1'    'AA_1_2'
%     'AA_2_1'    'AA_2_2'
%     'AA_3_1'    'AA_3_2'
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

narg = length(varargin);

siz = [1 1];
for iarg = 1:narg
    siz = max(siz, size(varargin{iarg}));
end

for iarg = 1:narg
    varargin{iarg} = rep2fit(varargin{iarg}, siz);
end

C = cell(siz);

for ii = 1:siz(1)
    for jj = 1:siz(2)
        cargs = cell(1,narg);
        for iarg = 1:narg
            if iscell(varargin{iarg})
                cargs{iarg} = varargin{iarg}{ii,jj};
            else
                cargs{iarg} = varargin{iarg}(ii,jj);
            end
        end
        
        C{ii,jj} = sprintf(fmt, cargs{:});
    end
end