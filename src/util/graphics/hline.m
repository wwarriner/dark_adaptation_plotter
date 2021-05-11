function ph = hline(varargin)

if nargin == 1
    axh = gca();
    h = varargin{2};
end

if 2 <= nargin
    axh = varargin{1};
    h = varargin{2};
end

x = axh.XLim;
y = [h h];
ph = plot(axh, x, y, "-");

end
