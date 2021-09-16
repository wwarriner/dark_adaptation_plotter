classdef prefField < handle
    properties (SetAccess = private)
        label matlab.ui.control.Label
        ui
    end
    
    methods
        function obj = prefField(container, pref_decl, config, push_callback)
            pref_config = config.(pref_decl.config);
            label = obj.create_label(container, pref_decl);
            ui = obj.create_ui_widget(container, pref_decl, config, @(o,~)obj.update_to_config_callback(o));
            initial_value = pref_config.value;
            
            obj.config = config;
            obj.pref_config = pref_config;
            obj.pref_decl = pref_decl;
            obj.label = label;
            obj.ui = ui;
            obj.push_callback = push_callback;
            obj.initial_value = initial_value;
        end
        
        function update_from_config(obj)
            obj.set_ui(obj.ui, obj.config, obj.pref_decl);
        end
        
        function update_to_config_callback(obj, ui_object)
            obj.pref_config.value = ui_object.Value;
            obj.push_callback();
            obj.update_from_config();
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
        pref_config Config
        pref_decl struct
        push_callback function_handle
        initial_value
    end
    
    methods (Access = private, Static)
        function label = create_label(parent, pref_decl)
            label = uilabel(parent);
            prefField.set_label(label, pref_decl);
        end
        
        function ui = create_ui_widget(parent, pref_decl, config, update_fn)
            ui_fn = str2func(pref_decl.object);
            ui = ui_fn(parent);
            prefField.set_ui(ui, config, pref_decl);
            ui.ValueChangedFcn = update_fn;
        end
        
        function label = set_label(label, pref_decl)
            v = pref_decl.label;
            prefField.apply_fields_to_ui(label, v);
        end
        
        function ui = set_ui(ui, config, pref_decl)
            v = pref_decl.ui;
            f = fieldnames(v);
            for i = 1 : numel(f)
                field = f{i};
                values = v.(field);
                values = prefField.transform_ui_values(config, values);
                v.(field) = values;
            end
            prefField.apply_fields_to_ui(ui, v);
        end
        
        function apply_fields_to_ui(ui_handle, value_struct)
            f = fieldnames(value_struct);
            for i = 1 : numel(f)
                field = f{i};
                ui_handle.(field) = value_struct.(field);
            end
        end
        
        function values = transform_ui_values(config, values)
            if ~iscell(values)
                values = {values};
            end
            for j = 1 : numel(values)
                values{j} = prefField.transform_ui_value(config, values{j});
            end
            try
                values = cell2mat(values);
            catch
                try values = string(values); catch; end
            end
        end
        
        function out = transform_ui_value(config, value)
            if isfield(value, "config")
                out = config.(value.config);
            elseif isfield(value, "float")
                out = str2double(value.float);
            else
                out = value;
            end
            assert(~isstruct(out));
        end
    end
end

