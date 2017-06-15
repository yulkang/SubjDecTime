classdef NullFile < matlab.mixin.Copyable
    % NullFile
    %
    % 2016 (c) Yul Kang. hk2699 at columbia dot edu.
    
methods (Static)
    function [files, info] = ls(d)
        if ~exist('d', 'var'), d = pwd; end
        if ~bml.file.exist_dir(d)
            warning('Directory %s does not exist!', d);
        end
        info = dir(d);
        
        siz = [info.bytes];
        incl = (siz == 0) & ~[info.isdir];
        
        info = info(incl);
        files = {info.name};
        
        files = fullfile(d, files(:));
    end
    function files = delete(d, varargin)
        % files = delete(d, varargin)
        
        S = varargin2S(varargin, {
            'confirm', true
            });
        
        if ~exist('d', 'var'), d = pwd; end
        if ~bml.file.exist_dir(d)
            warning('Directory %s does not exist!', d);
        end
        
        files = bml.file.NullFile.ls(d);
        n = length(files);
        
        if n == 0
            fprintf('No null files exist in %s\n', d);
            return;
        end
        if S.confirm
            fprintf('-----\n');
            fprintf('%s\n', files{:});
            fprintf('-----\n');
            fprintf('Delete %d null files in %s', n, d);
            if ~inputYN_def('', false)
                return;
            end
        end
        
        for ii = 1:n
            delete(files{ii});
        end
    end
    function tf = isa(file)
        % True if the given name is a file of size zero.
        % Works with cell arrays of file names.
        %
        % tf = isa(file)
        %
        % See also: NullFile.save
        if iscell(file)
            tf = cellfun(@bml.file.NullFile.isa, file);
            return;
        else
            assert(ischar(file));
        end
        
        if ~exist(file, 'file')
            tf = false;
        else
            info = dir(file);
            if isempty(info)
                tf = false; % [];
            else
                tf = (info.bytes == 0) && (info.isdir == 0);
            end
        end
    end
    function save(file)
        % Create a .mat file of zero size.
        %
        % See also: NullFile.isa

        % % TODO: perhaps implement options
        % tf_existing = exist(file, 'file');
        % if tf_existing && ~strcmp(S.if_existing, 'overwrite')
        %     d = dir(file);
        %     assert(isscalar(d));
        %     tf_empty = d.bytes == 0;
        %     if ~tf_empty
        %         error('Non-empty file %s exists!', file);
        %     end
        % end

        [pth,~,ext] = fileparts(file);
        if isempty(ext)
            file = [file, '.mat'];
        end

        mkdir2(pth);
        f = fopen(file, 'w');
        fclose(f);
    end
end
end