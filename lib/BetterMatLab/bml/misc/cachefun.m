function varargout = cachefun(fun, args)
% varargout = cachefun(fun, args)

persistent prevQuerry prevRes

querry = {fun, args};
nPrev  = length(prevQuerry);

for ii = 1:nPrev
    if isequaln(querry, prevQuerry{ii})
        if length(prevRes{ii}) >= nargout
            [varargout(1:nargout)] = prevRes{ii}(1:nargout);
            return;
        else
            break;
        end
    end
end

%% Add new results
nPrev = nPrev + 1;
prevQuerry{nPrev} = querry;
[prevRes{nPrev}{1:nargout}] = fun(args{:});

varargout(1:nargout) = prevRes{nPrev}(1:nargout);