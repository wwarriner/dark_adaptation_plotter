classdef dapData < handle
    properties (SetAccess = private)
        ids (:,1) string
    end
    
    methods
        function load(obj, file_path)
            obj.patients = containers.Map("keytype", "char", "valuetype", "any");
            obj.order = containers.Map("keytype", "double", "valuetype", "char");
            
            t = readtable(file_path);
            % TODO mangle t.Properties.VariableNames
            % TODO check mangled t.Properties.VariableNames against canonical
            sorted_names = sort(t.Properties.VariableNames);
            t = t(:, sorted_names);
            t.PPT_ID = string(t.PPT_ID);
            
            pt_ids = unique(t.PPT_ID);
            pt_ids = natsort(pt_ids); % https://www.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort
            start_order = numel(obj.ids);
            for i = 1 : numel(pt_ids)
                id = pt_ids(i);
                
                subset = t(t.PPT_ID == id, :);
                
                recovery_time = unique(subset.RIT);
                % TODO handle non-uniform RIT
                
                dp = dapPatient( ...
                    id, ...
                    recovery_time, ...
                    subset.threshold_time_minutes1, ...
                    subset.threshold_value1 ...
                    );
                obj.patients(char(id)) = dp;
                obj.order(start_order + i) = char(id);
            end
        end
        
        function dp = get(obj, id)
            dp = obj.patients(char(id));
        end
    end

    methods % properties
        function ids = get.ids(obj)
            ids = string(obj.order.values());
        end
    end
    
    properties (Access = private)
        patients containers.Map
        order containers.Map
    end
    
    properties (Access = private, Constant)
        
    end
    
    methods (Access = private)
        
    end
end

