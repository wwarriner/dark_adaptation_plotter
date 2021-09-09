classdef dapPlotTable < handle
    properties (Dependent)
        ids
        row_count
    end
    
    properties (Constant)
        ID_COL = 1;
        VISIBLE_COL = 2;
        COLOR_COL = 3;
        MARKER_COL = 4;
        SIZE_COL = 5;
        
        WIDTH_WEIGHTS = [96 32 48 60 32];
    end
    
    methods
        function obj = dapPlotTable(ui_t)
            available_markers = obj.build_marker_map();
            default_colors = obj.build_default_colors();
            
            eye_emoji = compose("\xD83D\xDC41\xFE0F");
            ui_t.ColumnName = {'ID', eye_emoji, 'Color', 'Marker', 'Size'};
            ui_t.ColumnEditable = [false true false true true];
            ui_t.ColumnSortable = [false false false false false];
            ui_t.ColumnFormat = {'char', 'logical', 'char', available_markers.keys(), 'numeric'};
            
            styles = StyleManager(ui_t);
            rows = containers.Map("keytype", "char", "valuetype", "double");
            
            obj.ui_t = ui_t;
            obj.styles = styles;
            obj.rows = rows;
            obj.available_markers = available_markers;
            obj.default_colors = default_colors;
        end
        
        function add(obj, ids)
            %{
            Inputs
            1. ids - string-like array of ids. Must not contain duplicates. Must
            not contain duplicates of data already held.
            %}
            assert(length(ids) == length(unique(ids)));
            for id = ids(:).'
                assert(~obj.styles.has_style(id));
            end
            
            ids = natsort(ids);
            
            % create new data
            count = numel(ids);
            new_data = cell(count, 5);
            new_style = cell(count, 1);
            i = 0;
            for id = ids(:).'
                i = i + 1;
                [color, marker] = obj.next_appearance();
                new_data(i, :) = obj.build_new_row(id, marker);
                new_style{i} = obj.build_new_style(color);
            end
            new_count = i;
            
            % add new data
            start_index = size(obj.ui_t.Data, 1);
            obj.ui_t.Data = [obj.ui_t.Data; new_data];
            for i = 1 : new_count
                id = new_data{i, obj.ID_COL};
                row_index = start_index + i;
                obj.styles.add_style(id, new_style{i}, "cell", [row_index obj.COLOR_COL]);
                obj.rows(id) = row_index;
            end
        end
        
        function remove(obj, row)
            obj.ui_t.Data(row, :) = [];
            id = obj.row_to_id(row);
            obj.styles.remove_style(id);
            obj.rows.remove(id);
        end
        
        function clear(obj)
            obj.ui_t.Data = {};
            obj.styles.clear();
            obj.rows = containers.Map("keytype", "char", "valuetype", "double");
            obj.appearance_counter = 0;
        end
        
        function id = get_id(obj, row)
            id = obj.ui_t.Data{row, obj.ID_COL};
        end
        
        function visible = get_visible(obj, row)
            visible = obj.ui_t.Data{row, obj.VISIBLE_COL};
        end
        
        function color = get_color(obj, row)
            id = obj.row_to_id(row);
            style = obj.styles.get_style(id);
            color = Color();
            color.rgb = style.BackgroundColor;
        end
        
        function set_color(obj, row, color)
            id = obj.row_to_id(row);
            style = obj.styles.get_style(id);
            style.BackgroundColor = color.rgb;
            obj.styles.update_style(id, style);
        end
        
        function marker = get_marker(obj, row)
            display_marker = obj.ui_t.Data{row, obj.MARKER_COL};
            marker = string(obj.available_markers(display_marker));
        end
        
        function size = get_size(obj, row)
            size = obj.ui_t.Data{row, obj.SIZE_COL};
        end
    end
    
    methods % properties
        function value = get.ids(obj)
            value = string(obj.rows.keys());
        end
        
        function value = get.row_count(obj)
            value = size(obj.ui_t.Data, 1);
        end
    end
    
    properties (Access = private)
        ui_t matlab.ui.control.Table
        styles StyleManager
        rows containers.Map
        
        available_markers containers.Map
        appearance_counter (1,1) double = 0;
        default_colors (:,1) cell = {Color.RED()};
    end
    
    methods (Access = private)
        function id = row_to_id(obj, row)
            id = obj.ui_t.Data{row, obj.ID_COL};
        end
        
        function row = id_to_row(obj, id)
            row = obj.rows(id);
        end
        
        function row = build_new_row(obj, id, marker)
            % add new row to table
            row = cell(1, 5);
            row{obj.ID_COL} = char(id);
            row{obj.VISIBLE_COL} = false;
            row{obj.COLOR_COL} = '';
            row{obj.MARKER_COL} = char(marker);
            row{obj.SIZE_COL} = 8;
        end
        
        function style = build_new_style(~, color)
            style = uistyle();
            style.BackgroundColor = color.rgb;
        end
        
        function [color, marker] = next_appearance(obj)
            color = obj.default_colors{obj.appearance_counter + 1};
            markers = obj.build_markers();
            markers = string(markers(:, 2));
            marker = markers(obj.appearance_counter + 1);
            obj.update_appearance_counter();
        end
        
        function update_appearance_counter(obj)
            obj.appearance_counter = obj.appearance_counter + 1;
            obj.appearance_counter = mod(obj.appearance_counter, numel(obj.default_colors));
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
        
        function markers = build_marker_map()
            markers = dapPlotTable.build_markers();
            markers = containers.Map(markers(:, 2), markers(:, 1));
        end
        
        function markers = build_markers()
            markers = {...
                'd', char(9670); ... % black diamond UTF-16 0x25c6
                'o', char(9679); ... % black circle UTF-16 0x25cf
                ...'+', char(43); ... % plus sign UTF-16 0x2b
                ...'*', char(10033); ... % heavy asterisk UTF-16 0x2731
                ...'x', char(215); ... % multiplication sign UTF-16 0xd7
                's', char(9632); ... % black square UTF-16 0x25a0
                '^', char(9650); ... % black up-pointing triangle UTF-16 0x25b2
                'v', char(9660); ... % black down-pointing triangle UTF-16 0x25bc
                '>', char(9654); ... % black right-pointing triangle UTF-16 0x25b6
                '<', char(9664); ... % black left-pointing triangle UTF-16 0x25c0
                'p', char(9733); ... % black star UTF-16 0x2605
                };
        end
    end
end

