function [t, label] = c2timeline(c)
% C2TIMELINE - Time of change to another string, suited to plot with TIMELINE
%
% [t, label] = c2timeline(c)
%
% [t, label] = c2timeline({'a', 'a', 'b', 'b', 'a', 'b'})
% t =
%      1     3     5     6
% label = 
%     'a'    'b'    'a'    'b' 
%
% See also: timeline

t(1)     = 1;
label(1) = c(1);

n        = length(c);

for ii = 2:n
    if ~strcmp(label{end}, c{ii})
        label{end+1} = c{ii}; %#ok<AGROW>
        t(end+1) = ii; %#ok<AGROW>
    end
end