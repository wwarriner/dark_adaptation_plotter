function [ph, lh] = draw_arrow(axh, start, stop)

% target pt/arrow
% actual pt/ax side
% actual units/ax side
% actual arrows/unit

% arrows/unit * units/ax side = arrows/ax side
HEAD_SIZE_PTS = [24 24]; % length, width
x_axis_pts = get_x_axis_pts(axh);
head_size = HEAD_SIZE_PTS ./ x_axis_pts;

% TODO make into a class
% have callback in API to hook into axes change updates
head_scale = axh.DataAspectRatio ./ axh.PlotBoxAspectRatio;

% line
x = [start(1) stop(1)];
y = [start(2) stop(2)];

x_len = (x(2) - x(1)) ./ head_scale(1);
y_len = (y(2) - y(1)) ./ head_scale(2);

theta = cart2pol(x_len, y_len);
r = rotz(rad2deg(theta));
r = r(1:2, 1:2);

% isoceles triangle
x_tri = [-1, 0, -1] .* head_size(1);
y_tri = [-0.5, 0, 0.5] .* head_size(2);
tri = (r * [x_tri; y_tri]).';
tri = tri .* head_scale(1 : 2) + stop;

ph = patch(axh, "xdata", tri(:, 1), "ydata", tri(:, 2));
ph.FaceColor = [0.0 0.0 0.0];
ph.EdgeColor = [0.0 0.0 0.0];

lh = line(axh, x, y);
lh.LineWidth = 0.5;
lh.LineStyle = "-";
lh.Color = [0.0 0.0 0.0];

end


function x_axis_pts = get_x_axis_pts(axh)

old_units = axh.Units;
unit_cleanup = onCleanup(@()restore_units(axh, old_units));
axh.Units = 'points';
x_axis_pts = axh.Position(3);
delete(unit_cleanup);

end


function restore_units(axh, units)

axh.Units = units;

end
