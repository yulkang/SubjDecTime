function tf1 = tf_narrow(tf1, tf_within_tf1_true)
% tf1 = tf_narrow(tf1, tf_within_tf1_true)
%
% Given two logical vectors where length(tf_within_tf1_true) == nnz(tf1 == true),
% returns a vector after performing tf1(tf1) = tf_within_tf1_true.
tf1(tf1) = tf_within_tf1_true;
end