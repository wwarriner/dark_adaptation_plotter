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
        
        FontName (1,1) string
        FontSize (1,1) double
        FontWeight (1,1) string
        FontAngle (1,1) string
    end
    
    methods
        function obj = dapAxes(container_handle)
            layout_handle = obj.build_layout(container_handle);
            axes_handle = obj.build_axes(layout_handle);
            legend_handle = obj.build_legend(axes_handle);
            
            obj.container_handle = container_handle;
            obj.layout_handle = layout_handle;
            obj.axes_handle = axes_handle;
            obj.legend_handle = legend_handle;
            
            obj.update();
        end
        
        function update(obj)
            x_min_curr = floor_to_nearest(obj.x_min, obj.x_step);
            x_max_curr = ceil_to_nearest(obj.x_max, obj.x_step);
            
            y_min_curr = floor_to_nearest(obj.y_min, obj.y_step);
            y_max_curr = ceil_to_nearest(obj.y_max, obj.y_step);
            
            h = obj.axes_handle;
            
            h.TickDir = "out";
            h.TickLength = [0.025 0.05];
            
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
        
        function varargout = draw_on(obj, draw_fn)
            %{
            draw_fn - a function handle which accepts an axes object
            %}
            [varargout{1:nargout}] = draw_fn(obj.axes_handle);
        end
        
        function [new_axes, new_legend] = copyobj(obj, parent_handle)
            h = [obj.axes_handle, obj.legend_handle];
            h = copyobj(h, parent_handle);
            new_axes = h(1);
            new_legend = h(2);
        end
        
        function update_font(obj)
            h = obj.axes_handle;
            h.FontName = obj.FontName;
            h.FontSize = obj.FontSize;
            h.FontWeight = obj.FontWeight;
            h.FontAngle = obj.FontAngle;
        end
    end
    
    properties (Access = private)
        container_handle matlab.graphics.Graphics
        layout_handle matlab.graphics.layout.TiledChartLayout
        axes_handle matlab.graphics.Graphics
        legend_handle matlab.graphics.illustration.Legend
    end
    
    properties (Access = private, Constant)
        LAYOUT_M = 1;
        LAYOUT_N = 3;
        AXES_TILE_SPAN (1,2) double = [dapAxes.LAYOUT_M dapAxes.LAYOUT_N-1];
        LEGEND_TILE_SPAN (1,2) double = [dapAxes.LAYOUT_M dapAxes.LAYOUT_N];
        LEGEND_TILE (1,1) double = 2; % NO idea why this works and 3 doesn't.
    end
    
    methods (Access = private)
        function layout_handle = build_layout(obj, container_handle)
            h = tiledlayout(container_handle, obj.LAYOUT_M, obj.LAYOUT_N);
            h.Padding = "tight";
            h.TileSpacing = "tight";
            layout_handle = h;
        end
        
        function axes_handle = build_axes(obj, layout_handle)
            h = nexttile(layout_handle, 1, obj.AXES_TILE_SPAN);
            hold(h, "on");
            h.Units = "pixels";
            h.Box = "on";
            h.PlotBoxAspectRatio = [1 1 1];
            h.Interactions = [];
            h.Toolbar = [];
            axes_handle = h;
        end
        
        function legend_handle = build_legend(obj, axes_handle)
            h = legend(axes_handle);
            h.Location = "layout";
            h.Layout.TileSpan = obj.LEGEND_TILE_SPAN;
            h.Layout.Tile = obj.LEGEND_TILE;
            h.Units = "pixels";
            legend_handle = h;
        end
    end
end

