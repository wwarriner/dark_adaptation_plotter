classdef dapPlots < handle
    properties (Dependent)
        ids
    end
    
    methods
        function obj = dapPlots(dap_axes)
            plots = containers.Map("keytype", "char", "valuetype", "any");
            
            legend_handle = dap_axes.draw_on(@legend);
            legend_handle.Location = "eastoutside";
            
            obj.dap_axes = dap_axes;
            obj.plots = plots;
            obj.legend_handle = legend_handle;
        end
        
        function value = has(obj, id)
            value = ismember(id, obj.ids);
        end
        
        function add(obj, patients)
            %{
            Inputs
            1. patients - Cell array of structs. Must not contain duplicate ID.
            Must not contain duplicate ID of data already held.
            %}
            new_ids = cellfun(@(x)x.id, patients);
            assert(length(new_ids) == length(unique(new_ids)));
            for id = new_ids(:).'
                assert(~obj.plots.isKey(id));
            end
            
            for i = 1 : numel(patients)
                patient = patients{i};
                plot = dapPlot(patient);
                plot.display_name = patient.id;
                obj.dap_axes.draw_on(@plot.draw);
                id = patient.id;
                obj.plots(char(id)) = plot;
            end
        end
        
        function remove(obj, id)
            plot = obj.plots(char(id));
            delete(plot);
            obj.plots.remove(char(id));
        end
        
        function clear(obj)
            old_ids = obj.ids;
            for i = 1 : numel(old_ids)
                obj.remove(old_ids(i));
            end
        end
        
        function update_visible(obj, id, visible)
            assert(isscalar(visible));
            assert(islogical(visible));
            
            plot = obj.plots(id);
            plot.visible = visible;
            plot.update();
        end
        
        function update_color(obj, id, color)
            assert(isa(color, "Color"));
            
            plot = obj.plots(id);
            plot.color = color;
            plot.update();
        end
        
        function update_marker(obj, id, marker)
            assert(isscalar(marker));
            assert(isstring(marker));
            assert(marker ~= "");
            
            plot = obj.plots(id);
            plot.marker = marker;
            plot.update();
        end
    end
    
    methods % properties
        function value = get.ids(obj)
            value = string(obj.plots.keys());
        end
    end
    
    properties (Access = private)
        dap_axes dapAxes
        plots containers.Map
        legend_handle matlab.graphics.illustration.Legend
    end
end

