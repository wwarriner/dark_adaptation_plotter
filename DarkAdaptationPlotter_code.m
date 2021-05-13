classdef DarkAdaptationPlotter < matlab.apps.AppBase
    
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure          matlab.ui.Figure
        FileMenu          matlab.ui.container.Menu
        OpenDataMenu      matlab.ui.container.Menu
        ExportFigureMenu  matlab.ui.container.Menu
        PreferencesMenu   matlab.ui.container.Menu
        ExitMenu          matlab.ui.container.Menu
        HelpMenu          matlab.ui.container.Menu
        HelpMenu_2        matlab.ui.container.Menu
        AboutMenu         matlab.ui.container.Menu
        PlotTable         matlab.ui.control.Table
    end
    
    properties (Access = private)
        dap_axes = []
    end
    
    % Callbacks that handle component events
    methods (Access = private)
        
        % Code that executes after component creation
        function startupFcn(app)
            pos = app.UIFigure.Position;
            pos(1) = app.PlotTable.Position(1) + app.PlotTable.Position(3) - 1;
            pos(3) = pos(3) - pos(1);
            pos(2) = 0;
            da = dapAxes(app.UIFigure);
            da.position = pos;
            da.update_position();
            
            app.dap_axes = da;
        end
        
        % Size changed function: UIFigure
        function UIFigureSizeChanged(app, event)
            if isempty(app.dap_axes)
                return;
            end
            
            position = app.UIFigure.Position;
            
            pos = position;
            pos(1) = app.PlotTable.Position(1) + app.PlotTable.Position(3) - 1 - 100;
            pos(3) = min(pos(3) - pos(1), pos(4) + 200);
            pos(2) = 0;
            app.dap_axes.position = pos;
            app.dap_axes.update_position();
            
            app.PlotTable.Position = [1 1 200 position(4)];
        end
        
        % Menu selected function: OpenDataMenu
        function OpenDataMenuSelected(app, event)
            file = uigetfile("*.csv");
            if file == 0
                return;
            end
            
            data = dapData();
            data.load(file);
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
            app.ExportFigureMenu.Text = 'Export Figure...';
            
            % Create PreferencesMenu
            app.PreferencesMenu = uimenu(app.FileMenu);
            app.PreferencesMenu.Separator = 'on';
            app.PreferencesMenu.Text = 'Preferences...';
            
            % Create ExitMenu
            app.ExitMenu = uimenu(app.FileMenu);
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
            app.PlotTable.ColumnName = {'C'};
            app.PlotTable.RowName = {};
            app.PlotTable.Position = [1 1 200 600];
            
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