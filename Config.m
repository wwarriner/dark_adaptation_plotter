classdef Config < DynamicPropertyTree
    methods
        function obj = Config(file)
            if nargin == 0
                return;
            end
            
            file = string(file);
            assert(isscalar(file));
            
            obj.read_from_file(file);
        end
        
        function read_from_file(obj, file)
            assert(isfile(file));
            
            s = read_json_file(file);
            obj.build(s, string(mfilename('class')));
            
            obj.file = file;
        end
        
        function apply(obj, other_obj, silent)
            if nargin < 3
                silent = false;
            end
            fields = string(fieldnames(other_obj));
            count = numel(fields);
            for i = 1 : count
                key = fields(i);
                mp = findprop(other_obj, key);
                if ~strcmpi(mp.SetAccess, 'public')
                    continue;
                end
                if ~isprop(obj, key)
                    if ~silent
                        fprintf(2, obj.missing_msg(key));
                    end
                    continue;
                end
                other_obj.(key) = obj.(key);
            end
        end
        
        function obj = subsasgn(obj, s, varargin)
            obj = subsasgn@DynamicPropertyTree(obj, s, varargin{:});
            if obj.file ~= "" && obj.is_mutable()
                obj.write(obj.file);
            end
        end
        
        function write(obj, file)
            assert(isstring(file));
            
            s = obj.struct();
            write_json_file(file, s);
        end
        
        function value = properties( obj )
            value = properties@DynamicPropertyTree( obj );
        end
    end
    
    properties (Access = private)
        file (1,1) string
    end
end

