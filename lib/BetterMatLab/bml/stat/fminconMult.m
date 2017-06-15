function res = fminconMult(fun, params, opt)
% res = fminconMult(fun, params, opt)
%
% fun      : will be fed to fminconWrap.
% params   : nParam x (name, guesses, min, max) cell array.
% guesses  : numerical vector.
% min, max : scalar.
% opt      : as defined by optimset.
%
% res      : a struct.
%
% See also: FMINCONWRAP, FMINCON.

if ~exist('opt', 'var'), opt = optimset; end

pName  = params(:,1);
pGuess = cellfun(@num2cell, params(:,2), 'uniformoutput', false);
pMin   = hVec(cell2mat(params(:,3)));
pMax   = hVec(cell2mat(params(:,4)));

pRep   = factorize(pGuess); % nGuess x nParam cell

fVal  = inf;
res    = struct;

for iRep = 1:size(pRep, 1)
    guess = cell2mat(pRep(iRep,:));
    
    [param, cFVal, exitFlag, output, lambda, grad, hess] = ...
        fminconWrap(fun, guess, pMin, pMax, opt);
    
    if cFVal < fVal
        fVal = cFVal;
        
        res = packStruct(pName, param, guess, pMin, pMax, fun, params, opt, ...
                exitFlag, output, lambda, grad, hess);
    end
end

res.se = hVec(diag(inv(res.hess)));