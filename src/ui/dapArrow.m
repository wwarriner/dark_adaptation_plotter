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
        head_size_pt (1,1) double {mustBeReal,mustBeFinite,mustBePositive} = 24 % x,y pair
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
            
            X = 1; Y = 2;
            TAIL = 1; HEAD = 2;
            
            s = obj.get_scale_data_per_pt(); % multiply to convert pt -> data
            
            % compute line
            line = [obj.tail; obj.head]; % data
            
            % find pt-space angle of line
            inv_line = (s^(-1) * line.').'; % data -> pt
            d_inv_line = diff(inv_line); % pt
            theta_inv_line = cart2pol(d_inv_line(X), d_inv_line(Y)); % pt
            
            % compute head triangle
            BASE_TRIANGLE = [-1 -0.5; 0 0; -1 0.5]; % origin is at tip, unitless
            tri = BASE_TRIANGLE .* obj.head_size_pt .* ones([1 2]); % pt
            r = obj.compute_rotation_matrix(theta_inv_line); % pt
            tri = (s * r * tri.').'; % pt -> data
            tri = tri + obj.head; % data
            
            % move head of line to base of head triangle to avoid line visible
            % at tip of triangle
            m = mean(tri([1 3], :)); % mid-base, data
            a = tri(2, :); % apex, data
            d_tri = sqrt(sum((m-a).^2)); % data
            d_line = diff(line); % data
            [theta_line, r_line] = cart2pol(d_line(X), d_line(Y)); % data
            r_line = r_line - d_tri; % data
            [d_x, d_y] = pol2cart(theta_line, r_line); % data
            line(HEAD, X) = line(TAIL, X) + d_x; % data
            line(HEAD, Y) = line(TAIL, Y) + d_y; % data
            
            % update
            h = obj.head_handle;
            h.XData = tri(:, X);
            h.YData = tri(:, Y);
            h.FaceColor = obj.color.rgb;
            h.EdgeColor = "none";
            h.Annotation.LegendInformation.IconDisplayStyle = "off";
            h.Visible = obj.visible;
            
            h = obj.line_handle;
            h.XData = line(:, X);
            h.YData = line(:, Y);
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
    
    properties (Access = private, Constant)
        
    end
    
    methods (Access = private)
        function scale = get_scale_data_per_pt(obj)
            d_ax_pts = obj.get_axes_length_pts(); % pt
            d_ax_data = obj.get_axes_length_data(); % data
            scale = d_ax_data ./ d_ax_pts; % data/pt
            scale = [...
                scale(1) 0; ...
                0 scale(2); ...
                ];
        end
        
        function d = get_axes_length_data(obj)
            axh = obj.axes_handle;
            d = diff([axh.XLim; axh.YLim].');
        end
        
        function d = get_axes_length_pts(obj)
            axh = obj.axes_handle;
            old_units = axh.Units;
            unit_cleanup = onCleanup(@()dapArrow.restore_units(axh, old_units));
            axh.Units = 'points';
            d = axh.InnerPosition(3:4);
        end
    end
    
    methods (Access = private, Static)
        function r = compute_rotation_matrix(theta)
            r = rotz(rad2deg(theta));
            r = r(1:2, 1:2);
        end
        
        function restore_units(axh, units)
            axh.Units = units;
        end
    end
end

