function ci = betaci(p1, prct)
% ci = betaci(p1, prct)
    if all(p1(:) == p1(1))
        ci = zeros(size(prct)) + p1(1);
    else
        est_ab = betafit(p1);
        ci = betainv(prct / 100, ...
            est_ab(1), est_ab(2));
    end
end
