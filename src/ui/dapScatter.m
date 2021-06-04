classdef dapScatter < handle
    %{
    Encapsulates a plot handle intended for display as a scatter plot. Not
    literally a MATLAB scatter handle.

    The strategy for this object is to:
    1. construct
    2. draw on an axes or uiaxes handle
    3. modify its public properties
    4. update the object
    
    % TODO rename draw() to set_parent()
    %}
    
    properties
        x (:,1) double
        y (:,1) double
        marker (1,1) string = "d"
        marker_size (1,1) double {mustBeReal,mustBeFinite,mustBePositive} = 8
        color Color = Color.BLUE()
        visible (1,1) logical = false
        legend_display_name (1,1) string = ""
    end
    
    methods
        function obj = dapScatter(x, y)
            %{
            Inputs:
            1. x - x-axis numeric vector
            2. y - y-axis numeric vector of the same length as x
            %}
            obj.plot_handle = matlab.graphics.chart.primitive.Line();
            
            if nargin == 0
                return;
            end
            
            assert(isnumeric(x));
            assert(isvector(x));
            
            assert(isnumeric(y));
            assert(isvector(y));
            
            assert(numel(x) == numel(y));
            
            x = double(x);
            y = double(y);
            
            obj.x = x;
            obj.y = y;
        end
        
        function delete(obj)
            delete(obj.plot_handle);
        end
        
        function set_parent(obj, axh)
            assert(~isempty(obj.plot_handle));
            
            assert(isscalar(axh));
            valid = isa(axh, "matlab.ui.control.UIAxes") ...
                | isa(axh, "matlab.graphics.axis.Axes");
            assert(valid);
            
            obj.plot_handle.Parent = axh;
            obj.update();
        end
        
        function update(obj)
            assert(~isempty(obj.plot_handle));
            
            h = obj.plot_handle;
            h.XData = obj.x;
            h.YData = obj.y;
            h.Marker = obj.marker;
            h.MarkerSize = obj.marker_size;
            h.MarkerFaceColor = obj.color.rgb;
            h.MarkerEdgeColor = obj.color.rgb;
            h.Color = "none";
            h.Visible = obj.visible;
            if obj.visible
                display = "on";
            else
                display = "off";
            end
            h.Annotation.LegendInformation.IconDisplayStyle = display;
            h.DisplayName = obj.legend_display_name;
        end
    end
    
    properties (Access = private)
        plot_handle matlab.graphics.chart.primitive.Line
    end
end