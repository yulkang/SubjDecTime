function res = input_or_paste(prompt)
% res = input_or_paste(prompt)

res = input(prompt, 's');

if isempty(res)
    res = clipboard('paste');
end