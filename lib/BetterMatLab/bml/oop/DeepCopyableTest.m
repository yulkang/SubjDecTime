classdef DeepCopyableTest < DeepCopyable
    % DeepCopyableTest tests whether DeepCopyable works as expected.
    % This class also demonstrates how to subclass DeepCopyable.
    %
    % EXAMPLE:
    % >> [tf_success, dc1, dc2] = DeepCopyableTest.test;
    % Trying dc2 = dc1.deep_copy
    %   dc2. ~= dc1.
    %   dc2..name == 'parent'
    %     dc. successfully copied by value!
    % 
    %   dc2.public_prop ~= dc1.public_prop
    %   dc2.public_prop.name == 'public_prop_name'
    %     dc.public_prop successfully copied by value!
    % 
    %   dc2.private_set ~= dc1.private_set
    %   dc2.private_set.name == 'private_set_name'
    %     dc.private_set successfully copied by value!
    % 
    %   dc2.get_private_get ~= dc1.get_private_get
    %   dc2.get_private_get.name == 'private_get_name'
    %     dc.get_private_get successfully copied by value!
    % 
    %   dc2.get_private_getset ~= dc1.get_private_getset
    %   dc2.get_private_getset.name == 'private_getset_name'
    %     dc.get_private_getset successfully copied by value!
    % 
    % deep_copying dc1 successful!
    % 
    % ... (Additional test messages for nested properties.
    %      When successful, all ends with 'successful!' and
    %      the tf_success == true.)
    % 
    % See also: DeepCopyable
    %
    % 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.
    properties
        name
        public_prop
    end
    properties (SetAccess = private)
        private_set
    end
    properties (GetAccess = private)
        private_get
    end
    properties (Access = private)
        private_getset
    end
    properties (Constant)
        props_to_test = {'public_prop', 'private_set', 'private_get', 'private_getset'};
    end
    methods
        function dc = DeepCopyableTest(name)
            if nargin == 0
                name = 'test';
            end
            
            dc.add_deep_copy(DeepCopyableTest.props_to_test);
            dc.name = name;
        end
        
        function v = get_public_prop(dc)
            % Unnecessary in general but added here for convenient demo.
            v = dc.public_prop;
        end
        function v = get_private_set(dc)
            % Unnecessary in general but added here for convenient demo.
            v = dc.private_set;
        end
        function v = get_private_get(dc)
            v = dc.private_get;
        end
        function v = get_private_getset(dc)
            v = dc.private_getset;
        end
        
        function set_public_prop(dc, v)
            % Unnecessary in general but added here for convenient demo.
            dc.public_prop = v;
        end
        function set_private_set(dc, v)
            dc.private_set = v;
        end
        function set_private_get(dc, v)
            % Unnecessary in general but added here for convenient demo.
            dc.private_get = v;
        end
        function set_private_getset(dc, v)
            dc.private_getset = v;
        end
    end
    methods (Static)
        function [tf_success, dc1, dc2, nested1, nested2] = test
            % [tf_success, dc1, dc2, nested1, nested2] = test
            
            %% Non-nested props
            dc1 = DeepCopyableTest('parent');
            dc1.public_prop = DeepCopyableTest('public_prop_name');
            dc1.set_private_set(DeepCopyableTest('private_set_name'));
            dc1.private_get = DeepCopyableTest('private_get_name');
            dc1.set_private_getset(DeepCopyableTest('private_getset_name'));
            
            fprintf('Trying dc2 = dc1.deep_copy\n');
            dc2 = dc1.deep_copy;
            
            if DeepCopyableTest.is_copied_by_value(dc1, dc2)
                fprintf('deep_copying dc1 successful!\n\n');
                tf_success = true;
            else
                error('deep_copying dc1 unsuccessful!');
            end
            
            %% Nested props
            nested1 = dc1.deep_copy;
            for field = DeepCopyableTest.props_to_test             
                nested1.(['set_' field{1}])(dc1.deep_copy);
            end
            nested2 = nested1.deep_copy;
            
            for field = DeepCopyableTest.props_to_test
                fprintf('Examining nested2.%s\n', field{1});
                
                f1 = nested1.(['get_' field{1}]);
                f2 = nested2.(['get_' field{1}]);
                
                if DeepCopyableTest.is_copied_by_value(f1, f2, ...
                        ['nested1.' field{1}], ['nested2.' field{1}])
                    fprintf('deep_copying nested1.%s succesful!\n\n', ...
                        field{1});
                    tf_success = true;
                else
                    error('deep_copying nested1.%s unsuccessful!', field{1});
                end
            end            
        end
        function tf = is_copied_by_value(dc1, dc2, dc_name1, dc_name2)
            if nargin < 3
                dc_name1 = 'dc1';
            end
            if nargin < 4
                dc_name2 = 'dc2';
            end
            for field = { ...
                    '', 'public_prop', 'private_set', ...
                    'get_private_get', 'get_private_getset'}

                if isempty(field{1})
                    f1 = dc1;
                    f2 = dc2;
                else
                    f1 = dc1.(field{1});
                    f2 = dc2.(field{1});
                end

                if f1 == f2
                    error('  Copied by reference rather than by value!');
                else
                    fprintf('  %s.%s ~= %s.%s\n', ...
                        dc_name1, field{1}, dc_name2, field{1});
                    fprintf('  %s.%s.name == ''%s''\n', ...
                        dc_name2, field{1}, f2.name);
                    if f1.name ~= f2.name
                        error('    Field .name not the same!');
                    else
                        fprintf('    %s.%s successfully copied by value!\n\n', ...
                            dc_name1, field{1});
                    end
                end
            end
            tf = true;
        end
    end
end