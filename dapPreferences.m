classdef dapPreferences < handle
    methods
        function obj = dapPreferences(config)
            callbacks = containers.Map("keytype", "char", "valuetype", "any");
            
            obj.config = config;
            obj.callbacks = callbacks;
        end
        
        function register_callback(obj, tag, callback_fn)
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
        
        function ui_update_preferences(obj, x, y)
            old_config = obj.config.copy();
            
            % PREPARE FIGURE
            f = uifigure();
            f.Scrollable = "on";
            W = 440;
            H = 300;
            y = y - H;
            f.Position = [x y W H];
            f.WindowStyle = "alwaysontop";
            f.Resize = "off";
            f.Name = "Preferences";
            
            % CREATE SCROLLABLE PANEL
            p = uipanel(f);
            y = 2 .* obj.PAD + obj.HEIGHT;
            w = f.Position(3);
            h = f.Position(4) - y + 1;
            p.Position = [1 y w h];
            total_height = p.Position(4);
            
            % CREATE PREF FIELDS
            pref_declarations = read_json_file("prefs.json");
            pref_keys = fieldnames(pref_declarations);
            pref_count = numel(pref_keys);
            
            fields = prefField.empty(pref_count, 0);
            for index = 1 : pref_count
                pref_decl = pref_declarations.(pref_keys{index});
                pf = prefField(p, pref_decl, obj.config, @obj.push_update);
                pf.label.Position = dapPreferences.index_to_label_position(total_height, index);
                pf.ui.Position = dapPreferences.index_to_ui_position(total_height, index);
                pf.update_from_config();
                fields(index) = pf;
            end
            
            % RESET BUTTON
            reset = uibutton(f);
            reset.Text = "Reset to Default";
            reset.Position = [obj.PAD, obj.PAD, obj.W_LEFT_BUTTON, obj.HEIGHT];
            reset.ButtonPushedFcn = @(~, ~)obj.reset_to_default_callback_fn(fields);
            
            % ACCEPT BUTTON
            count = 2;
            x = count .* obj.PAD + count .* obj.W_RIGHT_BUTTON;
            x = f.Position(3) - x;
            accept = uibutton(f);
            accept.Text = "Accept";
            accept.Position = [x, obj.PAD, obj.W_RIGHT_BUTTON, obj.HEIGHT];
            accept.ButtonPushedFcn = @(~, ~)obj.accept_callback_fn(f);
            
            % CANCEL BUTTON
            w = obj.W_RIGHT_BUTTON;
            x = x + obj.PAD + obj.W_RIGHT_BUTTON;
            cancel = uibutton(f);
            cancel.Text = "Cancel";
            cancel.Position = [x, obj.PAD, w, obj.HEIGHT];
            cancel.ButtonPushedFcn = @(~, ~)obj.cancel_callback_fn(old_config, f);
            
            % WAIT FOR USER TO FINISH
            uiwait(f);
        end
    end
    
    properties (Access = private)
        config Config
        callbacks containers.Map
    end
    
    properties (Access = private, Constant)
        PAD = 6;
        W_LABEL = 200;
        
        X_UI = 2.* dapPreferences.PAD + dapPreferences.W_LABEL;
        W_UI = 200;
        
        W_RIGHT_BUTTON = 48;
        W_LEFT_BUTTON = 96;
        
        HEIGHT = 23;
    end
    
    methods (Access = private)
        function push_update(obj)
            keys = string(obj.callbacks.keys());
            for i = 1 : numel(keys)
                fn = obj.callbacks(keys(i));
                fn();
            end
        end
        
        function accept_callback_fn(obj, figure_handle)
            obj.config.save();
            delete(figure_handle);
        end
        
        function cancel_callback_fn(obj, old_config, figure_handle)
            old_config.apply_to(obj.config);
            obj.push_update();
            delete(figure_handle);
        end
        
        function reset_to_default_callback_fn(~, fields)
            for i = 1 : numel(fields)
                field = fields(i);
                field.reset_to_default();
            end
        end
    end
       
    methods (Access = private, Static)
        function pos = index_to_label_position(total_height, index)
            y = dapPreferences.index_to_y(total_height, index);
            pos = [dapPreferences.PAD, y, dapPreferences.W_LABEL, dapPreferences.HEIGHT];
        end
        
        function pos = index_to_ui_position(total_height, index)
            y = dapPreferences.index_to_y(total_height, index);
            pos = [dapPreferences.X_UI, y, dapPreferences.W_UI, dapPreferences.HEIGHT];
        end
        
        function y = index_to_y(total_height, index)
            y = total_height - (dapPreferences.HEIGHT .* index + dapPreferences.PAD .* index);
        end
    end
end

