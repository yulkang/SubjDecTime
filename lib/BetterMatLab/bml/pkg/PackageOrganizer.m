classdef PackageOrganizer
    % TODO: deal with classes with dedicated folder (@class) 
    % - use get_classes_in_package, which now deals with @classes.
    
    methods
        function Pack = PackageOrganizer(varargin)
        end
    end
    %% Moving package
    methods (Static)
        function move_package(package_src, package_dst, classes)
            % move_package(src, dst, classes)
            root = pwd; % Other cases are not implemented/tested yet.
            Pack = PackageOrganizer;
            
            if exist('classes', 'var') && ~isempty(classes)
                assert(iscell(classes));
                assert(all(cellfun(@ischar, classes)));
                
                classes_src = cellfun(@(c) [package_src '.' c], classes, ...
                    'UniformOutput', false);
            else
                classes_src = dirfiles(pkg2dir(package_src));
                classes_src = cellfun(@file2pkg, classes_src, ...
                    'UniformOutput', false);
                
            end
            classes_dst = strrep(classes_src, package_src, package_dst);

            n_classes = numel(classes_src);
            for ii = 1:n_classes
                fprintf('%30s => %30s\n', classes_src{ii}, classes_dst{ii});
            end
            if ~inputYN(sprintf('Do you want to move %d classes (y/n)? ', n_classes))
                fprintf('Move cancelled by user.\n');
                return;
            end
            
            for ii = 1:n_classes
                Pack.move_class(classes_src{ii}, classes_dst{ii}, root);
            end
            fprintf('Finished moving %d classes.\n', n_classes);
        end
    end
    %% Moving class
    methods (Static)
        function move_class(src, dst, root)
            % move_class(src, dst, root)
            % 
            % src, dst : class name or class instance
            if nargin < 3
                root = pwd;
            end
            if ~ischar(src), src = class(src); end
            if ~ischar(dst), dst = class(dst); end
            Pack = PackageOrganizer;
            Pack.move_class_file(src, dst);
            Pack.replace_class_name(src, dst, root);
        end
    end
    %% ---- Internal
    %% Finding class
    methods (Static)
        function [class_files, classes] = get_classes_in_package(package_src)
            d_package = pkg2dir(package_src);
            class_files = dirfiles(d_package);
            
            [dirs, dir_names] = dirdirs(d_package);
            tf_class_dir = cellfun(@(s) ~isempty(s) && (s(1) == '@'), ...
                dir_names);
            class_dirs = dirs(tf_class_dir);
            class_names_in_dir = cellfun(@(s) s(2:end), ...
                dir_names(tf_class_dir), ...
                'UniformOutput', false);
            classes_in_dir = cellfun(@(d,f) fullfile(d, [f '.m']), ...
                class_dirs, class_names_in_dir, ...
                'UniformOutput', false);
            
            class_files = [class_files(:); classes_in_dir(:)];
            classes = file2pkg(class_files);
        end
    end
    %% Moving class
    methods (Static, Hidden)
        function move_class_file(src, dst)
            Pack = PackageOrganizer;
            
            src_file = which(src);
            dst_file = Pack.class2path(dst);
            [~, dst_name] = fileparts(dst_file);
            
            movefile2(src_file, dst_file, true);
            text = fileread(dst_file);
            
            [text, classdef_name] = Pack.strrep_classdef_name(text, dst_name);
            if ~isempty(classdef_name)
                text = Pack.strrep_constructor_name(text, classdef_name, dst_name);
            end
            
            filewrite(dst_file, text);
        end
        function replace_class_name(src, dst, root, varargin)
            if nargin < 3
                root = pwd;
            end
            C = varargin2C(varargin, {
                'pth', root
                'confirm', false
                });
            strrep_rdir(src, dst, C{:});
        end
    end
    methods (Static, Hidden)
        %% Path
        function pth = class2path(cl)
            pth = ['+', strrep(cl, '.', [filesep, '+']), '.m'];
            pos_last_plus = find(pth == '+', 1, 'last');
            pth(pos_last_plus) = '';
        end
        %% Modify MATLAB code
        function [text_res, name_classdef] = strrep_classdef_name(text_orig, dst)
            [name_classdef, st, en] = PackageOrganizer.get_classdef_name_pos(text_orig);
            if isempty(st)
                text_res = text_orig;
                name_classdef = '';
                return;
            end
            text_res = [text_orig(1:(st-1)), dst, text_orig((en+1):end)];
        end
        function text_res = strrep_constructor_name(text_orig, src, dst)
            [st, en] = PackageOrganizer.get_pos_constructor(text_orig, src);
            
            if ~isempty(st) && ~isempty(en)
                text_res = strrep_st_en(text_orig, st, en, dst);
            else
                text_res = text_orig;
                warning('No constructor found for the class %s', src);
            end
        end
        %% Parse MATLAB code
        function [res, st, en] = get_classdef_name_pos(text)
            expr = '\W*classdef\W+(\w+)\W+';
            [st, en, res]  = regexp(text, expr, 'start', 'end', 'tokens', 'once');
            if isempty(res)
                return;
            end
            res = res{1};
            
            str = text(st:en);
            st = st + strfind_whole(str, res) - 1;
            en = st + length(res) - 1;
            
%             token = 'classdef';
%             en_classdef = strfind_whole(text, token) + length(token) - 1;
%             assert(numel(en_classdef) >= 1, ...
%                 'There must be a classdef!');
%             en_classdef = en_classdef(1);
%             
%             assert(en_classdef + 2 <= length(text));
%             res = textscan(text((en_classdef + 2):end), '%s', 1);
%             res = res{1}{1};
%             
%             st = strfind_whole(text, res);
%             st = st(find(st >= (en_classdef + 2), 1, 'first'));
%             en = st + length(res) - 1;
        end
        function [st, en] = get_pos_constructor(text, class_name)
            expr = ['\W+function\W*\w+\W*=\W*' class_name '\W+'];
            st = regexp(text, expr, 'start');
            en = regexp(text, expr, 'end');
            str = text(st:en);
            
            st = st + strfind_whole(str, class_name) - 1;
            en = st + length(class_name) - 1;
        end
    end
end