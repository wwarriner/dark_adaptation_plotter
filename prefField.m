classdef prefField < handle
    properties (SetAccess = private)
        label
        ui
    end
    
    methods
        function obj = prefField(container, config, ui_fn, push_callback)
            label = uilabel(container);
            ui = ui_fn(container);
            ui.ValueChangedFcn = @(~,event)obj.update_to_config_callback(event);
            
            obj.config = config;
            obj.label = label;
            obj.ui = ui;
            obj.push_callback = push_callback;
            obj.initial_value = obj.config.value;
        end
        
        function update_from_config(obj)
            obj.ui.Value = obj.config.value;
        end
        
        function update_to_config_callback(obj, event)
            obj.config.value = event.Value;
            obj.push_callback();
        end
        
        function reset_to_initial(obj)
            obj.config.value = obj.initial_value;
            obj.update_from_config();
            obj.push_callback();
        end
        
        function reset_to_default(obj)
            obj.config.value = obj.config.default;
            obj.update_from_config();
            obj.push_callback();
        end
    end
    
    properties (Access = private)
        config Config
        push_callback function_handle
        initial_value
    end
end

