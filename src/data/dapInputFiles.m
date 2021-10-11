classdef dapInputFiles < handle
    properties
        folder (1,1) string
    end
    
    methods
        function obj = dapInputFiles(config, dap_data, dap_table, dap_plots)
            obj.folder = config.files.input_folder.value;
            
            obj.config = config;
            
            obj.dap_data = dap_data;
            obj.dap_table = dap_table;
            obj.dap_plots = dap_plots;
        end
        
        function ui_open_file(obj, figure_for_dialogs)
            d = uiprogressdlg(figure_for_dialogs);
            d.Message = "Loading file...";
            d.Title = "Loading";
            d.Indeterminate = true;
            closer = onCleanup(@()d.close());
            
            filter = "*.csv";
            title = "Load CSV data";
            default_folder = obj.folder;
            [name, path] = uigetfile(filter, title, default_folder);
            if name == 0
                return;
            end
            obj.folder = string(path);
            obj.config.files.input_folder.value = obj.folder;
            obj.config.save();
            file = fullfile(path, name);
            
            t = readtable(file);
            metaname_map = obj.config.table_field_selection.metanames.to_map();
            tfs_config.metanames = metaname_map.values();
            c = select_table_fields(tfs_config, t);
            t = renamevars(t, c.values(), c.keys());
            t = renamevars(t, metaname_map.values(), metaname_map.keys());
            t = t(:, metaname_map.keys());
            
            obj.dap_data.add_data(t);
            existing_ids = obj.dap_table.ids; % TODO check plots
            [patients, ids] = obj.dap_data.get_all_except(existing_ids);
            obj.dap_table.add(ids);
            obj.dap_plots.add(patients);
        end
    end
    
    properties (Access = private)
        config Config
        
        dap_data dapData
        dap_table dapPlotTable
        dap_plots dapPlots
    end
end

