classdef dapData < handle
    properties (SetAccess = private, Dependent)
        ids (:,1) string
    end
    
    methods
        function load(obj, file_path)
            obj.patients = containers.Map("keytype", "char", "valuetype", "any");
            
            t = readtable(file_path);
            % TODO mangle t.Properties.VariableNames
            % TODO check mangled t.Properties.VariableNames against canonical
            sorted_names = sort(t.Properties.VariableNames);
            t = t(:, sorted_names);
            t.PPT_ID = string(t.PPT_ID);
            
            for id = unique(t.PPT_ID).'
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
            end
        end
        
        function dp = get(obj, id)
            dp = obj.patients(char(id));
        end
    end

    methods % properties
        function ids = get.ids(obj)
            ids = obj.patients.keys();
            ids = string(ids);
            ids = natsort(ids); % https://www.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort
        end
    end
    
    properties (Access = private)
        patients containers.Map
    end
    
    properties (Access = private, Constant)
        
    end
    
    methods (Access = private)
        
    end
end

