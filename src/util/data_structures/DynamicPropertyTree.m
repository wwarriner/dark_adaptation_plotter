classdef DynamicPropertyTree < dynamicprops ...
        & matlab.mixin.CustomDisplay ...
        & matlab.mixin.Copyable
    methods
        function obj = DynamicPropertyTree(varargin)
            obj.meta_handles____ = containers.Map();
            if nargin == 0
                return;
            elseif nargin == 1
                obj.build(varargin{1}, string(mfilename("class")));
            elseif nargin == 2
                obj.build(varargin{1}, varargin{2});
            else
                assert(false);
            end
        end
        
        function clear(obj)
            obj.make_mutable();
            fields = string(fieldnames(obj));
            for i = 1 : numel(fields)
                key = fields(i);
                value = obj.(key);
                if isobject(value) && ~isstring(value)
                    value.clear();
                end
                obj.rmprop(key);
            end
            obj.make_immutable();
        end
        
        function m = to_map(obj)
            fields = string(fieldnames(obj));
            child_count = numel(fields);
            values = cell(child_count, 1);
            for i = 1 : child_count
                key = fields(i);
                value = obj.(key);
                if isobject(value) && ~isstring(value)
                    value = value.to_map();
                end
                values{i} = value;
            end
            m = containers.Map(fields, values);
        end
        
        function s = to_struct(obj)
            s = struct();
            fields = string(fieldnames(obj));
            child_count = numel(fields);
            for i = 1 : child_count
                key = fields(i);
                value = obj.(key);
                if isobject(value) && ~isstring(value)
                    value = value.to_struct();
                end
                s.(key) = value;
            end
        end
        
        function varargout = subsref(obj, s)
            switch s(1).type
                case "."
                    if 1 < length(s) && ~strcmpi(s(2).type, ".")
                        % function calls
                        [varargout{1:nargout}] = builtin("subsref", obj, s);
                    else
                        % property access
                        full_key = char(s(1).subs);
                        [key, tail] = strtok(full_key, ".");
                        tail = tail(2:end);
                        if ~isprop(obj, key)
                            error(obj.missing_msg(full_key));
                        end
                        v = obj.(key);
                        if isempty(tail)
                            if length(s) == 1
                                [varargout{1:nargout}] = v;
                            else
                                [varargout{1:nargout}] = subsref(v, s(2:end));
                            end
                        else
                            s(1).subs = tail;
                            [varargout{1:nargout}] = subsref(obj.(key), s);
                        end
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
                    % property access
                    full_key = char(s(1).subs);
                    [key, tail] = strtok(full_key, ".");
                    tail = tail(2:end);
                    if ~isprop(obj, key)
                        error(obj.missing_msg(full_key));
                    end
                    if isempty(tail)
                        if length(s) == 1
                            v = varargin{:};
                        else
                            v = subsasgn(obj.(key), s(2:end), varargin{:});
                        end
                    else
                        s(1).subs = tail;
                        v = subsasgn(obj.(key), s, varargin{:});
                    end
                    obj.(key) = v;
                case "()"
                    builtin("subsasgn", obj, s, varargin{:});
                case "{}"
                    builtin("subsasgn", obj, s, varargin{:});
                otherwise
                    assert(false);
            end
        end
        
        function value = properties(obj)
            if nargout == 0
                disp(builtin("properties", obj));
            else
                value = sort(builtin("properties", obj));
            end
        end
        
        function value = fieldnames(obj)
            value = sort(builtin("fieldnames", obj));
        end
        
        function addprop(obj, name)
            if obj.is_mutable()
                obj.meta_handles____(name) = addprop@dynamicprops(obj, name);
            else
                me = error("Adding properties is not allowed.");
                throwAsCaller(me);
            end
        end
        
        function rmprop(obj, name)
            if obj.is_mutable()
                h = obj.meta_handles____(name);
                delete(h);
            else
                me = error("Adding properties is not allowed.");
                throwAsCaller(me);
            end
        end
        
        function build(obj, s, type)
            assert(obj.is_mutable());
            assert(isstruct(s));
            assert(isstring(type));
            
            fields = string(fieldnames(s));
            child_count = numel(fields);
            for i = 1 : child_count
                key = fields(i);
                value = s.(key);
                if isstruct(value)
                    child = feval(type);
                    child.build(value, type);
                    value = child;
                end
                obj.addprop(key);
                obj.(key) = value;
            end
            obj.make_immutable();
        end
    end
    
    methods (Access = protected)
        function group = getPropertyGroups(obj)
            props = properties(obj);
            group = matlab.mixin.util.PropertyGroup(props);
        end
        
        function mutable = is_mutable(obj)
            mutable = obj.is_mutable____;
        end
        
        function make_immutable(obj)
            obj.is_mutable____ = false;
        end
        
        function make_mutable(obj)
            obj.is_mutable____ = true;
        end
        
        function new = copyElement(obj)
            new = feval(class(obj));
            fields = string(fieldnames(obj));
            child_count = numel(fields);
            for i = 1 : child_count
                key = fields(i);
                if isa(obj.(key), "DynamicPropertyTree")
                    value = obj.(key).copy();
                else
                    value = obj.(key);
                end
                new.addprop(key);
                new.(key) = value;
            end
        end
    end
    
    methods (Access = protected, Static)
        function value = missing_msg(key)
            value = sprintf("Missing setting: %s\n", key);
        end
    end
    
    properties (Access = private)
        is_mutable____(1,1) logical = true
        meta_handles____ containers.Map
    end
end

