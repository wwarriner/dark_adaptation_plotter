classdef dapArrow < handle
    %{
    Encapsulates line and patch handles intended for display as an arrow.
    
    The strategy for this object is to:
    1. construct
    2. draw on an axes or uiaxes handle
    3. modify its public properties
    4. update the object
    %}
    properties
        head (1,2) double % x,y pair
        tail (1,2) double % x,y pair
        line_width (1,1) double {mustBeReal,mustBeFinite,mustBePositive} = 2
        head_size_pt (1,2) double {mustBeReal,mustBeFinite,mustBePositive} = [24 24] % x,y pair
        color Color = Color.BLUE()
        visible (1,1) logical = false;
    end
    
    methods
        function obj = dapArrow(head, tail)
            %{
            Inputs:
            1. head - numeric x,y position of arrow head
            2. tail - numeric x,y position of arrow tail
            %}
            obj.head_handle = matlab.graphics.primitive.Patch();
            obj.line_handle = matlab.graphics.primitive.Line();
            
            if nargin == 0
                return;
            end
            
            assert(isnumeric(head));
            assert(isvector(head));
            assert(numel(head) == 2);
            
            assert(isnumeric(tail));
            assert(isvector(tail));
            assert(numel(tail) == 2);
            
            head = double(head);
            tail = double(tail);
            
            obj.head = head;
            obj.tail = tail;
        end
        
        function delete(obj)
            delete(obj.head_handle);
            delete(obj.line_handle);
        end
        
        function set_parent(obj, axh)
            assert(~isempty(obj.head_handle));
            assert(~isempty(obj.line_handle));
            
            assert(isscalar(axh));
            valid = isa(axh, "matlab.ui.control.UIAxes") ...
                | isa(axh, "matlab.graphics.axis.Axes");
            assert(valid);
            
            obj.line_handle.Parent = axh;
            obj.head_handle.Parent = axh;
            obj.axes_handle = axh;
            obj.update();
        end
        
        function update(obj)
            assert(~isempty(obj.head_handle));
            assert(~isempty(obj.line_handle));
            
            if isempty(obj.axes_handle)
                return;
            end
            
            scale = obj.get_scale(obj.axes_handle);
            [x_line, y_line] = obj.compute_line();
            r = obj.compute_rotation_matrix(x_line, y_line, scale);
            extent = compute_extent(obj, obj.axes_handle);
            [x_tri, y_tri] = obj.compute_triangle(r, scale, extent);
            
            h = obj.head_handle;
            h.XData = x_tri;
            h.YData = y_tri;
            h.FaceColor = obj.color.rgb;
            h.EdgeColor = obj.color.rgb;
            h.Annotation.LegendInformation.IconDisplayStyle = "off";
            h.Visible = obj.visible;
            
            h = obj.line_handle;
            h.XData = x_line;
            h.YData = y_line;
            h.Color = obj.color.rgb;
            h.LineWidth = obj.line_width;
            h.Annotation.LegendInformation.IconDisplayStyle = "off";
            h.Visible = obj.visible;
        end
    end
    
    properties (Access = private)
        head_handle matlab.graphics.primitive.Patch
        line_handle matlab.graphics.primitive.Line
        axes_handle
    end
    
    methods (Access = private)
        function [x, y] = compute_line(obj)
            x = [obj.tail(1) obj.head(1)];
            y = [obj.tail(2) obj.head(2)];
        end
        
        function [x, y] = compute_triangle(obj, r, scale, extent)
            x_tri = [-1, 0, -1] .* extent(1);
            y_tri = [-0.5, 0, 0.5] .* extent(2);
            
            tri = (r * [x_tri; y_tri]).';
            tri = tri .* scale(1 : 2) + obj.head;
            
            x = tri(:, 1);
            y = tri(:, 2);
        end
        
        function extent = compute_extent(obj, axh)
            x_axis_pts = obj.get_x_axis_pts(axh);
            extent = obj.head_size_pt ./ x_axis_pts;
        end
    end
    
    methods (Access = private, Static)
        function r = compute_rotation_matrix(x_line, y_line, scale)
            x_len = (x_line(2) - x_line(1)) ./ scale(1);
            y_len = (y_line(2) - y_line(1)) ./ scale(2);
            
            theta = cart2pol(x_len, y_len);
            r = rotz(rad2deg(theta));
            r = r(1:2, 1:2);
        end
        
        function scale = get_scale(axh)
            scale = axh.DataAspectRatio ./ axh.PlotBoxAspectRatio;
        end
        
        function x_axis_pts = get_x_axis_pts(axh)
            old_units = axh.Units;
            unit_cleanup = onCleanup(@()dapArrow.restore_units(axh, old_units));
            axh.Units = 'points';
            x_axis_pts = axh.Position(3);
        end
        
        function restore_units(axh, units)
            axh.Units = units;
        end
    end
end

