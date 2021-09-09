classdef dapPlots < handle
    properties (Dependent)
        ids
    end
    
    methods
        function obj = dapPlots(dap_axes)
            plots = containers.Map("keytype", "char", "valuetype", "any");
            
            obj.dap_axes = dap_axes;
            obj.plots = plots;
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
                plot.legend_display_name = patient.id;
                obj.dap_axes.draw_on(@plot.set_parent);
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
            
            if visible
                plot.apply(@(varargin)obj.dap_axes.add_to_legend(varargin{:}));
            else
                plot.apply(@(varargin)obj.dap_axes.remove_from_legend(varargin{:}));
            end
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
        
        function update_marker_size(obj, id, size)
            assert(isscalar(size));
            assert(isnumeric(size));
            assert(0.0 < size);
            
            plot = obj.plots(id);
            plot.marker_size = size;
            plot.update();
        end
        
        function update_draw(obj)
            current_ids = obj.ids;
            for i = 1 : numel(current_ids)
                plot = obj.plots(current_ids(i));
                if plot.visible
                    plot.update();
                end
            end
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
    end
end

