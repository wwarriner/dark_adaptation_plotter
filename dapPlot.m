classdef dapPlot < handle
    properties
        marker (1,1) string = "d"
        color Color = Color.BLUE()
        visible (1,1) logical = false
        display_name (1,1) string = ""
    end
    
    methods
        function obj = dapPlot(patient)
            %{
            patient - dapPatient
            axh - Axes handle
            %}
            obj.patient = patient;
        end
        
        function delete(obj)
            delete(obj.scatter);
            delete(obj.arrow);
        end
        
        function draw(obj, axh)
            assert(isa(axh, "matlab.graphics.axis.Axes"));
            
            ds = dapScatter(obj.patient.time, obj.patient.sensitivity);
            ds.draw(axh);
            
            r = obj.patient.recovery_time;
            start = [r 3.0]; % 3.0 = recovery_log_sensitivity from config
            stop = [r axh.YLim(2)];
            da = dapArrow(start, stop);
            da.draw(axh);
            
            obj.arrow = da;
            obj.scatter = ds;
            obj.axes_handle = axh;
            
            obj.update();
        end
        
        function update(obj)
            obj.scatter.marker = obj.marker;
            obj.scatter.color = obj.color;
            obj.scatter.visible = obj.visible;
            obj.scatter.display_name = obj.display_name;
            
            obj.arrow.color = obj.color;
            obj.arrow.visible = obj.visible;
            
            obj.scatter.update();
            obj.arrow.update();
        end
    end
    
    properties (Access = private)
        config Settings
        patient dapPatient
        
        scatter dapScatter
        arrow dapArrow
        
        axes_handle matlab.graphics.Graphics
    end
    
    methods (Access = private)
        
    end
end

