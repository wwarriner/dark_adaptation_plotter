classdef dapOutputFiles < handle
    properties
        desired_size (1,1) double = 800
        folder (1,1)
        file_name (1,1) string = "out.png"
    end
    
    methods
        function obj = dapOutputFiles(dap_axes)
            obj.dap_axes = dap_axes;
        end
        
        function ui_run_export_preview(obj)
            fh = obj.generate_figure();
            fh.Visible = "on";
            
            % TODO add onclick callback to deal with results
        end
        
        function ui_run_export_as(obj)
            default_file_path = fullfile(obj.folder, obj.file_name);
            [file, path] = uiputfile(["*.png"; "*.eps"; "*.pdf"], "Export figure as", default_file_path);
            if file == 0
                return;
            end
            
            fh = obj.generate_figure();
            closer = onCleanup(@()delete(fh));
            exportgraphics(fh, fullfile(path, file));
            obj.folder = string(path);
            obj.file_name = string(file);
            delete(closer);
        end
    end
    
    properties (Access = private)
        dap_axes dapAxes
    end
    
    methods (Access = private)
        function fh = generate_figure(obj)
            fh = uifigure();
            fh.WindowStyle = "modal";
            fh.Resize = "off";
            fh.Name = "Export Preview";
            fh.Color = [1.0 1.0 1.0];
            fh.Visible = "off";
            fh.Position(1:2) = [50 50];
            
            [new_axh, new_lh] = obj.dap_axes.copyobj(fh);
            
            new_axh.OuterPosition(1:2) = [1 1];
            new_axh.OuterPosition(3) = obj.desired_size;
            new_axh.OuterPosition(4) = obj.desired_size;
            new_axh.Toolbar = [];
            new_axh.Interactions = [];
            new_axh.HitTest = "off";
            
            new_lh.Parent = fh; % copyobj should handle this yet here we are
            new_lh.Location = "eastoutside";
            new_lh.HitTest = "off";
            
            fig_width = new_lh.Position(1) + new_lh.Position(3);
            fig_height = new_axh.OuterPosition(4);
            fh.Position(3:4) = [fig_width fig_height];
        end
        
        function close(obj)
            obj.is_open = false;
        end
    end
end
