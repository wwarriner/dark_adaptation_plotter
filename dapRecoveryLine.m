classdef dapRecoveryLine < handle
    properties
        y (1,1) double {mustBeReal,mustBeFinite} = 3.0
        line_width (1,1) double {mustBeReal,mustBeFinite,mustBePositive} = 2.0
        line_style (1,1) string = ":"
        color Color = Color.BLACK();
    end
    
    methods
        function draw(obj, axh)
            assert(isa(axh, "matlab.graphics.axis.Axes"));
            
            ph = hline(axh, obj.y);
            obj.line_handle = ph;
            
            obj.axes_handle = axh;
            
            obj.update();
        end
        
        function update(obj)
            h = obj.line_handle;
            h.XData = obj.axes_handle.XLim;
            h.YData = [obj.y obj.y];
            h.LineStyle = obj.line_style;
            h.LineWidth = obj.line_width;
            h.Color = obj.color.rgb;
        end
    end
    
    properties (Access = private)
        line_handle matlab.graphics.Graphics
        axes_handle matlab.graphics.Graphics
    end
end

