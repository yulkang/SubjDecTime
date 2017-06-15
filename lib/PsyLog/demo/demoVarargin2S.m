function demoVarargin2S
% Demonstrates uses of varargin2S and varargin2V.
%
% See also: varargin2S, varargin2V
%
% 2013 Yul Kang. hk2699 at columbia dot edu.

disp('===== varargin2S =====');
disp('demo1(10, 20);');
demo1(10, 20);

disp('demo1(10, 20, ''opt2'', 30);');
demo1(10, 20, 'opt2', 30);

disp('demo1(10, 20, ''opt2'', 30, ''opt1'', 40)');
demo1(10, 20, 'opt2', 30, 'opt1', 40);

disp('===== varargin2V =====');
disp('demo2(10, 20);');
demo2(10, 20);

disp('demo2(10, 20, ''opt2'', 30);');
demo2(10, 20, 'opt2', 30);

disp('demo2(10, 20, ''opt2'', 30, ''opt1'', 40)');
demo2(10, 20, 'opt2', 30, 'opt1', 40);

disp('===== varargin2S with an unexpected argument =====');
try
    disp('demo3(10, 20, ''opt3'', 30, ''opt1'', 40);');
    demo3(10, 20, 'opt3', 30, 'opt1', 40);
catch LE
    disp(LE.message);
end
end

function demo1(req1, req2, varargin)
opt = varargin2S(varargin, {'opt1', 1, 'opt2', 2});

dispVar(req1, req2, opt);
end

function demo2(req1, req2, varargin)
varargin2V(varargin, {'opt1', 1, 'opt2', 2});

dispVar(req1, req2, opt1, opt2);
end

function demo3(req1, req2, varargin)
opt = varargin2S(varargin, {'opt1', 1, 'opt2', 2}, true);

dispVar(req1, req2, opt);
end

function dispVar(varargin)
% dispVar(variable1, variable2, ...)
%
% Example
%
% dispVar(a, [2 3], b)
%          a =      2
% 
% #        2 =      2     3
% 
%          b =      4
% 
% 2013 Yul Kang. hk2699 at columbia dot edu.

for ii = 1:length(varargin)
    if isempty(inputname(ii))
        fprintf('#%d =\n', ii);
    else
        fprintf('%s =\n', inputname(ii));
    end
    disp(varargin{ii});
end
end