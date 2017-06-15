function h = plot(Hover, relS)

n       = Hover.n;

if nargin < 2, relS = []; end

if ~isempty(relS)
    relSecs = Hover.relSec;
    f_s     = @(s,v) sprintf('%s%d', s, v);

    for ii = 1:n
        t_enter = relSecs.(f_s('enter', ii));
        t_exit  = relSecs.(f_s('exit', ii));

        if PsyVis.onnow(relS, t_enter, t_exit)
            Hover.color(:,ii) = Hover.colorIn(:,ii);        
        else
            Hover.color(:,ii) = Hover.colorOut(:,ii);
        end
    end
end

h = plot@PsyPTB(Hover, relS);
