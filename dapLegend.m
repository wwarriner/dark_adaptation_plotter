classdef dapLegend < handle
    properties
        position (1,4) double
    end
    
    methods
        function obj = dapLegend(dap_axes, layout)
            legend_handle = dap_axes.draw_on(@legend);
            legend_handle.Location = "layout";
            legend_handle.Layout.TileSpan = layout.GridSize;
            legend_handle.Layout.Tile = 2;
            %legend_handle.Location = "eastoutside";
            legend_handle.Units = "pixels";
            
            obj.legend_handle = legend_handle;
            obj.position = obj.legend_handle.Position;
        end
        
        function update_position(obj)
            obj.legend_handle.Position = obj.position;
        end
    end
    
    properties (Access = private)
        dap_axes dapAxes
        legend_handle matlab.graphics.illustration.Legend
    end
end

