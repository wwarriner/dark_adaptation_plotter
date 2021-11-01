classdef DarkAdaptationPlotter < matlab.apps.AppBase
    
    % Properties that correspond to app components
    properties (Access = public)
        DarkAdaptationPlotterUIFigure  matlab.ui.Figure
        FileParentMenu                 matlab.ui.container.Menu
        OpenDataMenu                   matlab.ui.container.Menu
        ClearDataMenu                  matlab.ui.container.Menu
        ExportPreviewMenu              matlab.ui.container.Menu
        ExportAsMenu                   matlab.ui.container.Menu
        ExitMenu                       matlab.ui.container.Menu
        EditMenu                       matlab.ui.container.Menu
        FontMenu                       matlab.ui.container.Menu
        PreferencesMenu                matlab.ui.container.Menu
        HelpParentMenu                 matlab.ui.container.Menu
        HelpMenu                       matlab.ui.container.Menu
        AboutMenu                      matlab.ui.container.Menu
        AxesPanel                      matlab.ui.container.Panel
        Table                          matlab.ui.control.Table
    end
    
    properties (Access = private)
        dap_axes = []
        dap_table = []
        dap_plots = []
        dap_data = []
        font_settings = []
        dap_input_files = []
        dap_output_files = []
        dap_preferences = []
        sort_state = 0
    end
    
    methods (Access = private)
        function update_plot(app, row)
            app.update_visible(row);
            app.update_color(row);
            app.update_marker(row);
            app.update_marker_size(row);
        end
        
        function update_visible(app, row)
            id = app.dap_table.get_id(row);
            visible = app.dap_table.get_visible(row);
            app.dap_plots.update_visible(id, visible);
        end
        
        function update_color(app, row)
            id = app.dap_table.get_id(row);
            color = app.dap_table.get_color(row);
            app.dap_plots.update_color(id, color);
        end
        
        function update_marker(app, row)
            id = app.dap_table.get_id(row);
            marker = app.dap_table.get_marker(row);
            app.dap_plots.update_marker(id, marker);
        end
        
        function update_marker_size(app, row)
            id = app.dap_table.get_id(row);
            size = app.dap_table.get_size(row);
            app.dap_plots.update_marker_size(id, size);
        end
        
        function pick_color(app, row)
            color = app.dap_table.get_color(row);
            color.rgb = uisetcolor(color.rgb, "Select a plot color");
            app.dap_table.set_color(row, color);
            drawnow();
        end
        
        function resize(app)
            position = app.DarkAdaptationPlotterUIFigure.Position;
            
            % table
            TABLE_X_FRACTION = 0.33;
            table_width = round(TABLE_X_FRACTION .* position(3));
            SCROLLBAR_WIDTH = 18;
            table_width_for_columns = max(table_width - SCROLLBAR_WIDTH, 0);
            
            table_height = position(4);
            
            app.Table.Position = [1 1 table_width table_height];
            width_weights = app.dap_table.WIDTH_WEIGHTS;
            width_fractions = width_weights ./ sum(width_weights);
            column_widths = table_width_for_columns .* width_fractions;
            app.Table.ColumnWidth = num2cell(column_widths);
            
            % panel
            panel_x = app.Table.Position(1) + app.Table.Position(3) - 1;
            panel_y = 1;
            panel_width = position(3) - table_width;
            panel_height = position(4);
            app.AxesPanel.Position = [panel_x panel_y panel_width panel_height];
        end
        
        function close(app)
            delete(app);
        end
    end
    
    % Callbacks that handle component events
    methods (Access = private)
        
        % Code that executes after component creation
        function startupFcn(app)
            extend_search_path();
            
            config = Config("config.json");
            
            da = dapAxes(app.AxesPanel, config);
            
            recovery_line = dapRecoveryLine();
            da.draw_on(@recovery_line.set_parent);
            da.register_callback("recovery_line", @recovery_line.update);
            da.update();
            
            dd = dapData();
            dt = dapPlotTable(app.Table);
            dp = dapPlots(config, da);
            
            dof = dapOutputFiles(config, da);
            dif = dapInputFiles(config, dd, dt, dp);
            
            dpref = dapPreferences(config, [440, 300], "res/prefs.json");
            dpref.register_callback("dapAxes", @da.update);
            dpref.register_callback("dapPlots", @dp.update_draw);
            dpref.register_callback("dapOutputFiles", @dof.update);
            
            app.dap_axes = da;
            app.dap_data = dd;
            app.dap_table = dt;
            app.dap_plots = dp;
            app.dap_output_files = dof;
            app.dap_input_files = dif;
            app.dap_preferences = dpref;
            
            resize(app);
        end
        
        % Size changed function: DarkAdaptationPlotterUIFigure
        function DarkAdaptationPlotterUIFigureSizeChanged(app, event)
            if isempty(app.dap_axes)
                return;
            end
            
            resize(app);
        end
        
        % Cell edit callback: Table
        function TableCellEdit(app, event)
            %{
            Only the visibility and marker columns are directly editable.
            For color editing see PlotTableCellSelection().
            %}
            %newData = event.NewData;
            indices = event.Indices;
            row = indices(1);
            col = indices(2);
            
            if col == app.dap_table.VISIBLE_COL
                app.update_plot(row);
            elseif col == app.dap_table.MARKER_COL
                app.update_plot(row);
            elseif col == app.dap_table.SIZE_COL
                app.update_plot(row);
            end
        end
        
        % Cell selection callback: Table
        function TableCellSelection(app, event)
            %{
            A way to allow editing of color column using a picker.
            %}
            indices = event.Indices;
            if isempty(indices)
                return;
            end
            row = indices(1);
            col = indices(2);
            
            if col == app.dap_table.COLOR_COL
                app.pick_color(row);
                app.update_plot(row);
            end
        end
        
        % Menu selected function: OpenDataMenu
        function OpenDataMenuSelected(app, event)
            assert(~isempty(app.dap_input_files));
            app.dap_input_files.ui_open_file(app.DarkAdaptationPlotterUIFigure)
        end
        
        % Menu selected function: ClearDataMenu
        function ClearDataMenuSelected(app, event)
            assert(~isempty(app.dap_data));
            assert(~isempty(app.dap_plots));
            assert(~isempty(app.dap_table));
            assert(~isempty(app.dap_axes));
            
            CLEAR_OPT = "Clear all data";
            CANCEL_OPT = "Go back";
            CANCEL_NUM = 2;
            selection = uiconfirm(...
                app.DarkAdaptationPlotterUIFigure, ...
                ["Really clear all data?" "This cannot be undone."], ...
                "Clear data?", ...
                "options", [CLEAR_OPT CANCEL_OPT], ...
                "defaultoption", CANCEL_NUM, ...
                "canceloption", CANCEL_NUM ...
                );
            
            switch selection
                case CLEAR_OPT
                    app.dap_data.clear();
                    app.dap_plots.clear();
                    app.dap_table.clear();
                    app.dap_axes.update();
                case CANCEL_OPT; return;
                otherwise; assert(false);
            end
        end
        
        % Menu selected function: ExportPreviewMenu
        function ExportPreviewMenuSelected(app, event)
            app.dap_output_files.ui_run_export_preview(app.DarkAdaptationPlotterUIFigure);
        end
        
        % Menu selected function: ExportAsMenu
        function ExportAsMenuSelected(app, event)
            assert(~isempty(app.dap_output_files));
            app.dap_output_files.ui_run_export_as(app.DarkAdaptationPlotterUIFigure);
        end
        
        % Menu selected function: ExitMenu
        function ExitMenuSelected(app, event)
            app.DarkAdaptationPlotterUIFigureCloseRequest(event);
        end
        
        % Menu selected function: FontMenu
        function FontMenuSelected(app, event)
            assert(~isempty(app.dap_preferences));
            app.dap_preferences.ui_update_font();
        end
        
        % Menu selected function: PreferencesMenu
        function PreferencesMenuSelected(app, event)
            assert(~isempty(app.dap_preferences));
            p = app.DarkAdaptationPlotterUIFigure.Position;
            x = p(1) + 24;
            y = p(4) + p(2) - 1 - 24;
            app.dap_preferences.ui_update_preferences(x, y);
        end
        
        % Close request function: DarkAdaptationPlotterUIFigure
        function DarkAdaptationPlotterUIFigureCloseRequest(app, event)
            EXIT_OPT = "Exit now";
            CANCEL_OPT = "Go back";
            CANCEL_NUM = 2;
            selection = uiconfirm(...
                app.DarkAdaptationPlotterUIFigure, ...
                "Are you sure you want to exit?", ...
                "Exit?", ...
                "options", [EXIT_OPT, CANCEL_OPT], ...
                "defaultoption", CANCEL_NUM, ...
                "canceloption", CANCEL_NUM ...
                );
            switch selection
                case EXIT_OPT; app.close();
                case CANCEL_OPT; return;
                otherwise; assert(false);
            end
        end
    end
    
    % Component initialization
    methods (Access = private)
        
        % Create UIFigure and components
        function createComponents(app)
            
            % Create DarkAdaptationPlotterUIFigure and hide until all components are created
            app.DarkAdaptationPlotterUIFigure = uifigure('Visible', 'off');
            app.DarkAdaptationPlotterUIFigure.AutoResizeChildren = 'off';
            app.DarkAdaptationPlotterUIFigure.Position = [100 100 1200 600];
            app.DarkAdaptationPlotterUIFigure.Name = 'Dark Adaptation Plotter';
            app.DarkAdaptationPlotterUIFigure.CloseRequestFcn = createCallbackFcn(app, @DarkAdaptationPlotterUIFigureCloseRequest, true);
            app.DarkAdaptationPlotterUIFigure.SizeChangedFcn = createCallbackFcn(app, @DarkAdaptationPlotterUIFigureSizeChanged, true);
            
            % Create FileParentMenu
            app.FileParentMenu = uimenu(app.DarkAdaptationPlotterUIFigure);
            app.FileParentMenu.Text = 'File';
            
            % Create OpenDataMenu
            app.OpenDataMenu = uimenu(app.FileParentMenu);
            app.OpenDataMenu.MenuSelectedFcn = createCallbackFcn(app, @OpenDataMenuSelected, true);
            app.OpenDataMenu.Text = 'Open Data...';
            
            % Create ClearDataMenu
            app.ClearDataMenu = uimenu(app.FileParentMenu);
            app.ClearDataMenu.MenuSelectedFcn = createCallbackFcn(app, @ClearDataMenuSelected, true);
            app.ClearDataMenu.Text = 'Clear Data';
            
            % Create ExportPreviewMenu
            app.ExportPreviewMenu = uimenu(app.FileParentMenu);
            app.ExportPreviewMenu.MenuSelectedFcn = createCallbackFcn(app, @ExportPreviewMenuSelected, true);
            app.ExportPreviewMenu.Separator = 'on';
            app.ExportPreviewMenu.Text = 'Export Preview...';
            
            % Create ExportAsMenu
            app.ExportAsMenu = uimenu(app.FileParentMenu);
            app.ExportAsMenu.MenuSelectedFcn = createCallbackFcn(app, @ExportAsMenuSelected, true);
            app.ExportAsMenu.Text = 'Export As...';
            
            % Create ExitMenu
            app.ExitMenu = uimenu(app.FileParentMenu);
            app.ExitMenu.MenuSelectedFcn = createCallbackFcn(app, @ExitMenuSelected, true);
            app.ExitMenu.Separator = 'on';
            app.ExitMenu.Text = 'Exit';
            
            % Create EditMenu
            app.EditMenu = uimenu(app.DarkAdaptationPlotterUIFigure);
            app.EditMenu.Text = 'Edit';
            
            % Create FontMenu
            app.FontMenu = uimenu(app.EditMenu);
            app.FontMenu.MenuSelectedFcn = createCallbackFcn(app, @FontMenuSelected, true);
            app.FontMenu.Text = 'Font...';
            
            % Create PreferencesMenu
            app.PreferencesMenu = uimenu(app.EditMenu);
            app.PreferencesMenu.MenuSelectedFcn = createCallbackFcn(app, @PreferencesMenuSelected, true);
            app.PreferencesMenu.Text = 'Preferences...';
            
            % Create HelpParentMenu
            app.HelpParentMenu = uimenu(app.DarkAdaptationPlotterUIFigure);
            app.HelpParentMenu.Text = 'Help';
            
            % Create HelpMenu
            app.HelpMenu = uimenu(app.HelpParentMenu);
            app.HelpMenu.Text = 'Help...';
            
            % Create AboutMenu
            app.AboutMenu = uimenu(app.HelpParentMenu);
            app.AboutMenu.Separator = 'on';
            app.AboutMenu.Text = 'About...';
            
            % Create Table
            app.Table = uitable(app.DarkAdaptationPlotterUIFigure);
            app.Table.ColumnName = {'ID'; '👁️'; 'Color'; 'Marker'; 'Size'};
            app.Table.ColumnWidth = {96, 32, 50, 60, 32};
            app.Table.RowName = {};
            app.Table.ColumnSortable = [true true false false false];
            app.Table.ColumnEditable = [false true true true true];
            app.Table.CellEditCallback = createCallbackFcn(app, @TableCellEdit, true);
            app.Table.CellSelectionCallback = createCallbackFcn(app, @TableCellSelection, true);
            app.Table.Position = [1 1 239.754098360656 600];
            
            % Create AxesPanel
            app.AxesPanel = uipanel(app.DarkAdaptationPlotterUIFigure);
            app.AxesPanel.AutoResizeChildren = 'off';
            app.AxesPanel.Position = [240 1 961 600];
            
            % Show the figure after all components are created
            app.DarkAdaptationPlotterUIFigure.Visible = 'on';
        end
    end
    
    % App creation and deletion
    methods (Access = public)
        
        % Construct app
        function app = DarkAdaptationPlotter
            
            % Create UIFigure and components
            createComponents(app)
            
            % Register the app with App Designer
            registerApp(app, app.DarkAdaptationPlotterUIFigure)
            
            % Execute the startup function
            runStartupFcn(app, @startupFcn)
            
            if nargout == 0
                clear app
            end
        end
        
        % Code that executes before app deletion
        function delete(app)
            
            % Delete UIFigure when app is deleted
            delete(app.DarkAdaptationPlotterUIFigure)
        end
    end
end