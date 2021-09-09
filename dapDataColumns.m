classdef dapDataColumns
    %{
    Dev Notes
    The intent of this class is to encapsulate most of the fuzzy loading logic.
    The strategy is basically a triple loop. The outer loop is over any columns
    available in a file being loaded, in the normalize() function.

    The next loop
    is over the columns supplied to this constructor as "names", checking for
    matches. If a match is found that name is removed from further
    consideration.
    
    The last loop is over the "variants" of each of the "names". For example
    "sensitivity" and "value" may be equally valid, so we want to check for
    both.
    
    Currently we'll accept as a match anything that startsWith() or endsWith()
    any of the variants, though this is open to ideas.
    %}
    
    methods
        function obj = dapDataColumns(names, variants)
            %{
            Inputs:
            1. names - list of canonical required column names
            2. variants - cell array of string arrays, same length as names,
            variants of canonical name allowed as input
            %}
            assert(isstring(names));
            assert(iscell(variants));
            for i = 1 : numel(variants)
                variant = variants{i};
                assert(isempty(variant) || isstring(variant));
            end
            assert(numel(names) == numel(variants));
            for i = 1 : numel(names)
                variants{i} = [variants{i} names(i)];
            end
            v = containers.Map(cellstr(names), variants);
            obj.variants = v;
        end
        
        function [new_cols, missed] = normalize(obj, cols)
            %{
            Normalizes columns. Column names are mangled to contain only
            lowercase alphanumeric and "_". All punctuation and inline
            whitespace are replaced by "_". Repetitions of "_" are removed.
            If a match is found to a name or variant, the column is replaced by
            the associated name.
            
            Inputs:
            1. cols - string array of columns to normalize
            
            Outputs:
            1. new_cols - string array of normalized columns
            2. missed - any names missed during normalization
            %}
            
            assert(isstring(cols));
            new_cols = cols;
            names_to_check = obj.names;
            for i = 1 : numel(cols)
                col = cols(i);
                col = obj.mangle(col);
                [new_cols(i), names_to_check] = obj.normalize_column(col, names_to_check);
            end
            missed = names_to_check;
        end
    end
    
    properties (Access = private)
        variants containers.Map
    end
    
    properties (Access = private, Dependent)
        names (1,:) string
    end
    
    methods (Access = private)
        function [new_col, names_to_check] = normalize_column(obj, col, names_to_check)
            %{
            Attempts to find a matching name in input list of names. Returns
            after first match. Output will be input if no match found, may be
            changed to canonical form if match found, if not already in
            canonical form. Available columns will be returned with match
            removed.
            
            Inputs:
            1. col - column name to find a match for
            2. names_to_check - names to check for a match for col
            
            Outputs:
            1. new_col - new column name, may be same as input
            2. names_to_check - same as input with match removed if found
            %}
            new_col = col;
            for j = 1 : numel(names_to_check)
                name = names_to_check{j};
                if obj.check(name, col)
                    new_col = name;
                    names_to_check(j) = [];
                    break;
                end
            end
        end
        
        function match = check(obj, name, col)
            %{
            Checks if col matches a variant for given name.
            %}
            v = obj.variants(name);
            match = false;
            for i = 1 : numel(v)
                expected = v(i);
                match = match | startsWith(col, expected);
                match = match | endsWith(col, expected);
            end
        end
    end
    
    methods (Access = private, Static)
        function s = mangle(s)
            %{
            Mangles a string into a form acceptable to MATLAB tables. MATLAB has
            yet to provide a stable API for this feature, so we have made a
            stable version ourselves.
            
            Transforms any string into lowercase alphanumeric and literal
            underscore.
            %}
            % replace all punctuation with "_"
            s = regexprep(s, "([`=\[\]\\;',/~!@#\$%\^&\*\(\)\+{}|:""<>\?\-\.])", "_");
            % replace inline whitespace with "_"
            s = regexprep(s, "([ \t])", "_");
            % deduplicate "_"
            s = regexprep(s, "([_]){2,}", "_");
            s = strip(s, "_");
            s = lower(s);
        end
    end
    
    methods % private accessors
        function value = get.names(obj)
            value = string(obj.variants.keys());
        end
    end
end

