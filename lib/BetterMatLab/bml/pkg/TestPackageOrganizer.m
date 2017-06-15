classdef TestPackageOrganizer < matlab.unittest.TestCase
    properties
        src = varargin2S({
            'packs', {}
            'name', ''
            });
        dst = varargin2S({
            'packs', {}
            'name', ''
            });
    end
    methods (Test)
        function in_package_to_in(TC)
            TC.set_src_in;
            TC.set_dst_in;
            TC.verify;
        end
        function in_package_to_out(TC)
            TC.set_src_in;
            TC.set_dst_out;
            TC.verify;
        end
        function out_package_to_in(TC)
            TC.set_src_out;
            TC.set_dst_in;
            TC.verify;
        end
        function out_package_to_out(TC)
            TC.set_src_out;
            TC.set_dst_out;
            TC.verify;
        end        
    end
    methods (TestMethodTeardown)
        function teardown(TC)
            TC.remove_all(TC.src);
            TC.remove_all(TC.dst);
        end
    end
    methods
        %% Verify
        function verify(TC)
            TC.setup;            
            PackageOrganizer.move_class( ...
                TC.get_full_class(TC.src), TC.get_full_class(TC.dst));
            TC.verify_dst;
        end
        function verify_dst(TC)
            for line = [1 3]
                actual_text = TC.read_line(TC.get_full_file(TC.dst), line);
                fprintf('Actual line %d: %s\n', line, actual_text);
                TC.verifyEqual(actual_text, ...
                    TC.get_text(TC.dst.name, line));
            end            
        end
        %% File I/O
        function setup(TC)
            mkdir2(TC.get_dir(TC.src));
            filewrite(TC.get_full_file(TC.src), TC.get_text);
        end
        function remove_all(~, obj)
            if isempty(obj.packs)
                file = [obj.name '.m'];
                if exist(file, 'file')
                    delete(file);
                    fprintf('Deleted %s\n', file);
                end
            else
                d = ['+' obj.packs{1}];
                rmdir(d, 's');
                fprintf('Deleted %s\n', d); 
            end
        end
        function str = read_line(~, file, line)
            fid = fopen(file, 'r');
            for ii = 1:line
                str = fgetl(fid);
            end
            fclose(fid);
        end
        %% Set
        function set_src_in(TC)
            TC.src.packs = {'examplePackageOrganizer', 'exampleSubPackage'};
            TC.src.name = 'ExamplePackageOrganizer';
        end
        function set_src_out(TC)
            TC.src.packs = {};
            TC.src.name = 'ExamplePackageOrganizer';
        end
        function set_dst_in(TC)
            TC.dst.packs = {'exampleDestPackage', 'exampleDestSubPackage'};
            TC.dst.name = 'ExampleDest';
        end
        function set_dst_out(TC)
            TC.dst.packs = {};
            TC.dst.name = 'ExampleDest';
        end
        %% Get
        function d = get_dir(~, obj)
            pack_dirs = cellfun(@(s) ['+' s], obj.packs, ...
                'UniformOutput', false);
            if isempty(pack_dirs)
                d = '';
            else
                d = fullfile(pack_dirs{:});
            end
        end
        function full_file = get_full_file(TC, obj)
            full_file = fullfile(TC.get_dir(obj), [obj.name, '.m']);
        end
        function full_class = get_full_class(~, obj)
            full_class = str_bridge('.', obj.packs{:}, obj.name);
        end
        function text = get_text(TC, name, line)
            if nargin < 2
                name = TC.src.name;
            end
            text = {
                ['classdef ' name ' < handle & matlab.mixin.Copyable']
                '    methods'
                ['        function ex = ' name '(input1, varargin)']
                '        end'
                '    end'
                'end'
                };
            if nargin < 3
                return;
            else
                text = text{line};
            end
        end
    end
end