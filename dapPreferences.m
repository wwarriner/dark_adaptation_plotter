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
            
            f = uifigure();
            f.Scrollable = "on";
            W = 440;
            H = 300;
            y = y - H;
            f.Position = [x y W H];
            f.WindowStyle = "modal";
            f.Resize = "off";
            
            p = uipanel(f);
            y = 2 .* obj.PAD + obj.HEIGHT;
            w = f.Position(3);
            h = f.Position(4) - y + 1;
            p.Position = [1 y w h];
            total_height = p.Position(4);
            
            index = 0;
            fields = prefField.empty();
            
            index = index + 1;
            label_pos = dapPreferences.index_to_label_position(total_height, index);
            ui_pos = dapPreferences.index_to_ui_position(total_height, index);
            x_title = prefField(p, obj.config.axes.x.label, @uieditfield, @obj.push_update);
            x_title.label.Position = label_pos;
            x_title.label.Text = "X axis title";
            x_title.ui.Position = ui_pos;
            x_title.update_from_config();
            fields(index) = x_title;
            
            index = index + 1;
            label_pos = dapPreferences.index_to_label_position(total_height, index);
            ui_pos = dapPreferences.index_to_ui_position(total_height, index);
            x_max = prefField(p, obj.config.axes.x.max, @uispinner, @obj.push_update);
            x_max.label.Text = "X axis maximum";
            x_max.label.Position = label_pos;
            x_max.ui.Value = obj.config.axes.x.max.value;
            x_max.ui.Limits = [obj.config.axes.x.min.value inf];
            x_max.ui.Step = obj.config.axes.x.step.value;
            x_max.ui.RoundFractionalValues = "on";
            x_max.ui.ValueDisplayFormat = "%d";
            x_max.ui.LowerLimitInclusive = "off";
            x_max.ui.UpperLimitInclusive = "off";
            x_max.ui.Position = ui_pos;
            x_max.update_from_config();
            fields(index) = x_max;
            
            index = index + 1;
            label_pos = dapPreferences.index_to_label_position(total_height, index);
            ui_pos = dapPreferences.index_to_ui_position(total_height, index);
            y_title = prefField(p, obj.config.axes.y.label, @uieditfield, @obj.push_update);
            y_title.label.Text = "Y axis title";
            y_title.label.Position = label_pos;
            y_title.ui.Value = obj.config.axes.y.label.value;
            y_title.ui.Position = ui_pos;
            y_title.update_from_config();
            fields(index) = y_title;
            
            index = index + 1;
            label_pos = dapPreferences.index_to_label_position(total_height, index);
            ui_pos = dapPreferences.index_to_ui_position(total_height, index);
            y_max = prefField(p, obj.config.axes.y.max, @uispinner, @obj.push_update);
            y_max.label.Text = "Y axis maximum";
            y_max.label.Position = label_pos;
            y_max.ui.Value = obj.config.axes.y.max.value;
            y_max.ui.Limits = [obj.config.axes.y.min.value inf];
            y_max.ui.Step = obj.config.axes.y.step.value;
            y_max.ui.RoundFractionalValues = "off";
            y_max.ui.ValueDisplayFormat = "%.1f";
            y_max.ui.LowerLimitInclusive = "off";
            y_max.ui.UpperLimitInclusive = "off";
            y_max.ui.Position = ui_pos;
            y_max.update_from_config();
            fields(index) = y_max;
            
            reset = uibutton(f);
            reset.Text = "Reset to Default";
            reset.Position = [obj.PAD, obj.PAD, obj.W_LEFT_BUTTON, obj.HEIGHT];
            reset.ButtonPushedFcn = @(~, ~)obj.reset_to_default_callback_fn(fields);
            
            count = 2;
            x = count .* obj.PAD + count .* obj.W_RIGHT_BUTTON;
            x = f.Position(3) - x;
            accept = uibutton(f);
            accept.Text = "Accept";
            accept.Position = [x, obj.PAD, obj.W_RIGHT_BUTTON, obj.HEIGHT];
            accept.ButtonPushedFcn = @(~, ~)obj.accept_callback_fn(f);
            
            w = obj.W_RIGHT_BUTTON;
            x = x + obj.PAD + obj.W_RIGHT_BUTTON;
            cancel = uibutton(f);
            cancel.Text = "Cancel";
            cancel.Position = [x, obj.PAD, w, obj.HEIGHT];
            cancel.ButtonPushedFcn = @(~, ~)obj.cancel_callback_fn(old_config, f);
            
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

