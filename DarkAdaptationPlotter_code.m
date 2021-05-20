classdef DarkAdaptationPlotter < matlab.apps.AppBase
    
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        FileParentMenu     matlab.ui.container.Menu
        OpenDataMenu       matlab.ui.container.Menu
        ClearDataMenu      matlab.ui.container.Menu
        ExportPreviewMenu  matlab.ui.container.Menu
        ExportAsMenu       matlab.ui.container.Menu
        ExitMenu           matlab.ui.container.Menu
        EditMenu           matlab.ui.container.Menu
        FontMenu           matlab.ui.container.Menu
        PreferencesMenu    matlab.ui.container.Menu
        HelpParentMenu     matlab.ui.container.Menu
        HelpMenu           matlab.ui.container.Menu
        AboutMenu          matlab.ui.container.Menu
        AxesPanel          matlab.ui.container.Panel
        Table              matlab.ui.control.Table
    end
    
    properties (Access = private)
        dap_axes = []
        dap_table = []
        dap_plots = []
        dap_data = []
        font_settings = []
        dap_output_files = []
        sort_state = 0
    end
    
    methods (Access = private)
        function update_plot(app, row)
            app.update_visible(row);
            app.update_color(row);
            app.update_marker(row);
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
        
        function pick_color(app, row)
            color = app.dap_table.get_color(row);
            color.rgb = uisetcolor(color.rgb, "Select a plot color");
            app.dap_table.set_color(row, color);
            drawnow();
        end
        
        function update_marker(app, row)
            id = app.dap_table.get_id(row);
            marker = app.dap_table.get_marker(row);
            app.dap_plots.update_marker(id, marker);
        end
        
        function resize(app)
            position = app.UIFigure.Position;
            
            % table
            TABLE_X_FRACTION = 0.33;
            table_x = 1;
            table_y = 1;
            table_width = round(TABLE_X_FRACTION .* position(3));
            table_height = position(4);
            app.Table.Position = [table_x table_y table_width table_height];
            TABLE_WIDTH_WEIGHTS = [96 32 50 60];
            table_width_fractions = TABLE_WIDTH_WEIGHTS ./ sum(TABLE_WIDTH_WEIGHTS);
            table_widths = round(app.Table.Position(3) .* table_width_fractions);
            table_widths(end) = sum(table_widths) - sum(table_widths(1 : end-1)) - 2;
            app.Table.ColumnWidth = num2cell(table_widths);
            
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
            
            da = dapAxes(app.AxesPanel);
            
            recovery_line = dapRecoveryLine();
            da.draw_on(@recovery_line.draw);
            da.update();
            
            dd = dapData();
            dt = dapPlotTable(app.Table);
            dp = dapPlots(da);
            
            % TODO config defaults
            font_opt = FontSettings("Helvetica", 24, "normal", "normal");
            font_opt.register(app.Table);
            font_opt.register(da, @da.update_font);
            font_opt.update();
            
            dof = dapOutputFiles(da);
            
            app.dap_axes = da;
            app.dap_data = dd;
            app.dap_table = dt;
            app.dap_plots = dp;
            app.font_settings = font_opt;
            app.dap_output_files = dof;
            
            resize(app);
        end
        
        % Size changed function: UIFigure
        function UIFigureSizeChanged(app, event)
            if isempty(app.dap_axes)
                return;
            end
            
            resize(app);
        end
        
        % Menu selected function: OpenDataMenu
        function OpenDataMenuSelected(app, event)
            file = uigetfile("*.csv");
            if file == 0
                return;
            end
            
            d = uiprogressdlg(app.UIFigure);
            d.Message = "Loading file...";
            d.Title = "Loading";
            d.Indeterminate = true;
            
            closer = onCleanup(@()d.close());
            
            app.dap_data.load(file);
            existing_ids = app.dap_table.ids; % TODO check plots
            [patients, ids] = app.dap_data.get_all_except(existing_ids);
            app.dap_table.add(ids);
            app.dap_plots.add(patients);
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
        
        % Menu selected function: ClearDataMenu
        function ClearDataMenuSelected(app, event)
            CLEAR_OPT = "Clear all data";
            CANCEL_OPT = "Go back";
            CANCEL_NUM = 2;
            selection = uiconfirm(...
                app.UIFigure, ...
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
        
        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            EXIT_OPT = "Exit now";
            CANCEL_OPT = "Go back";
            CANCEL_NUM = 2;
            selection = uiconfirm(...
                app.UIFigure, ...
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
        
        % Menu selected function: ExitMenu
        function ExitMenuSelected(app, event)
            app.UIFigureCloseRequest(event);
        end
        
        % Menu selected function: ExportPreviewMenu
        function ExportPreviewMenuSelected(app, event)
            app.dap_output_files.ui_run_export_preview();
        end
        
        % Callback function
        function PreferencesMenuSelected(app, event)
            % TODO bring up preferences dialog
            % export options - png image size
            %
        end
        
        % Menu selected function: FontMenu
        function FontMenuSelected(app, event)
            assert(~isempty(app.font_settings));
            
            app.font_settings.ui_get();
        end
        
        % Menu selected function: ExportAsMenu
        function ExportAsMenuSelected(app, event)
            app.dap_output_files.ui_run_export_as();
        end
        
        % Display data changed function: Table
        function TableDisplayDataChanged(app, event)
            if event.InteractionColumn ~= app.dap_table.ID_COL
                return;
            end
            
            newDisplayData = app.Table.DisplayData;
            switch app.sort_state
                case 0
                    [~, ndx] = natsort(app.Table.Data(:, event.InteractionColumn));
                    app.sort_state = 1;
                case 1
                    [~, ndx] = natsort(app.Table.Data(:, event.InteractionColumn));
                    ndx = flipud(ndx);
                    app.sort_state = 0;
                otherwise
                    assert(false);
            end
            app.Table.Data = app.Table.Data(ndx, :);
        end
    end
    
    % Component initialization
    methods (Access = private)
        
        % Create UIFigure and components
        function createComponents(app)
            
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 1200 600];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);
            
            % Create FileParentMenu
            app.FileParentMenu = uimenu(app.UIFigure);
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
            app.EditMenu = uimenu(app.UIFigure);
            app.EditMenu.Text = 'Edit';
            
            % Create FontMenu
            app.FontMenu = uimenu(app.EditMenu);
            app.FontMenu.MenuSelectedFcn = createCallbackFcn(app, @FontMenuSelected, true);
            app.FontMenu.Text = 'Font...';
            
            % Create PreferencesMenu
            app.PreferencesMenu = uimenu(app.EditMenu);
            app.PreferencesMenu.Text = 'Preferences...';
            
            % Create HelpParentMenu
            app.HelpParentMenu = uimenu(app.UIFigure);
            app.HelpParentMenu.Text = 'Help';
            
            % Create HelpMenu
            app.HelpMenu = uimenu(app.HelpParentMenu);
            app.HelpMenu.Text = 'Help...';
            
            % Create AboutMenu
            app.AboutMenu = uimenu(app.HelpParentMenu);
            app.AboutMenu.Separator = 'on';
            app.AboutMenu.Text = 'About...';
            
            % Create Table
            app.Table = uitable(app.UIFigure);
            app.Table.ColumnName = {'ID'; '👁️'; 'Color'; 'Marker'};
            app.Table.ColumnWidth = {96, 32, 50, 60};
            app.Table.RowName = {};
            app.Table.ColumnSortable = [true true false false];
            app.Table.ColumnEditable = [false true true true];
            app.Table.CellEditCallback = createCallbackFcn(app, @TableCellEdit, true);
            app.Table.CellSelectionCallback = createCallbackFcn(app, @TableCellSelection, true);
            app.Table.DisplayDataChangedFcn = createCallbackFcn(app, @TableDisplayDataChanged, true);
            app.Table.Position = [1 1 239.754098360656 600];
            
            % Create AxesPanel
            app.AxesPanel = uipanel(app.UIFigure);
            app.AxesPanel.AutoResizeChildren = 'off';
            app.AxesPanel.Position = [240 1 961 600];
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end
    
    % App creation and deletion
    methods (Access = public)
        
        % Construct app
        function app = DarkAdaptationPlotter
            
            % Create UIFigure and components
            createComponents(app)
            
            % Register the app with App Designer
            registerApp(app, app.UIFigure)
            
            % Execute the startup function
            runStartupFcn(app, @startupFcn)
            
            if nargout == 0
                clear app
            end
        end
        
        % Code that executes before app deletion
        function delete(app)
            
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end