classdef VisitorToTree < DeepCopyable
    % Visits VisitableTree and performs operation recursively.
    % Visit order is depth first. 
    % (root - child1 - grandchild1_1 - grandchild1_2 - child2 - grandchild2_1 ..)
    % Separate from VisitableTree so that new functionality can be added
    % without modifying VisitableTree or its subclasses.
    %
    % USAGE:
    % 'fun' is a function that gets a tree node as a sole input argument.
    %
    % flattened_struct = VisitorToTree.get_flattened_struct_from_tree(Tree, fun)
    % VisitorToTree.apply_flattened_struct_to_tree(fun, flattened_struct)
    % vec = VisitorToTree.get_flattened_vector_from_tree(Tree, fun, vec)
    % n_applied = VisitorToTree.apply_flattened_vector_to_tree(Tree, fun, size_fun, vec)
    % % size_fun(Tree) should give the size vector for the node.
    %
    % Shorten notation by assigning Visitor = VisitorToTree and using Visitor
    % in place of VisitorToTree.
    %
    % Test with VisitorToTree.test
    %
    % Currently, all methods are static. This makes explicit that they 
    % don't use information internal to Visitor.
    %
    % See also: VisitableTree.
    
%     properties
%         allowed_types = {'VisitableTree'};
%     end
    methods (Static) % feeding Visitor every time seems unnecessary...
        function tf = is_correct_type(Tree)
            tf = isscalar(Tree) && isa(Tree, 'VisitableTree');
        end
%         function tf = is_correct_type(Visitor)
%             tf = isoneof(Tree, Visitor.allowed_types);
%         end
        %% Visitor
        function flattened_struct = get_flattened_struct_from_tree(Tree, fun)
            Visitor = VisitorToTree;
            assert(Visitor.is_correct_type(Tree));
            assert(isa(fun, 'function_handle'));
            
            flattened_struct = struct;
            
            % Results from self
            my_name = Tree.get_name;
            flattened_struct.(my_name) = fun(Tree);
            
            % Results from children
            children = Tree.get_children;
            for ii = 1:length(children)
                child = children{ii};
                
                curr_res = Visitor.get_flattened_struct_from_tree(child, fun);
                flattened_struct = set_sub_struct(flattened_struct, curr_res, [my_name '__']);
            end
        end
        function apply_flattened_struct_to_tree(Tree, fun, flattened_struct)
            Visitor = VisitorToTree;
            assert(Visitor.is_correct_type(Tree));
            assert(isa(fun, 'function_handle'));
            assert(isstruct(flattened_struct));
            
            % Apply to myself
            my_name = Tree.get_name;
            fun(Tree, flattened_struct.(my_name));
            
            % Apply to children
            subres = get_sub_struct(flattened_struct, [my_name '__']);
            children = Tree.get_children;
            for ii = 1:length(children)
                Visitor.apply_flattened_struct_to_tree(children{ii}, fun, subres);
            end
        end
        function vec = get_flattened_vector_from_tree(Tree, fun, vec)
            Visitor = VisitorToTree;             
            assert(Visitor.is_correct_type(Tree));             
            assert(isa(fun, 'function_handle'));
            assert(isvector(vec));
            
            if nargin < 4
                vec = [];
            else
                vec = vec(:)';
            end
            children = Tree.get_children;
            for child = children(:)'
                curr_vec = fun(child{1});
                vec = [vec(:)', curr_vec(:)'];
            end
        end
        function n_applied = apply_flattened_vector_to_tree(Tree, ...
                fun, size_fun, vec)
            % n_applied = apply_flattened_vector_to_tree(Visitor, Tree, ...
            %     fun, size_fun, vec)
            % size_fun(Tree) gives the size vector for the node.
            
            Visitor = VisitorToTree;             
            assert(Visitor.is_correct_type(Tree));             
            assert(isa(fun, 'function_handle'));
            assert(isa(size_fun, 'function_handle'));
            assert(isvector(vec));
            
            siz = size_fun(Tree);
            len = prod(siz);
            
            fun(Tree, vec(1:len));
            n_applied = len;
            
            children = Tree.get_children;
            for ii = 1:length(children)
                curr_n_applied = Visitor.apply_flattened_vector_to_tree(child, ...
                    fun, size_fun, vec((n_applied + 1):end));
                n_applied = n_applied + curr_n_applied;
            end
        end        
        function set_tree_prop_recursive(Tree, prop, val)
            % set_tree_prop_recursive(Tree, prop, val)
            Visitor = VisitorToTree;             
            assert(Visitor.is_correct_type(Tree));             
            
            Tree.(prop) = val;
            for child = Tree.get_children
                Visitor.set_tree_prop_recursive(child{1}, prop, val);
            end
        end
        function eval_tree_recursive(Tree, fun)
            % eval_tree_recursive(Tree, fun)
            Visitor = VisitorToTree;             
            assert(Visitor.is_correct_type(Tree));             
            
            fun(Tree);
            for child = Tree.get_chilren
                Visitor.eval_tree_recursive(child{1}, fun);
            end
        end
    end
    methods (Static)
        function varargout = test(varargin)
            [varargout{1:nargout}] = VisitableTree.test(varargin{:});
        end
    end
end