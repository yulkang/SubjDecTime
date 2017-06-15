function loglik = glm_train_test(X_train, y_train, X_test, y_test, glm_args)
% loglik = glm_train_test(X_train, y_train, X_test, y_test, glm_args)

if ~exist('glm_args', 'var')
    glm_args = {};
end
glm_args = varargin2C(glm_args, {
    'Distribution', 'binomial'
    });
glm_opt = varargin2S(glm_args);
assert(strcmp(glm_opt.Distribution, 'binomial'));

mdl1 = fitglm(X_train, y_train, glm_args{:});
y_pred = predict(mdl1, X_test);

loglik = bml.stat.glmlik(X_test, y_test, y_pred, glm_opt.Distribution);