classdef dapData < handle
    %{
    Dev Notes:
    The intent of this class is to facilitate interfacing with the data. It
    features a means to normalize various column names from different or
    inconsistent file sources into a unified, canonical set of variable names.
    
    The data is ultimately stored in a map container keyed to the ID column.
    While data could be stored in a table, we wanted a way to enforce uniqueness
    of ids.
    %}
    
    properties (SetAccess = private)
        ids (:,1) string
    end
    
    properties (Constant)
        % REQUIRED COLUMNS
        ID = "id"
        RECOVERY_TIME = "recovery_time"
        TIME = "time"
        SENSITIVITY = "sensitivity"
    end
    
    methods
        function obj = dapData()
            obj.clear();
        end
        
        function clear(obj)
            %{
            Clears contents, resets to original state.
            %}
            obj.patients = containers.Map("keytype", "char", "valuetype", "any");
        end
        
        function add_data(obj, t)
            %{
            Adds tabular data, keyed to ID column. Overwrites existing data if
            there is a collision.
            
            Inputs:
            1. t - Table with at least the columns in % REQUIRED COLUMNS
            %}
            
            t = obj.prepare_table(t);
            sorted_names = sort(t.Properties.VariableNames);
            t = t(:, sorted_names);
            t.(obj.ID) = string(t.(obj.ID));
            
            pt_ids = unique(t.(obj.ID));
            for i = 1 : numel(pt_ids)
                id = pt_ids(i);
                rows = t.(obj.ID) == id;
                subset = t(rows, :);
                recovery_time = unique(subset.(obj.RECOVERY_TIME));
                if 1 < numel(recovery_time)
                    warning(...
                        "dapData:ambiguousRecoveryTimeWarning", ...
                        "more than one unique recovery time found for id %s, skipping", ...
                        id ...
                        );
                    continue;
                end
                dp = dapPatient( ...
                    id, ...
                    recovery_time, ...
                    subset.(obj.TIME), ...
                    subset.(obj.SENSITIVITY) ...
                    );
                obj.patients(char(id)) = dp;
            end
        end
        
        function value = has(obj, id)
            %{
            Checks for the presence of ID given by id.
            %}
            value = obj.patients.isKey(char(id));
        end
        
        function value = get(obj, id)
            %{
            Returns the dapPatient object associated with ID given by id.
            %}
            assert(obj.has(id));
            
            value = obj.patients(char(id));
        end
        
        function [patients, ids] = get_all_except(obj, ids)
            %{
            Returns all dapPatient objects except those associated with ids.
            Also returns list of ids.
            
            Output:
            1. patients - cell vector of dapPatient objects
            2. ids - string vector of ids assoicated with patient objects, of
            the same length as patients
            %}
            all_except_ids = setdiff(obj.ids, ids);
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
        patients containers.Map %#ok<MCHDT>
    end
    
    methods (Access = private)
        function t = prepare_table(~, t)
            names = [...
                dapData.ID ...
                dapData.RECOVERY_TIME ...
                dapData.TIME ...
                dapData.SENSITIVITY ...
                ];
            
            
            % TODO legacy code here, we don't necessarily need to do a lot of
            % this column name wrangling anymore.
            % We probably don't need variants at all here.
            variants = {...
                [] ...
                "rit" ...
                "threshold_time" ...
                ["value", "threshold_value"]
                };
            allowed_cols = dapDataColumns(names, variants);
            cols = t.Properties.VariableNames;
            [cols, missed] = allowed_cols.normalize(string(cols));
            if ~isempty(missed)
                error(...
                    "dapData:missingColumnsError", ...
                    "missing columns:" + newline + strjoin(missed, newline) ...
                    );
            end
            t.Properties.VariableNames = cols;
        end
        
        function new_cols = interpret_columns(obj, cols)
            %{
            Looking for variations of the columns needed under
            % REQUIRED COLUMNS
            
            For each input column, matches against known columns.
            If match is found, replace input with known, remove it from list of
            known, move to the next input.
            %}
            assert(isstring(cols));
            req_cols = obj.REQUIRED_COLUMNS;
            new_cols = cols;
            for i = 1 : numel(cols)
                col = cols(i);
                col = obj.mangle(col);
                for j = 1 : numel(req_cols)
                    req_col = req_cols{j};
                    if req_col.check(col)
                        new_cols(i) = req_col.name;
                        req_cols(j) = [];
                        break;
                    end
                end
            end
        end
    end
end

