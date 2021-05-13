classdef dapScatter < handle
    properties
        marker (1,1) string = "d"
        marker_size (1,1) double {mustBeReal,mustBeFinite,mustBePositive} = 8
        
        color Color = Color.BLUE()
        visible (1,1) logical = false
    end
    
    methods
        function obj = dapScatter(x, y)
            obj.x = x;
            obj.y = y;
        end
        
        function delete(obj)
            delete(obj.plot_handle);
        end
        
        function draw(obj, axh)
            assert(isa(axh, "matlab.graphics.axis.Axes"));
            
            ph = plot(axh, obj.x, obj.y);
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
        end
    end
    
    properties (Access = private)
        plot_handle matlab.graphics.chart.primitive.Line
        
        x (:,1) double
        y (:,1) double
    end
end

