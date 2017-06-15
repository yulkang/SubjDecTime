Tree = VisitableTree('root');
Tree.add_children(varargin2S({
    'child1', VisitableTree('child1')
    'child2', VisitableTree('child2')
    }));
for child = Tree.get_children
    child{1}.add_children(varargin2S({
        'grandchild1', VisitableTree('grandchild1')
        'grandchild2', VisitableTree('grandchild2')
        }));
end

Visitor = VisitorToTree;
f_get_name_struct = @(Tree) ...
    Visitor.get_flattened_struct_from_tree(Tree, @(Tree) Tree.get_name);

name_struct = f_get_name_struct(Tree);
disp(name_struct);

Tree_struct = ...
    Visitor.get_flattened_struct_from_tree(Tree, @(Tree) Tree);

%% Test add 
assert(isequal(name_struct, varargin2S({
    'root', 'root'
    'root__child1', 'child1'
    'root__child1__grandchild1', 'grandchild1'
    'root__child1__grandchild2', 'grandchild2'
    'root__child2', 'child2'
    'root__child2__grandchild1', 'grandchild1'
    'root__child2__grandchild2', 'grandchild2'
    })));

%% Test update_parent on add
nodes = struct2cell(Tree_struct);
for node = nodes(:)'
    node_name = node{1}.get_name;
    root_name = node{1}.root_.get_name;
    fprintf('%s.root = %s\n', node_name, root_name);
    assert(isequal(root_name, 'root'));
end

%% Test remove_child
child = Tree.get_child('child1');
Tree.remove_child('child1');

name_struct = f_get_name_struct(Tree);
disp(name_struct);
assert(isequal(name_struct, varargin2S({
    'root', 'root'
    'root__child2', 'child2'
    'root__child2__grandchild1', 'grandchild1'
    'root__child2__grandchild2', 'grandchild2'
    })));

child_root_name = child.root_.get_name;
disp(child_root_name);
assert(isequal(child_root_name, 'child1'));

grandchild = child.get_child('grandchild1');
grandchild_root_name = grandchild.root_.get_name;
disp(grandchild_root_name);
assert(isequal(grandchild_root_name, 'child1'));

%% Test remove_parent
child = Tree.get_child('child2');
child.remove_parent;

name_struct = f_get_name_struct(Tree);
disp(name_struct);
assert(isequal(name_struct, varargin2S({
    'root', 'root'
    })));

child2_root_name = child.root_.get_name;
disp(child2_root_name);
assert(isequal(child2_root_name, 'child2'));

grandchild = child.get_child('grandchild1');
grandchild_root_name = grandchild.root_.get_name;
disp(grandchild_root_name);
assert(isequal(grandchild_root_name, 'child2'));
