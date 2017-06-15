function [tf, abs_t, rel_t, val_act] = wait(Ser, prop, val, varargin)
% Wait until isequal(get(Ser, prop), val) or val(get(Ser, prop))
%
% [tf, abs_t, rel_t, val_act] = wait(Ser, prop, val, ['opt1', opt1, ...])
%
% val   : If function handle, wait until val(get(Ser, prop)) evaluates to true.
%         Otherwise, wait until isequal(get(Ser, prop), val) evaluates to true.
%
% tf    : True if desired state is achieved.
% abs_t : Absolute time when the state is achieved.
% rel_t : Wait time until the state is achieved.
% val_act: Actual value when either the state is achieved or max_t is reached.
% 
% Options:
%     'max_t',    1 ...           % How long to wait (sec)
%     'retry_t',  0.001 ...       % How soon to retry (sec)
%     'f_time',   @() GetSecs ... % alternatively, give @() now

S = varargin2S(varargin, { ...
    'max_t',    1 ...           % How long to wait (sec)
    'retry_t',  0.0002 ...       % How soon to retry (sec)
    'f_time',   @() GetSecs ... % alternatively, give @() now
    });

st = S.f_time();
tf = false;

if ~isa(val, 'function_handle')
    f_until = @(v) isequal(v, val);
else
    f_until = val;
end

while (S.f_time() < st + S.max_t)
    val_act = get(Ser, prop);
    
    if f_until(val_act)
        tf = true;
        break;
    else
        WaitSecs(S.retry_t);
    end
end

abs_t = S.f_time();
rel_t = abs_t - st;