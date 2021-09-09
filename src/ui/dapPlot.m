classdef dapPlot < handle
    %{
    Encapsulates dark adaptation plot, including both scatter and arrow.
    
    The strategy for this object is to:
    1. construct
    2. draw on an axes or uiaxes handle
    3. modify its public properties
    4. update the object
    %}
    properties
        marker (1,1) string = "d"
        marker_size (1,1) double {mustBeReal,mustBeFinite,mustBePositive} = 8
        color Color = Color.BLUE()
        visible (1,1) logical = false
        legend_display_name (1,1) string = ""
    end
    
    methods
        function obj = dapPlot(patient)
            %{
            Inputs:
            1. patient - scalar dapPatient object
            %}
            assert(isscalar(patient));
            assert(isa(patient, "dapPatient"));
            
            obj.patient = patient;
            obj.arrow = dapArrow();
            obj.scatter = dapScatter();
        end
        
        function set_parent(obj, axh)
            assert(~isempty(obj.arrow));
            assert(~isempty(obj.scatter));
            
            assert(isscalar(axh));
            valid = isa(axh, "matlab.ui.control.UIAxes") ...
                | isa(axh, "matlab.graphics.axis.Axes");
            assert(valid);
            
            obj.arrow.set_parent(axh);
            obj.scatter.set_parent(axh);
            obj.axes_handle = axh;
            obj.update();
        end
        
        function varargout = apply(obj, fn)
            %{
            fn - function which accepts plot handle and string label
            %}
            [varargout{1:nargout}] = obj.scatter.apply(fn);
        end
        
        function update(obj)
            assert(~isempty(obj.arrow));
            assert(~isempty(obj.scatter));
            
            obj.scatter.x = obj.patient.time;
            obj.scatter.y = obj.patient.sensitivity;
            obj.scatter.marker = obj.marker;
            obj.scatter.marker_size = obj.marker_size;
            obj.scatter.color = obj.color;
            obj.scatter.visible = obj.visible;
            obj.scatter.legend_display_name = obj.legend_display_name;
            
            r = obj.patient.recovery_time;
            obj.arrow.head = [r obj.axes_handle.YLim(2)]; % always touches edge of axes
            obj.arrow.tail = [r 3.0]; % always starts at recovery line, 3.0 = recovery_log_sensitivity from config
            % TODO tie this to recovery line
            obj.arrow.color = obj.color;
            obj.arrow.visible = obj.visible;
            
            obj.scatter.update();
            obj.arrow.update();
        end
    end
    
    properties (Access = private)
        config Config
        patient dapPatient
        
        arrow dapArrow
        scatter dapScatter
        
        axes_handle
    end
    
    methods (Access = private)
        
    end
end

