function scatter_factor(x,y,plot_args)
% scatter_2x2({x1,x2}, {y1,y2}, plot_args='.')

if nargin < 3, plot_args = {'.'}; end

nR = length(y);
nC = length(x);

for r = 1:nR
    for c = 1:nC
        subplotRC(nR,nC,r,c);
        
        plot(x{r}, y{c}, plot_args{:});
    end
end
