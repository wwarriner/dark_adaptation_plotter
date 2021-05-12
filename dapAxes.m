classdef dapAxes < handle
    properties
        x_label (1,1) string = "Minutes following photobleach"
        x_min (1,1) double {mustBeReal,mustBeFinite} = 0.0
        x_step (1,1) double {mustBeReal,mustBeFinite} = 5.0
        x_minor_step (1,1) double {mustBeReal,mustBeFinite} = 1.0
        x_max (1,1) double {mustBeReal,mustBeFinite} = 25.0
        
        y_label (1,1) string = "Log Sensitivity"
        y_min (1,1) double {mustBeReal,mustBeFinite} = 0.0
        y_step (1,1) double {mustBeReal,mustBeFinite} = 0.5
        y_minor_step (1,1) double {mustBeReal,mustBeFinite} = 0.1
        y_max (1,1) double {mustBeReal,mustBeFinite} = 4.5
    end
    
    methods
        function obj = dapAxes(fh)
            axh = axes(fh);
            hold(axh, "on");
            
            obj.figure_handle = fh;
            obj.axes_handle = axh;
            
            obj.update();
        end
        
        function update(obj)
            x_min_curr = floor_to_nearest(obj.x_min, obj.x_step);
            x_max_curr = ceil_to_nearest(obj.x_max, obj.x_step);
            
            y_min_curr = floor_to_nearest(obj.y_min, obj.y_step);
            y_max_curr = ceil_to_nearest(obj.y_max, obj.y_step);
            
            h = obj.axes_handle;
            
            h.XLabel.String = obj.x_label;
            h.XLim = [x_min_curr x_max_curr];
            h.XTick = x_min_curr : obj.x_step : x_max_curr;
            h.XAxis.MinorTick = "on";
            h.XAxis.MinorTickValues = x_min_curr : obj.x_minor_step : x_max_curr;
            
            h.YLabel.String = obj.y_label;
            h.YLim = [y_min_curr y_max_curr];
            h.YTick = y_min_curr : obj.y_step : y_max_curr;
            h.YAxis.MinorTick = "on";
            h.YAxis.MinorTickValues = y_min_curr : obj.y_minor_step : y_max_curr;
            h.YAxis.Direction = "reverse";
        end
        
        function draw_on(obj, draw_fn)
            %{
            draw_fn - a function handle which accepts an axes object
            %}
            draw_fn(obj.axes_handle);
        end
    end
    
    properties (Access = private)
        figure_handle matlab.graphics.Graphics
        axes_handle matlab.graphics.Graphics
    end
    
    methods (Access = private)
        
    end
end
