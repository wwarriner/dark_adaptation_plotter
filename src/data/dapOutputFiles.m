classdef dapOutputFiles < handle
    properties
        desired_size (1,1) double = 800
        folder (1,1) string
        file_name (1,1) string = "out.png"
    end
    
    methods
        function obj = dapOutputFiles(config, dap_axes)
            obj.folder = config.files.output_folder.value;
            
            obj.config = config;
            
            obj.dap_axes = dap_axes;
        end
        
        function ui_run_export_preview(obj, figure_for_dialogs)
            fh = obj.generate_figure();
            fh.Visible = "on";
            
            menuh = uimenu(fh);
            menuh.MenuSelectedFcn = @(varargin)obj.ui_run_export_as(figure_for_dialogs);
            menuh.Text = 'Export As...';
            
            d = uiprogressdlg(figure_for_dialogs);
            d.Message = "Previewing figure for export...";
            d.Title = "Previewing";
            d.Indeterminate = true;
            closer = onCleanup(@()d.close());
            
            uiwait(fh);
        end
        
        function ui_run_export_as(obj, figure_for_dialogs)
            d = uiprogressdlg(figure_for_dialogs);
            d.Message = "Exporting figure...";
            d.Title = "Exporting";
            d.Indeterminate = true;
            closer = onCleanup(@()d.close());
            
            filter = ["*.png"; "*.eps"; "*.pdf"];
            title = "Export figure as";
            default_file_path = fullfile(obj.folder, obj.file_name);
            [name, path] = uiputfile(filter, title, default_file_path);
            if name == 0
                return;
            end
            obj.folder = string(path);
            obj.config.files.output_folder.value = obj.folder;
            obj.config.save();
            obj.file_name = string(name);
            file = fullfile(path, name);
            
            fh = obj.generate_figure();
            deleter = onCleanup(@()delete(fh));
            exportgraphics(fh, file);
        end
    end
    
    properties (Access = private)
        config Config
        
        dap_axes dapAxes
    end
    
    methods (Access = private)
        function fh = generate_figure(obj)
            fh = uifigure();
            fh.MenuBar = "none";
            fh.Resize = "off";
            fh.Name = "Export Preview";
            fh.Color = [1.0 1.0 1.0];
            fh.Visible = "off";
            fh.Position(1:2) = [50 50];
            
            [new_axh, new_lh] = obj.dap_axes.copyobj(fh);
            
            new_axh.OuterPosition(1:2) = [1 1];
            new_axh.OuterPosition(3:4) = obj.desired_size_px;
            new_axh.Toolbar = [];
            new_axh.Interactions = [];
            new_axh.HitTest = "off";
            new_axh.PositionConstraint = "outerposition";
            
            new_lh.HitTest = "off";
            
            loc = new_lh.Location;
            east_west = contains(loc, "east") || contains(loc, "west");
            north_south = contains(loc, "north") || contains(loc, "south");
            outside = contains(loc, "outside");
            fig_w = new_axh.OuterPosition(3);
            if east_west && outside
                fig_w = fig_w + new_lh.Position(3);
            end
            fig_h = new_axh.OuterPosition(4);
            if north_south && outside
                fig_h = fig_h + new_lh.Position(4);
            end
            fh.Position(3:4) = [fig_w fig_h];
        end
    end
end

