classdef dapPreferences < handle
    methods
        function obj = dapPreferences(config, size_px)
            if nargin < 2
                size_px = [440 300];
            end
            
            assert(all(size_px == fix(size_px)));
            
            callbacks = containers.Map("keytype", "char", "valuetype", "any");
            
            obj.config = config;
            obj.size_px = size_px;
            obj.callbacks = callbacks;
        end
        
        function register_callback(obj, tag, callback_fn)
            % callback_fn takes no arguments and returns nothing
            % used to call argument-less update functions on objects
            obj.callbacks(char(tag)) = callback_fn;
        end
        
        function ui_update_font(obj)
            % creates font dialog and updates config with user selection
            f = obj.config.axes.font;
            s.FontName = f.name.value;
            s.FontSize = f.size.value;
            s.FontWeight = f.weight.value;
            s.FontAngle = f.angle.value;
            
            s = uisetfont(s);
            if isnumeric(s); return; end
            
            f.name = s.FontName;
            f.size = s.FontSize;
            f.weight = s.FontWeight;
            f.angle = s.FontAngle;
            obj.push_update();
        end
        
        function ui_update_preferences(obj, app_window_x, app_window_y)
            old_config = obj.config.copy();
            f = obj.create_figure(app_window_x, app_window_y, old_config);
            p = obj.create_panel(f);
            fields = obj.add_pref_fields(p);
            obj.create_buttons(f, fields, old_config);
            uiwait(f);
        end
    end
    
    properties (Access = private)
        config Config
        size_px(1,2) double {mustBeReal,mustBeFinite,mustBeNonnegative}
        callbacks containers.Map
    end
    
    properties (Access = private, Constant)
        PAD = 6;
        W_LABEL = 200;
        
        X_UI = 2 .* dapPreferences.PAD + dapPreferences.W_LABEL;
        
        GUTTER_W = 3 .* dapPreferences.PAD;
        
        W_RIGHT_BUTTON = 48;
        W_LEFT_BUTTON = 96;
        
        BUTTON_H = 23;
    end
    
    methods (Access = private)
        function push_update(obj)
            % pushes changes by calling all registered callbacks
            keys = string(obj.callbacks.keys());
            for i = 1 : numel(keys)
                fn = obj.callbacks(keys(i));
                fn();
            end
        end
        
        function accept_callback_fn(obj, figure_handle)
            % saves config if accept pushed
            obj.config.save();
            delete(figure_handle);
        end
        
        function cancel_callback_fn(obj, old_config, figure_handle)
            % restored old config if cancel pushed
            old_config.apply_to(obj.config);
            obj.push_update();
            delete(figure_handle);
        end
        
        function reset_to_default_callback_fn(~, fields)
            % sets all fields to default values if reset pushed
            for i = 1 : numel(fields)
                field = fields(i);
                field.reset_to_default();
            end
        end
        
        function f = create_figure(obj, x, y, old_config)
            f = uifigure();
            f.Scrollable = "on";
            w = obj.size_px(1);
            h = obj.size_px(2);
            y = y - h;
            f.Position = [x y w h];
            f.WindowStyle = "alwaysontop";
            f.Resize = "off";
            f.Name = "Preferences";
            %f.CloseRequestFcn = @(~, ~)obj.cancel_callback_fn(old_config, f);
        end
        
        function p = create_panel(obj, parent)
            p = uipanel(parent);
            y = 2 .* obj.PAD + obj.BUTTON_H; % bottom button row
            w = parent.Position(3);
            h = parent.Position(4) - y + 1;
            p.Position = [1 y w h];
            p.Scrollable = true;
        end
        
        function fields = add_pref_fields(obj, parent)
            pref_declarations = read_json_file("prefs.json");
            pref_keys = fieldnames(pref_declarations);
            pref_count = numel(pref_keys);
            
            total_height = obj.total_height(pref_count);
            
            % HACK - empty uilabel because scrollability doesn't respect the top pad
            uih = uilabel(parent);
            uih.Position(2) = obj.index_to_y(total_height, 1) + obj.PAD;
            uih.Text = "";
            
            fields = prefField.empty(pref_count, 0);
            for index = 1 : pref_count
                pref_decl = pref_declarations.(pref_keys{index});
                pf = prefField(parent, pref_decl, obj.config, @obj.push_update);
                pf.label.Position = obj.index_to_label_position(total_height, index);
                pf.ui.Position = obj.index_to_ui_position(total_height, obj.size_px(1), index);
                pf.update_from_config();
                fields(index) = pf;
            end
        end
        
        function create_buttons(obj, parent, fields, old_config)
            % RESET
            reset = uibutton(parent);
            reset.Text = "Reset to Default";
            reset.Position = [obj.PAD, obj.PAD, obj.W_LEFT_BUTTON, obj.BUTTON_H];
            reset.ButtonPushedFcn = @(~, ~)obj.reset_to_default_callback_fn(fields);
            
            % ACCEPT
            count = 2;
            x = count .* obj.PAD + count .* obj.W_RIGHT_BUTTON;
            x = parent.Position(3) - x;
            accept = uibutton(parent);
            accept.Text = "Accept";
            accept.Position = [x, obj.PAD, obj.W_RIGHT_BUTTON, obj.BUTTON_H];
            accept.ButtonPushedFcn = @(~, ~)obj.accept_callback_fn(parent);
            
            % CANCEL
            w = obj.W_RIGHT_BUTTON;
            x = x + obj.PAD + obj.W_RIGHT_BUTTON;
            cancel = uibutton(parent);
            cancel.Text = "Cancel";
            cancel.Position = [x, obj.PAD, w, obj.BUTTON_H];
            cancel.ButtonPushedFcn = @(~, ~)obj.cancel_callback_fn(old_config, parent);
        end
    end
       
    methods (Access = private, Static)
        function pos = index_to_label_position(total_height, index)
            y = dapPreferences.index_to_y(total_height, index);
            pos = [dapPreferences.PAD, y, dapPreferences.W_LABEL, dapPreferences.BUTTON_H];
        end
        
        function pos = index_to_ui_position(total_height, width, index)
            y = dapPreferences.index_to_y(total_height, index);
            w = width - dapPreferences.W_LABEL - (3 .* dapPreferences.PAD) - dapPreferences.GUTTER_W;
            pos = [dapPreferences.X_UI, y, w, dapPreferences.BUTTON_H];
        end
        
        function y = index_to_y(total_height, index)
            y = total_height - (dapPreferences.BUTTON_H .* index + dapPreferences.PAD .* (index + 1));
        end
        
        function h = total_height(count)
            h = (dapPreferences.BUTTON_H .* count) + (dapPreferences.PAD * (count + 2));
        end
    end
end

