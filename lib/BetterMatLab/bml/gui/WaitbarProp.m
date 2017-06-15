classdef WaitbarProp < matlab.mixin.Copyable
properties
    h = [];
    nDone  = 0;
    nTotal = 1;
    fmt = '%g/%g (%1.1f%%) done';
end
methods
    function me = WaitbarProp(varargin)
        if nargin > 0
            init(me, varargin{:});
        end
    end
    function init(me, varargin)
        varargin2fields(me, varargin);
        
        if isempty(me.h)
            me.h = waitbar(me.nDone / me.nTotal, ...
                sprintf(me.fmt, me.nDone, me.nTotal, me.nDone / me.nTotal * 100));
        end
    end
    function update(me, nDone, varargin)
        me.nDone = nDone;
        if nargin > 2
            varargin2fields(me, varargin);
        end
        waitbar(me.nDone / me.nTotal, me.h, sprintf(me.fmt, me.nDone, me.nTotal, ...
            me.nDone / me.nTotal * 100));
    end
    function delete(me)
        delete(me.h);
        me.h = [];
    end
end
end