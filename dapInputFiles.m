classdef dapInputFiles < handle
    properties
        folder (1,1) string
    end
    
    methods
        function obj = dapInputFiles(dap_data, dap_table, dap_plots)
            obj.dap_data = dap_data;
            obj.dap_table = dap_table;
            obj.dap_plots = dap_plots;
        end
        
        function ui_open_file(obj, figure_for_dialogs)
            filter = "*.csv";
            title = "Load CSV data";
            default_path = obj.folder;
            [name, path] = uigetfile(filter, title, default_path);
            if name == 0
                return;
            end
            file = fullfile(path, name);
            
            d = uiprogressdlg(figure_for_dialogs);
            d.Message = "Loading file...";
            d.Title = "Loading";
            d.Indeterminate = true;
            
            closer = onCleanup(@()d.close());
            
            obj.dap_data.load(file);
            existing_ids = obj.dap_table.ids; % TODO check plots
            [patients, ids] = obj.dap_data.get_all_except(existing_ids);
            obj.dap_table.add(ids);
            obj.dap_plots.add(patients);
        end
    end
    
    properties (Access = private)
        dap_data dapData
        dap_table dapPlotTable
        dap_plots dapPlots
    end
end

