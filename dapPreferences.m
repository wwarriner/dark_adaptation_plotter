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
            
            obj.update_value(f.name, s.FontName);
            obj.update_value(f.size, s.FontSize);
            obj.update_value(f.weight, s.FontWeight);
            obj.update_value(f.angle, s.FontAngle);
        end
        
        function ui_update_preferences(obj)
            f = uifigure();
            f.Scrollable = "on";
            f.Position = [50 50 800 600];
            f.WindowStyle = "modal";
            total_height = f.Position(4);
            
            index = 0;
            
            index = index + 1;
            [time_title, time_title_label] = obj.build_ui(f, @uieditfield, total_height, index);
            time_title_label.Text = "X axis title";
            time_title.Value = obj.config.axes.x.label.value;
            time_title.ValueChangedFcn = @(~,event)obj.update_value(obj.config.axes.x.label, event.Value);
            
            index = index + 1;
            [time_max, time_max_label] = obj.build_ui(f, @uispinner, total_height, index);
            time_max_label.Text = "X axis maximum";
            time_max.Value = obj.config.axes.x.max.value;
            time_max.Limits = [obj.config.axes.x.min.value inf];
            time_max.Step = obj.config.axes.x.step.value;
            time_max.RoundFractionalValues = "on";
            time_max.ValueDisplayFormat = "%d";
            time_max.LowerLimitInclusive = "off";
            time_max.UpperLimitInclusive = "off";
            time_max.ValueChangedFcn = @(~,event)obj.update_value(obj.config.axes.x.max, event.Value);
            
            index = index + 1;
            [time_title, time_title_label] = obj.build_ui(f, @uieditfield, total_height, index);
            time_title_label.Text = "Y axis title";
            time_title.Value = obj.config.axes.y.label.value;
            time_title.ValueChangedFcn = @(~,event)obj.update_value(obj.config.axes.y.label, event.Value);
            
            index = index + 1;
            [sensitivity_max, sensitivity_max_label] = obj.build_ui(f, @uispinner, total_height, index);
            sensitivity_max_label.Text = "Y axis maximum";
            sensitivity_max.Value = obj.config.axes.y.max.value;
            sensitivity_max.Limits = [obj.config.axes.y.min.value inf];
            sensitivity_max.Step = obj.config.axes.y.step.value;
            sensitivity_max.RoundFractionalValues = "off";
            sensitivity_max.ValueDisplayFormat = "%.1f";
            sensitivity_max.LowerLimitInclusive = "off";
            sensitivity_max.UpperLimitInclusive = "off";
            sensitivity_max.ValueChangedFcn = @(~,event)obj.update_value(obj.config.axes.y.max, event.Value);
            
            index = index + 1;
        end
    end
    
    properties (Access = private)
        config Config
        callbacks containers.Map
    end
    
    properties (Access = private, Constant)
        PAD = 6;
        X_LABEL = 10;
        W_LABEL = 200;
        
        X_UI = dapPreferences.PAD + dapPreferences.X_LABEL + dapPreferences.W_LABEL;
        W_UI = 200;
        
        HEIGHT = 23;
    end
    
    methods (Access = private)
        function update_value(obj, config, value)
            config.value = value;
            keys = string(obj.callbacks.keys());
            for i = 1 : numel(keys)
                fn = obj.callbacks(keys(i));
                fn();
            end
        end
    end
       
    methods (Access = private, Static)
        function [ui, label] = build_ui(parent, ui_fn, total_height, index)
            label = dapPreferences.build_label(parent, total_height, index);
            
            ui = ui_fn(parent);
            ui.Position = dapPreferences.index_to_ui_position(total_height, index);
        end
        
        function label = build_label(parent, total_height, index)
            label = uilabel(parent);
            label.Position = dapPreferences.index_to_label_position(total_height, index);
        end
        
        function pos = index_to_label_position(total_height, index)
            y = dapPreferences.index_to_y(total_height, index);
            pos = [dapPreferences.X_LABEL, y, dapPreferences.W_LABEL, dapPreferences.HEIGHT];
        end
        
        function pos = index_to_ui_position(total_height, index)
            y = dapPreferences.index_to_y(total_height, index);
            pos = [dapPreferences.X_UI, y, dapPreferences.W_UI, dapPreferences.HEIGHT];
        end
        
        function y = index_to_y(total_height, index)
            y = total_height - (dapPreferences.HEIGHT .* index + dapPreferences.PAD .* (index - 1));
        end
    end
end

