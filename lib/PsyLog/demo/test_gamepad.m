% test_gamepad
Gamepad('Unplug');

%%
Gamepad GetNumGamepads
Gamepad('GetGamepadNamesFromIndices', 1)
n_but = Gamepad('GetNumButtons', 1)
n_ax  = Gamepad('GetNumAxes', 1)

bb = zeros(1,n_but);
aa = zeros(1,n_ax);

%%
tic; 
for ii = 1:1
    for jj = 1:n_ax
        aa(jj) = Gamepad('GetAxis', 1, jj);
    end
    for jj = 1:n_but, 
        bb(jj) = Gamepad('GetButton', 1,jj); 
    end
end
toc;

disp(aa);
disp(bb);

%%
for ii = 1:n_ax
    h_ax(ii,:) = Gamepad('GetAxisRawMapping', 1, ii);
end

%%
for ii = 1:n_but
    h_but(ii,:) = Gamepad('GetButtonRawMapping', 1, ii);
end

%%
