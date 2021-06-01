classdef dapScatter < handle
    %{
    Encapsulates a plot handle intended for display as a scatter plot. Not
    literally a MATLAB scatter handle.

    The strategy for this object is to:
    1. construct
    2. draw on one or more axes
    3. modify its public properties
    4. update the object
    %}
    
    properties
        marker (1,1) string = "d"
        marker_size (1,1) double {mustBeReal,mustBeFinite,mustBePositive} = 8
        color Color = Color.BLUE()
        visible (1,1) logical = false
        display_name (1,1) string = ""
    end
    
    methods
        function obj = dapScatter(x, y)
            %{
            Inputs:
            1. x - x-axis numeric vector
            2. y - y-axis numeric vector of the same length as x
            %}
            obj.x = x;
            obj.y = y;
        end
        
        function delete(obj)
            delete(obj.plot_handle);
        end
        
        function draw(obj, axh)
            %{
            Draws this object onto an axes or uiaxes.
            %}
            assert(isa(axh, "matlab.graphics.axis.Axes"));
            
            ph = plot(axh, obj.x, obj.y);
            ph.Annotation.LegendInformation.IconDisplayStyle = "off";
            obj.plot_handle = ph;
            
            obj.update();
        end
        
        function update(obj)
            assert(~isempty(obj.plot_handle));
            
            h = obj.plot_handle;
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
            h.DisplayName = obj.display_name;
        end
    end
    
    properties (Access = private)
        plot_handle matlab.graphics.chart.primitive.Line
        
        x (:,1) double
        y (:,1) double
    end
end

