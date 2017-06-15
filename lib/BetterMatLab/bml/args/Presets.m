classdef Presets
    properties
        rootdir = 'Data/presets_'
        subdir  = 'default'        
    end
    
    properties (Dependent)
        presetFiles
        presetNams
        presetDir
        
        selFile
        selections
    end
    
    methods
        function Prs = Presets(varargin)
            if nargin > 0
                Prs = varargin2fields(Presets, varargin);
            end
        end
        
        %% Get/Set
        function v = get.presetNams(Prs)
            [~,v] = filepartsAll(Prs.presetFiles);
        end
        
        function v = get.presetFiles(Prs)
            v = dirfiles(Prs.presetDir);
        end
        
        function v = get.presetDir(Prs)
            v = fullfile(Prs.rootdir, Prs.subdir, 'presets_');
        end
        
        function v = get.selections(Prs)
            v = load(Prs.selFile, '-struct');
        end
        
        function v = get.selFile(Prs)
            v = fullfile(S.rootdir, S.subdir, 'selections.mat');
        end
    end    
    
    %% ===== Static =====
    methods (Static)
        function [todos, nams, Prs] = choose(sdir)
            if nargin < 1 || isempty(sdir), sdir = 'default'; end
            Prs = Presets('subdir', sdir);
            
            [todos, nams] = Prs.selections;
        end
    end
end