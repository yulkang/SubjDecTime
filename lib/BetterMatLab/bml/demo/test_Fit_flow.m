% function test_cost_oop_simpler

%%
f_cost = @(fl) sum((fl.dat.x - fl.P.x).^2 + (fl.dat.y - fl.P.y).^2);
cost = Fit_module( ...
       {'x', {2, 1, 3}, ...
        'y', {20, 10, 30}}, ...
       {'x', 'y'}, ...
       'f_cost', f_cost ...
       );
   
bias = Fit_module( ...
       {'x_scale', {0, -1, 1}}, ...
       {}, ...
       'f_pred', {'x', @(fl) fl.P.x * fl.P.x_scale} ...
       );
       
flow = Fit_flow({cost, bias});

%%
disp(flow.dat_names); % Check if the column order is correct in dat_mat.

dat_mat = [1:5; 10:10:50]';
flow.init(dat_mat);

%%
tic;
[x_flow,~,~,output_flow] = flow.fmincon;
toc;































%%
test_Fit_flow_cost;

%%
test_Fit_flow_cost_control;

   
%%
tic;
[x_reg,~,~,output_reg] = ...
    fmincon(@(x) sum((dat_mat(:,1)-x(1)*x(3)).^2 + (dat_mat(:,2)-x(2)).^2), ...
    [2, 20, 0], ...
    [], [], [], [], ...
    [1, 10, -1], ...
    [3, 30, 1]);
toc;

%%
cost_subclass = test_Fit_module_cost;
bias_subclass = test_Fit_module_bias;
flow_subclass = Fit_flow({cost_subclass, bias_subclass});
flow_subclass.init(dat_mat);

%%
tic;
for ii = 1:1000
    flow_subclass.cost(flow_subclass.th_vec);
end
toc;

%%
tic;
[x_subclass,~,~,output_subclass] = flow_subclass.fmincon;
toc;

%%
disp(output_flow);
disp(output_reg);
disp(output_subclass);

% end