classdef dapAxes < handle
    methods
        function obj = dapAxes(container_handle, config)
            callbacks = containers.Map("keytype", "char", "valuetype", "any");
            
            layout_handle = obj.build_layout(container_handle);
            axes_handle = obj.build_axes(layout_handle);
            legend_handle = obj.build_legend(axes_handle);
            
            obj.container_handle = container_handle;
            obj.layout_handle = layout_handle;
            obj.axes_handle = axes_handle;
            obj.legend_handle = legend_handle;
            
            obj.config = config;
            obj.callbacks = callbacks;
            
            obj.update();
        end
        
        function update(obj)
            x_label = obj.get_x_value("label");
            x_min = obj.get_x_value("min");
            x_step = obj.get_x_value("step");
            x_minor_step = obj.get_x_value("minor_step");
            x_max = obj.get_x_value("max");
            
            y_label = obj.get_y_value("label");
            y_min = obj.get_y_value("min");
            y_step = obj.get_y_value("step");
            y_minor_step = obj.get_y_value("minor_step");
            y_max = obj.get_y_value("max");
            
            font_name = obj.config.axes.font.name.value;
            font_size = obj.config.axes.font.size.value;
            font_weight = obj.config.axes.font.weight.value;
            font_angle = obj.config.axes.font.angle.value;
            
            h = obj.axes_handle;
            
            h.TickDir = "out";
            h.TickLength = [0.025 0.05];
            
            h.XLabel.String = x_label;
            x_min_curr = floor_to_nearest(x_min, x_step);
            x_max_curr = ceil_to_nearest(x_max, x_step);
            h.XLim = [x_min_curr x_max_curr];
            h.XTick = x_min_curr : x_step : x_max_curr;
            h.XAxis.MinorTick = "on";
            h.XAxis.MinorTickValues = x_min_curr : x_minor_step : x_max_curr;
            
            h.YLabel.String = y_label;
            y_min_curr = floor_to_nearest(y_min, y_step);
            y_max_curr = ceil_to_nearest(y_max, y_step);
            h.YLim = [y_min_curr y_max_curr];
            h.YTick = y_min_curr : y_step : y_max_curr;
            h.YAxis.MinorTick = "on";
            h.YAxis.MinorTickValues = y_min_curr : y_minor_step : y_max_curr;
            h.YAxis.Direction = "reverse";
            
            h.FontName = font_name;
            h.FontSize = font_size;
            h.FontWeight = font_weight;
            h.FontAngle = font_angle;
            
            obj.legend_handle.Location = obj.config.axes.legend.location.value;
            
            keys = string(obj.callbacks.keys());
            for i = 1 : numel(keys)
                fn = obj.callbacks(keys(i));
                fn();
            end
        end
        
        function varargout = draw_on(obj, draw_fn)
            %{
            draw_fn - a function handle which accepts an axes object
            %}
            [varargout{1:nargout}] = draw_fn(obj.axes_handle);
        end
        
        function add_to_legend(obj, handle, label)
            label = string(label);
            obj.legend_plot_handles = [obj.legend_plot_handles handle];
            obj.legend_plot_labels = [obj.legend_plot_labels label];
            obj.update_legend_contents();
            obj.update();
        end
        
        function remove_from_legend(obj, handle, ~)
            index = obj.legend_plot_handles == handle;
            obj.legend_plot_handles(index) = [];
            obj.legend_plot_labels(index) = [];
            obj.update_legend_contents();
            obj.update();
        end
        
        function register_callback(obj, tag, fn)
            obj.callbacks(char(tag)) = fn;
        end
        
        function [new_axes, new_legend] = copyobj(obj, parent_handle)
            h = [obj.axes_handle, obj.legend_handle];
            h = copyobj(h, parent_handle);
            new_axes = h(1);
            new_legend = h(2);
        end
    end
    
    properties (Access = private)
        config Config
        
        container_handle matlab.graphics.Graphics
        layout_handle matlab.graphics.layout.TiledChartLayout
        axes_handle matlab.graphics.Graphics
        legend_handle matlab.graphics.illustration.Legend
        
        legend_plot_handles matlab.graphics.Graphics
        legend_plot_labels string
        
        callbacks containers.Map
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
            h.Interpreter = "none";
            h.AutoUpdate = "off";
            legend_handle = h;
        end
        
        function update_legend_contents(obj)
            obj.legend_handle = legend(obj.axes_handle, obj.legend_plot_handles);
            if isempty(obj.legend_plot_labels)
                % HACK need to rebuild the legend to empty it out
                % setting empty string array has no effect (grays out last entry
                % instead of removing it)
                % SUBMIT BUG REPORT TO MATHWORKS
                legend(obj.axes_handle, "off");
                obj.legend_handle = obj.build_legend(obj.axes_handle);
            else
                obj.legend_handle.String = obj.legend_plot_labels;
            end
        end
        
        function v = get_x_value(obj, key)
            v = obj.config.axes.x.(key).value;
        end
        
        function v = get_y_value(obj, key)
            v = obj.config.axes.y.(key).value;
        end
    end
end

