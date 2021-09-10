classdef Config < DynamicPropertyTree
    properties (Access = private)
        file (1,1) string
    end
    
    methods
        function obj = Config(file)
            if nargin == 0
                return;
            end
            
            file = string(file);
            assert(isscalar(file));
            
            obj.read(file);
        end
        
        function read(obj, file)
            assert(isfile(file));
            
            s = read_json_file(file);
            obj.build(s, string(mfilename('class')));
            
            obj.file = file;
        end
        
        function apply_to(obj, other_obj, silent)
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
        
        function varargout = subsref(obj, s)
            switch s(1).type
                case "."
                    if numel(s) == 1
                        if s(1).subs == "file"
                            varargout{1} = obj.file;
                        else
                            [varargout{1:nargout}] = obj.subsref@DynamicPropertyTree(s);
                        end
                    else
                        [varargout{1:nargout}] = builtin("subsref", obj, s);
                    end
                case "()"
                    [varargout{1:nargout}] = builtin("subsref", obj, s);
                case "{}"
                    [varargout{1:nargout}] = builtin("subsref", obj, s);
                otherwise
                    assert(false);
            end  
        end
        
        function obj = subsasgn(obj, s, varargin)
            switch s(1).type
                case "."
                    if numel(s) == 1
                        if s(1).subs == "file"
                            obj.file = varargin{1};
                        else
                            obj.subsasgn@DynamicPropertyTree(s, varargin{:});
                        end
                    else
                        obj = builtin("subsasgn", obj, s, varargin{:});
                    end
                case "()"
                    obj = builtin("subsasgn", obj, s, varargin{:});
                case "{}"
                    obj = builtin("subsasgn", obj, s, varargin{:});
                otherwise
                    assert(false);
            end  
        end
        
        function save(obj)
            obj.write(obj.file);
        end
        
        function write(obj, file)
            assert(isstring(file));
            
            s = obj.to_struct();
            write_json_file(file, s);
        end
    end
end
