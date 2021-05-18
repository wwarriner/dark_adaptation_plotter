classdef DarkAdaptationPlotter < matlab.apps.AppBase
    
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure          matlab.ui.Figure
        FileMenu          matlab.ui.container.Menu
        OpenDataMenu      matlab.ui.container.Menu
        ExportFigureMenu  matlab.ui.container.Menu
        ClearDataMenu     matlab.ui.container.Menu
        PreferencesMenu   matlab.ui.container.Menu
        ExitMenu          matlab.ui.container.Menu
        HelpMenu          matlab.ui.container.Menu
        HelpMenu_2        matlab.ui.container.Menu
        AboutMenu         matlab.ui.container.Menu
        PlotTable         matlab.ui.control.Table
    end
    
    properties (Access = private)
        dap_axes = []
        dap_table = []
        dap_plots = []
        dap_data = []
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
        
        function close(app)
            delete(app);
        end
    end
    
    % Callbacks that handle component events
    methods (Access = private)
        
        % Code that executes after component creation
        function startupFcn(app)
            extend_search_path();
            
            pos = app.UIFigure.Position;
            pos(1) = app.PlotTable.Position(1) + app.PlotTable.Position(3) - 1;
            pos(3) = pos(3) - pos(1);
            pos(2) = 0;
            da = dapAxes(app.UIFigure);
            da.position = pos;
            da.update_position();
            
            recovery_line = dapRecoveryLine();
            da.draw_on(@recovery_line.draw);
            da.update();
            
            dd = dapData();
            dt = dapPlotTable(app.PlotTable);
            dp = dapPlots(da);
            
            app.dap_axes = da;
            app.dap_data = dd;
            app.dap_table = dt;
            app.dap_plots = dp;
        end
        
        % Size changed function: UIFigure
        function UIFigureSizeChanged(app, event)
            if isempty(app.dap_axes)
                return;
            end
            
            position = app.UIFigure.Position;
            
            pos = position;
            fudge = 100;
            pos(1) = app.PlotTable.Position(1) + app.PlotTable.Position(3) - 1 - fudge;
            pos(3) = min(pos(3) - pos(1), pos(4) + app.PlotTable.Position(3));
            pos(2) = 0;
            app.dap_axes.position = pos;
            app.dap_axes.update_position();
            
            app.PlotTable.Position = [1 1 app.PlotTable.Position(3) position(4)];
        end
        
        % Menu selected function: OpenDataMenu
        function OpenDataMenuSelected(app, event)
            d = uiprogressdlg(app.UIFigure);
            d.Message = "Loading file, patience please...";
            d.Title = "Loading";
            d.Indeterminate = true;
            
            closer = onCleanup(@()d.close());
            
            file = uigetfile("*.csv");
            if file == 0
                return;
            end
            
            app.dap_data.load(file);
            existing_ids = app.dap_table.ids; % TODO check plots
            [patients, ids] = app.dap_data.get_all_except(existing_ids);
            app.dap_table.add(ids);
            app.dap_plots.add(patients);
        end
        
        % Cell edit callback: PlotTable
        function PlotTableCellEdit(app, event)
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
        
        % Cell selection callback: PlotTable
        function PlotTableCellSelection(app, event)
            %{
            A way to allow editing of color column using a picker.
            %}
            indices = event.Indices;
            row = indices(1);
            col = indices(2);
            
            if col == app.dap_table.COLOR_COL
                app.pick_color(row);
                app.update_plot(row);
            end
        end
        
        % Menu selected function: ClearDataMenu
        function ClearDataMenuSelected(app, event)
            app.dap_data.clear();
            app.dap_plots.clear();
            app.dap_table.clear();
        end
        
        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            EXIT = "Exit now";
            CANCEL = "Go back";
            CANCEL_NUM = 2;
            selection = uiconfirm(...
                app.UIFigure, ...
                "Are you sure you want to exit?", ...
                "Exit?", ...
                "options", [EXIT, CANCEL], ...
                "defaultoption", CANCEL_NUM, ...
                "canceloption", CANCEL_NUM ...
                );
            switch selection
                case EXIT; app.close();
                case CANCEL; return;
                otherwise; assert(false);
            end
        end
        
        % Menu selected function: ExitMenu
        function ExitMenuSelected(app, event)
            app.UIFigureCloseRequest(event)
        end
        
        % Menu selected function: ExportFigureMenu
        function ExportFigureMenuSelected(app, event)
            % TODO bring up save dialog
            % pdf, eps, png
        end
        
        % Menu selected function: PreferencesMenu
        function PreferencesMenuSelected(app, event)
            % TODO bring up preferences dialog
            % export options - png image size
            %
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
            
            % Create FileMenu
            app.FileMenu = uimenu(app.UIFigure);
            app.FileMenu.Text = 'File';
            
            % Create OpenDataMenu
            app.OpenDataMenu = uimenu(app.FileMenu);
            app.OpenDataMenu.MenuSelectedFcn = createCallbackFcn(app, @OpenDataMenuSelected, true);
            app.OpenDataMenu.Text = 'Open Data...';
            
            % Create ExportFigureMenu
            app.ExportFigureMenu = uimenu(app.FileMenu);
            app.ExportFigureMenu.MenuSelectedFcn = createCallbackFcn(app, @ExportFigureMenuSelected, true);
            app.ExportFigureMenu.Text = 'Export Figure...';
            
            % Create ClearDataMenu
            app.ClearDataMenu = uimenu(app.FileMenu);
            app.ClearDataMenu.MenuSelectedFcn = createCallbackFcn(app, @ClearDataMenuSelected, true);
            app.ClearDataMenu.Text = 'Clear Data...';
            
            % Create PreferencesMenu
            app.PreferencesMenu = uimenu(app.FileMenu);
            app.PreferencesMenu.MenuSelectedFcn = createCallbackFcn(app, @PreferencesMenuSelected, true);
            app.PreferencesMenu.Separator = 'on';
            app.PreferencesMenu.Text = 'Preferences...';
            
            % Create ExitMenu
            app.ExitMenu = uimenu(app.FileMenu);
            app.ExitMenu.MenuSelectedFcn = createCallbackFcn(app, @ExitMenuSelected, true);
            app.ExitMenu.Separator = 'on';
            app.ExitMenu.Text = 'Exit';
            
            % Create HelpMenu
            app.HelpMenu = uimenu(app.UIFigure);
            app.HelpMenu.Text = 'Help';
            
            % Create HelpMenu_2
            app.HelpMenu_2 = uimenu(app.HelpMenu);
            app.HelpMenu_2.Text = 'Help...';
            
            % Create AboutMenu
            app.AboutMenu = uimenu(app.HelpMenu);
            app.AboutMenu.Separator = 'on';
            app.AboutMenu.Text = 'About...';
            
            % Create PlotTable
            app.PlotTable = uitable(app.UIFigure);
            app.PlotTable.ColumnName = {'ID'; '👁️'; 'Color'; 'Marker'};
            app.PlotTable.ColumnWidth = {96, 32, 50, 60};
            app.PlotTable.RowName = {};
            app.PlotTable.ColumnSortable = [true true false false];
            app.PlotTable.ColumnEditable = [false true true true];
            app.PlotTable.CellEditCallback = createCallbackFcn(app, @PlotTableCellEdit, true);
            app.PlotTable.CellSelectionCallback = createCallbackFcn(app, @PlotTableCellSelection, true);
            app.PlotTable.Position = [1 1 240 600];
            
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