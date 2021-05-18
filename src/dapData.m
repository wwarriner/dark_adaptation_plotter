classdef dapData < handle
    properties (SetAccess = private)
        ids (:,1) string
    end
    
    methods
        function obj = dapData()
            obj.clear();
        end
        
        function clear(obj)
            obj.patients = containers.Map("keytype", "char", "valuetype", "any");
        end
        
        function load(obj, file_path)
            %{
            Overwrites data for existing IDs.
            %}
            t = readtable(file_path);
            % TODO mangle t.Properties.VariableNames
            % TODO check mangled t.Properties.VariableNames against canonical
            sorted_names = sort(t.Properties.VariableNames);
            t = t(:, sorted_names);
            t.PPT_ID = string(t.PPT_ID);
            
            pt_ids = unique(t.PPT_ID);
            %pt_ids = natsort(pt_ids); % https://www.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort
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
            end
        end
        
        function value = has(obj, id)
            value = obj.patients.isKey(char(id));
        end
        
        function value = get(obj, id)
            assert(obj.has(id));
            
            value = obj.patients(char(id));
        end
        
        function [patients, ids] = get_all_except(obj, ids)
            all_ids = string(obj.patients.keys());
            all_except_ids = setdiff(all_ids, ids);
            count = numel(all_except_ids);
            patients = cell(count, 1);
            for i = 1 : count
                patients{i} = obj.get(all_except_ids(i));
            end
            ids = all_except_ids;
        end
        
        function remove(obj, id)
            assert(obj.has(id));
            
            obj.patients.remove(char(id));
        end
    end

    methods % properties
        function ids = get.ids(obj)
            ids = string(obj.patients.keys());
        end
    end
    
    properties (Access = private)
        patients containers.Map
    end
end

