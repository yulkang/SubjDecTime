function bootstat = bootstrp_group(n_boot, bootfun, args, group, varargin)
% bootstat = bootstrp_group(n_boot, bootfun, args, group, varargin)
%
% args  : Cell array of arguments for bootfun
% group : Numerical vector of group number in 0:n_args. 
% Arguments in the same group are resampled together,
% while arguments in different groups are resampled independently.
% If group(k) == 0, k-th element is always used as is without resampling.
%
% OPTIONS:
% 'UseParallel', true
% 'boot_tr', {} % {group}(row, i_boot) = row0 or just (row, i_boot)
%
% EXAMPLE:
% >> bml.stat.bootstrp_group(3, @(v1, v2) v1 + v2, {(1:5)', (10:10:50)'}, [1 1])
% ans =
%     44    44    22    55    22
%     11    11    22    33    55
%     44    33    22    22    44
% 
% >> bml.stat.bootstrp_group(3, @(v1, v2) v1 + v2, {(1:5)', (10:10:50)'}, [1 2])
% ans =
%     54    21    33    25    11
%     31    12    43    11    53
%     12    54    24    32    34
% 
% >> bml.stat.bootstrp_group(3, @(v1, v2) v1 + v2, {(1:5)', (10:10:50)'}, [1 0])
% ans =
%     15    22    32    41    54
%     12    25    33    41    51
%     15    23    35    43    54
%
% See also: bootstrp
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.
assert(isscalar(n_boot));
assert(isnumeric(n_boot));

if ischar(bootfun)
    bootfun = str2func(bootfun);
else
    assert(isa(bootfun, 'function_handle'));
end

assert(iscell(args));
assert(isvector(args));
n_args = numel(args);

assert(isnumeric(group));
assert(isvector(group));

n_group = max(group);
assert(n_group <= n_args);

S = varargin2S(varargin, {
    'UseParallel', true
    'boot_tr', {} % {group}(row, i_boot) = row0 or just (row, i_boot)
    });

%% Sample
n_rows = cellfun(@(v) size(v,1), args);

boot_tr = S.boot_tr;
if isempty(boot_tr);
    boot_tr = cell(1, n_group);
else
    if ~iscell(boot_tr)
        % Assume that only the first group's is provided.
        boot_tr = {boot_tr};
    end
    if numel(boot_tr) < n_group
        boot_tr{n_group} = [];
    end
end

for i_boot = 1:n_boot
    for i_group = 1:n_group
        incl = group == i_group;
        if ~any(incl)
            continue;
        else
            n_row = n_rows(find(incl, 1));
            if isempty(boot_tr{i_group})
                boot_tr{i_group} = randsample(n_row, n_row * n_boot, true);
                boot_tr{i_group} = reshape(boot_tr{i_group}, ...
                    [n_row, n_boot]);
            else
                assert(size(boot_tr{i_group}, 1) == n_row);
                assert(size(boot_tr{i_group}, 2) >= n_boot);
            end            
        end
    end
end

%% Process
bootstat = cell(n_boot, 1);

if S.UseParallel
%     bootstat = arrayfun(@get_bootstat_unit, (1:nboot)', ...
%         'UniformOutput', false);
    parfor i_boot = 1:n_boot
        c_args = args;
        for i_group = 1:n_group
            incl = group == i_group;
            if ~any(incl), continue; end

%             n_row = n_rows(find(incl, 1)); %#ok<PFBNS>
%             ix = randsample(n_row, n_row, true);
            
            ix = boot_tr{i_group}(:, i_boot); %#ok<PFBNS>

            for i_arg = find(incl)
                c_args{i_arg} = args{i_arg}(ix,:);
            end
        end

        bootstat{i_boot} = hVec(bootfun(c_args{:})); %#ok<PFBNS>
    end
else
    for i_boot = 1:n_boot
        c_args = args;
        for i_group = 1:n_group
            incl = group == i_group;
            if ~any(incl), continue; end

%             n_row = n_rows(find(incl, 1)); %#ok<PFBNS>
%             ix = randsample(n_row, n_row, true);
            
            ix = boot_tr{i_group}(:, i_boot);

            for i_arg = find(incl)
                c_args{i_arg} = args{i_arg}(ix,:);
            end
        end

        bootstat{i_boot} = hVec(bootfun(c_args{:}));
    end
end
bootstat = cell2mat(bootstat);

%     function res = get_bootstat_unit(~)
%         c_args = args;
%         for i_group = 1:n_group
%             incl = group == i_group;
%             if ~any(incl), continue; end
% 
%             n_row = n_rows(find(incl, 1));
%             ix = randsample(n_row, n_row, true);
% 
%             for i_arg = find(incl)
%                 c_args{i_arg} = args{i_arg}(ix,:);
%             end
%         end
% 
%         res = hVec(bootfun(c_args{:}));
%     end
end