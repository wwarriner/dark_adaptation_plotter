classdef dapPlots < handle
    properties
        ids
    end
    
    methods
        function obj = dapPlots()
            plots = containers.Map("keytype", "char", "valuetype", "any");
            
            colors = obj.build_default_colors();
            
            obj.data = table;
            obj.plots = plots;
            obj.colors = colors;
        end
        
        function add(obj, id, plot)
            if isempty(obj.data) || ~ismember(id, obj.ids)
                row = obj.new_row(id);
                obj.data = [obj.data; row];
            else
                row = obj.data.ID == id;
                obj.data{row, "Deleted"} = false;
            end
            obj.plots(char(id)) = plot;
            obj.update_plot(row, plot);
        end
        
        function remove(obj, id)
            if isempty(obj.data) || ~ismember(id, obj.ids)
                % TODO warning?
                return;
            end
            row = obj.data.ID == id;
            obj.data{row, "Deleted"} = true;
            obj.plots.remove(char(id));
        end
        
        function plot = get(obj, id)
            plot = obj.plots(char(id));
        end
        
        function t = as_table(obj)
            t = obj.data;
            t(t.Deleted, :) = [];
            t.Deleted = [];
        end
        
        function update_visible(obj, id, visible)
            assert(isscalar(visible));
            assert(islogical(visible));
            
            row = obj.data.ID == id;
            obj.data{row, "Visible"} = visible;
            plot = obj.plots(id);
            plot.visible = visible;
            plot.update_data();
            plot.update_arrow();
        end
        
        function update_color(obj, id, color)
            assert(isa(color, "Color"));
            
            row = obj.data.ID == id;
            obj.data{row, "Color"} = color;
            plot = obj.plots(id);
            plot.color = color;
            plot.update_data();
            plot.update_arrow();
        end
        
        function update_marker(obj, id, marker)
            assert(isscalar(marker));
            assert(isstring(marker));
            assert(marker ~= "");
            
            row = obj.data.ID == id;
            obj.data{row, "Marker"} = marker;
            plot = obj.plots(id);
            plot.marker = marker;
            plot.update_data();
        end
    end
    
    methods % properties
        function ids = get.ids(obj)
            ids = string(obj.data.ID);
        end
    end
    
    properties (Access = private)
        data table
        % Deleted, ID, Visible, Color, Marker
        % Deleted - if the plot is deleted, we cache everything but data, i.e.
        % leave everything but the row, and stop showing it in the table widget
        % USER VISIBLE BELOW
        % ID - id as a double
        % Visible - if the plot is user visible
        % Color - shows the color used in the dapPlot, brings up color picker
        % Marker - shows the marker used in the dapPlot
        plots containers.Map
        
        color_counter (1,1) double = 0;
        colors (:,1) cell = {Color.RED()};
    end
    
    methods (Access = private)
        function row = new_row(obj, id)
            s.Deleted = false;
            s.ID = id;
            s.Visible = false;
            s.Color = obj.colors{obj.color_counter + 1};
            s.Marker = "d";
            row = struct2table(s);
            obj.update_color_counter();
        end
        
        function update_plot(~, row, plot)
            plot.marker = row.Marker;
            plot.color = row.Color;
        end
        
        function update_color_counter(obj)
            obj.color_counter = obj.color_counter + 1;
            obj.color_counter = mod(obj.color_counter, numel(obj.colors));
        end
    end
    
    methods (Access = public, Static)
        function colors = build_default_colors()
            % from https://www.nature.com/articles/nmeth.1618
            c = [...
                230 159 0; ...
                86 180 233; ...
                0 158 115; ...
                240 228 66; ...
                0 114 178; ...
                213 94 0; ...
                204 121 167; ...
                ];
            colors = cell(size(c, 1), 1);
            for i = 1 : size(c, 1)
                color = Color();
                color.rgb_uint8 = c(i, :);
                colors{i} = color;
            end
        end
    end
end

