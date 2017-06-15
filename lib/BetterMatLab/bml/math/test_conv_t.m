% Test conv_t

%% Vectors
t = (0:0.01:1)';
a = gampdf_ms(t, 0.1, 0.05, 1);
b = gampdf_ms(t, 0.2, 0.1, 1);
c = conv_t(a,b);

clf;
plot(t, a, 'r-');
hold on;

plot(t, b, 'b-');
hold on;

plot(t, c, 'm-');
hold off;

%% Matrix
t = (0:0.01:1)';
a = [gampdf_ms(t, 0.1, 0.05, 1), gampdf_ms(t, 0.15, 0.05, 1)];
b = [gampdf_ms(t, 0.2, 0.1, 1),  gampdf_ms(t, 0.3, 0.1, 1)];
c = conv_t(a,b);

clf;
plot(t, a, 'r-');
hold on;

plot(t, b, 'b-');
hold on;

plot(t, c(:,1), 'm-');
hold on;

plot(t, c(:,2), 'c-');
hold off;
