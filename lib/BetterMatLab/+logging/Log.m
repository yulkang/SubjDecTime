classdef Log < matlab.mixin.Copyable
    properties
        bCaller     = '';
        pth_code    = '';
        nam         = '';
        comment     = '';
        
        code_base   = '/CodeNData/Code/';
        data_base   = '/CodeNData/Data/';
        data_subdir = 'Data';
        
        add_datestr = true;
        datestr     = '';
        
        scheme      = 'parallel';
        verbose     = true;
        journal     = true;
        create_dir  = true;
        
        commit_changes = 'ask'; 
        ask_comment = false;
        
        to_log      = true;
        add_info    = {};
        
        fmt         = struct;
    end
    
    methods
        function me = Log(bCaller, varargin)
            if ~exist('bCaller', 'var'), bCaller = ''; end
            
            [me.bCaller, me.pth_code, me.nam] = ...
                logging.base_caller(bCaller, {mfilename('fullpath')});
            
            me.datestr = logging.datestr;
            
            logging.commit_if_changed(me.bCaller, { ...
                'comment',  me.comment, ...
                'datestr',  me.datestr, ...
                }, ...
                'verbose', me.verbose, ...
                'commit_changes', me.commit_changes ...
                );
            
            varargin2fields(me, varargin);
        end
        
        function varargout = name(me, subdir, kind, ext, comment, data_files, varargin)
            % varargout = name(me, subdir, kind, ext, comment, data_files, varargin)
            %
            % logging.Log.name doesn't commit; it only warns about changes.
            % This behavior is crucial when your program runs for a 
            % very long time (e.g., fitting), and saves intermittently.
            %
            % To commit, use the constructor, logging.Log, or logging.Log.init.
            
            if ~exist('comment', 'var') || isequal(comment, nan), comment = me.comment; end
            if ~exist('data_files', 'var'), data_files = {}; end
            
            % Don't commit changes after the object construction.
            c_commit_changes = me.commit_changes;
            
            varargin = varargin2C(varargin, ...
                S2C(me), ... 
                false);
            
            [varargout{1:nargout}] = logging.name(subdir, kind, ext, comment, data_files, ...
                varargin{:});
        end
        
        function add_fmt(me, fmt_name, subdir_fmt, kind_fmt, comment_fmt)
            % add_fmt(me, fmt_name, subdir_fmt, kind_fmt, comment_fmt)
            
            S.subdir = subdir_fmt;
            S.kind   = kind_fmt;
            S.comment = comment_fmt;
            
            me.fmt.(fmt_name) = S;
        end
        
        function varargout = name_fmt(me, fmt_name, ext, fmt_args, varargin)
            % varargout = name_fmt(me, fmt_name, ext, {fmt_arg1, ...}, varargin)
            
            if isempty(fmt_args), fmt_args = {}; end
            
            for cc_compo = {'subdir', 'kind', 'comment'}
                c_compo = cc_compo{1};
                c_fmt   = me.fmt.(fmt_name).(c_compo);
                
                S.(c_compo) = strrep_fmt(c_fmt, 'L', fmt_args{:});
            end
            
            [varargout{1:nargout}] = name(me, S.subdir, S.kind, ext, S.comment, varargin{:});
        end
    end
    
    methods (Static)
        function me = test(varargin)
           me = logging.Log('', varargin{:});
           name(me, 'subdir', 'kind', '.ext', 'comment');
        end
    end
end