classdef CommonWorkspace...
        < FitWorkspace ...
        & Fit.Common.EvTime ...
        & bml.oop.PropFileName
%% Props - Linked to Data
properties (Dependent)
    subj
    parad
    subj_parad % = {subj, parad}. For easy joint specification.
    data_file_type
    rt_field
    tr_incl
    balance
    incl_tRDKDur
    incl_tRDK2Go
    incl_tRDK2Go_msec
    incl_tRDKDur_msec
end
%% Internal
properties (Transient)
    W_now % For batch
end
%% Main
methods
    function W = CommonWorkspace(varargin)
        W.set_Data(Fit.Common.DataChRtPdf);
        if nargin > 0
            W.init(varargin{:});
        end
    end
    function set_Data(W, varargin)
        W.set_Data@Fit.Common.EvTime(varargin{:});
    end
    function init(W, varargin)
        bml.oop.varargin2props(W, varargin, true);
        W.Data.load_data;
    end
    function f = get_file_fields(W)
        f = {
            'subj',         'sbj'
            'parad',        'prd'
            'rt_field',     'rtfd'
            'tr_incl',      'tr'
            'balance',      'bal'
            };
        if bml.str.strcmpStart('VD', W.parad)
            f = [f
                {
                'incl_tRDK2Go_msec', 'dly'
                'incl_tRDKDur_msec', 'dur'
                }];
        end
    end
end
%% Data interface
methods
    function v = get.subj(W)
        v = W.Data.subj;
    end
    function set.subj(W, v)
        W.Data.subj = v;
    end

    function v = get.parad(W)
        v = W.Data.parad;
    end
    function set.parad(W, v)
        W.Data.parad = v;
    end
    
    function set.subj_parad(W, v)
        if ~isempty(v)
            assert(iscell(v));
            assert(numel(v) == 2);
            
            W.subj = v{1};
            W.parad = v{2};
        end
    end

    function v = get.data_file_type(W)
        v = W.Data.data_file_type;
    end
    function set.data_file_type(W, v)
        W.Data.data_file_type = v;
    end

    function v = get.rt_field(W)
        v = W.Data.rt_field;
    end
    function set.rt_field(W, v)
        W.Data.rt_field = v;
    end
    
    function v = get.tr_incl(W)
        v = W.Data.get_tr_incl;
    end
    function set.tr_incl(W, v)
        W.Data.tr_incl = v;
    end
    
    function v = get.balance(W)
        v = W.Data.balance;
    end
    function set.balance(W, v)
        W.Data.balance = v;
    end
    
    function v = get.incl_tRDKDur(W)
        v = W.Data.incl_tRDKDur;
    end
    function set.incl_tRDKDur(W, v)
        W.Data.incl_tRDKDur = v;
    end
    
    function v = get.incl_tRDK2Go(W)
        v = W.Data.incl_tRDK2Go;
    end
    function set.incl_tRDK2Go(W, v)
        W.Data.incl_tRDK2Go = v;
    end
    
    function v = get.incl_tRDK2Go_msec(W)
        v = W.Data.incl_tRDK2Go_msec;
    end
    function set.incl_tRDK2Go_msec(W, v)
        W.Data.incl_tRDK2Go_msec = v;
    end

    function v = get.incl_tRDKDur_msec(W)
        v = W.Data.incl_tRDKDur_msec;
    end
    function set.incl_tRDKDur_msec(W, v)
        W.Data.incl_tRDKDur_msec = v;
    end

end
end