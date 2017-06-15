function est_p = betaest(p1)
    if isempty(p1)
        est_p = nan;
    elseif all(abs(p1(:) - p1(1)) < 1e-5)
        est_p = p1(1);
    else
        est_ab = betafit(p1);
        est_p = est_ab(1) / (est_ab(1) + est_ab(2));
    end
end
