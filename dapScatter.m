classdef dapScatter < handle
    properties
        marker (1,1) string = "d"
        marker_size (1,1) double {mustBeReal,mustBeFinite,mustBePositive} = 8
        color Color = Color.BLUE()
        visible (1,1) logical = false
        display_name (1,1) string = ""
    end
    
    methods
        function obj = dapScatter(x, y)
            assert(isnumeric(x));
            assert(isvector(x));
            
            assert(isnumeric(y));
            assert(isvector(y));
            
            assert(numel(x) == numel(y));
            
            x = double(x);
            y = double(y);
            
            obj.x = x;
            obj.y = y;
            obj.plot_handle = matlab.graphics.chart.primitive.Line;
        end
        
        function delete(obj)
            delete(obj.plot_handle);
        end
        
        function draw(obj, axh)
            assert(isa(axh, "matlab.graphics.axis.Axes"));
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
