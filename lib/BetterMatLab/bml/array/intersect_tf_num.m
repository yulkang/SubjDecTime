function tf = intersect_tf_num(tf, num)
% Intersection between logical and numerical indices.

tf2 = false(size(tf));
tf2(num) = true;

tf  = tf & tf2;