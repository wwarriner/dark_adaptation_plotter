classdef dapPlot < handle
    properties
        marker (1,1) string = "d"
        marker_size (1,1) double {mustBeReal,mustBeFinite,mustBePositive} = 8
        color Color = Color.BLUE()
        
        arrow_line_width (1,1) double {mustBeReal,mustBeFinite,mustBePositive} = 2
        
        visible (1,1) logical = false;
    end
    
    methods
        function obj = dapPlot(patient)
            %{
            patient - dapPatient
            axh - Axes handle
            %}
            obj.patient = patient;
        end
        
        function draw(obj, axh)
            assert(isa(axh, "matlab.graphics.axis.Axes"));
            
            ph = plot(axh, obj.patient.time, obj.patient.sensitivity);
            obj.data_plot_handle = ph;
            
            r = obj.patient.recovery_time;
            start = [r 3.0]; % 3.0 = recovery_log_sensitivity from config
            stop = [r axh.YLim(2)];
            da = dapArrow(start, stop);
            da.draw(axh);
            obj.arrow = da;
            
            obj.axes_handle = axh;
            
            obj.update_data();
            obj.update_arrow();
        end
        
        function update_data(obj)
            obj.data_plot_handle.Visible = obj.visible;
            obj.data_plot_handle.MarkerSize = obj.marker_size;
            obj.data_plot_handle.Marker = obj.marker;
            obj.data_plot_handle.MarkerFaceColor = obj.color.rgb;
            obj.data_plot_handle.MarkerEdgeColor = obj.color.rgb;
            obj.data_plot_handle.Color = "none";
        end
        
        function update_arrow(obj)
            obj.arrow.visible = obj.visible;
            obj.arrow.color = obj.color;
            obj.arrow.line_width = obj.arrow_line_width;
            obj.arrow.update();
        end
    end
    
    properties (Access = private)
        patient dapPatient
        
        data_plot_handle matlab.graphics.Graphics
        arrow dapArrow
        
        axes_handle matlab.graphics.Graphics
    end
    
    methods (Access = private)
        
    end
end

