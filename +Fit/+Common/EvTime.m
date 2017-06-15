classdef EvTime ...
        < FitWorkspace ...
        & EvAxis.EvidenceAxisInheritable ...
        & TimeAxis.TimeInheritable
    %
    % 2015 YK wrote the initial version.
methods
    %% Match Time to Data.Time.
    function set_Data(W, Data)
        W.set_Data@FitWorkspace(Data); % Data is always maintained as the root's.
        W.Data.set_Time(W.get_Time); % Time is updated to match the workspace's.
%         W.set_Time(Data.get_Time); % Time is updated to match the data's
    end
    %% Always use root's Time and EvAxis.
    function set_Time(W, Time)
        root = W.get_Data_source;
        root.set_Time@TimeAxis.TimeInheritable(Time);
    end
    function Time = get_Time(W)
        root = W.get_Data_source;
        Time = root.get_Time@TimeAxis.TimeInheritable;
    end
    function set_EvAxis(W, EvAxis)
        root = W.get_Data_source;
        root.set_EvAxis@EvAxis.EvidenceAxisInheritable(EvAxis);
    end
    function EvAxis = get_EvAxis(W)
        root = W.get_Data_source;
        EvAxis = root.get_EvAxis@EvAxis.EvidenceAxisInheritable;
    end
    function set_root(W, new_root)
        % When the W itself becomes a root,
        % set its Time & EvAxis to the previous root's Time & EvAxis.
        
        prev_root = W.get_root;
        W.set_root@FitWorkspace(new_root);
        if W.is_root % Equivalent to W == new_root
            W.set_Time(prev_root.get_Data);
            W.set_EvAxis(prev_root.get_EvAxis);
        end
    end
    function src = get_Data_source(W)
        % Defaults to the root. 
        % Modify, e.g., to self, in subclasses if necessary.
        % Then set_root should be changed as well.
        src = W.get_root;
    end
end
% methods (Static)
%     function W = loadobj(W) % Perhaps unnecessary.
%         if isa(W.Data, 'FitData')
%             W.set_Data(W.Data); % To evoke set_Time
%         end 
%     end
% end
end
    