function c = red(m)
% Creates a white to red colormap. Based on redblue by Adam Auton see
% redblue function for more information

if nargin < 1, m = size(get(gcf,'colormap'),1); end
    b = flipud((0:m)'/max(m,1));
    g = b;
    r = (ones(size(b)));
c = [r g b];