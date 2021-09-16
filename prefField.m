classdef prefField < handle
    properties (SetAccess = private)
        label
        ui
    end
    
    methods
        function obj = prefField(container, pref_decl, config, push_callback)
            label = uilabel(container);
            obj.set_label(label, pref_decl);
            
            ui_fn = str2func(pref_decl.object);
            ui = ui_fn(container);
            obj.set_ui(ui, config, pref_decl);
            ui.ValueChangedFcn = @(o,~)obj.update_to_config_callback(o);
            
            pref_config = config.(pref_decl.config);
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
        function label = set_label(label, pref_decl)
            v = pref_decl.label;
            f = fieldnames(v);
            for i = 1 : numel(f)
                field = f{i};
                label.(field) = v.(field);
            end
        end
        
        function ui = set_ui(ui, config, pref_decl)
            v = pref_decl.ui;
            f = fieldnames(v);
            for i = 1 : numel(f)
                field = f{i};
                values = v.(field);
                if ~iscell(values)
                    values = {values};
                end
                for j = 1 : numel(values)
                    values{j} = prefField.transform_ui(config, values{j});
                end
                try
                    values = cell2mat(values);
                catch
                    try values = string(values); catch; end
                end
                v.(field) = values;
            end
            for i = 1 : numel(f)
                field = f{i};
                ui.(field) = v.(field);
            end
        end
        
        function out = transform_ui(config, v)
            if isfield(v, "config")
                out = config.(v.config);
            elseif isfield(v, "float")
                out = str2double(v.float);
            else
                out = v;
            end
            assert(~isstruct(out));
        end
    end
end

