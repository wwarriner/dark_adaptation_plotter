classdef dapRecoveryLine < handle
    %{
    Encapsulates the recovery line, i.e. the predefined sensitivity threshold
    below which the patient has adapted to low ambient illumination intensity.
    
    The strategy for this object is to:
    1. construct
    2. draw on an axes or uiaxes handle
    3. modify its public properties
    4. update the object
    %}
    properties
        y (1,1) double {mustBeReal,mustBeFinite} = 3.0
        line_width (1,1) double {mustBeReal,mustBeFinite,mustBePositive} = 2.0
        line_style (1,1) string = ":"
        color Color = Color.BLACK();
    end
    
    methods
        function obj = dapRecoveryLine()
            obj.line_handle = matlab.graphics.primitive.Line();
        end
        
        function set_parent(obj, axh)
            assert(~isempty(obj.line_handle));
            
            assert(isscalar(axh));
            valid = isa(axh, "matlab.ui.control.UIAxes") ...
                | isa(axh, "matlab.graphics.axis.Axes");
            assert(valid);
            
            obj.line_handle.Parent = axh;
            obj.axes_handle = axh;
            obj.update();
        end
        
        function update(obj)
            h = obj.line_handle;
            h.XData = obj.axes_handle.XLim; % always spans full width
            h.YData = [obj.y obj.y];
            h.LineStyle = obj.line_style;
            h.LineWidth = obj.line_width;
            h.Color = obj.color.rgb;
            h.Annotation.LegendInformation.IconDisplayStyle = "off";
        end
    end
    
    properties (Access = private)
        line_handle matlab.graphics.primitive.Line
        axes_handle
    end
end

