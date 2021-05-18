classdef FontSettings < handle
    methods
        function obj = FontSettings(name, size, weight, angle)
            obj.FontName = name;
            obj.FontSize = size;
            obj.FontWeight = weight;
            obj.FontAngle = angle;
        end
        
        function register(obj, other, fn)
            if nargin < 3
                fn = @()[];
            end
            obj.registered = [obj.registered {other}];
            obj.functions = [obj.functions {fn}];
        end
        
        function ui_get(obj)
            s.FontName = obj.FontName;
            s.FontSize = obj.FontSize;
            s.FontWeight = obj.FontWeight;
            s.FontAngle = obj.FontAngle;
            s = uisetfont(s);
            obj.FontName = s.FontName;
            obj.FontSize = s.FontSize;
            obj.FontWeight = s.FontWeight;
            obj.FontAngle = s.FontAngle;
            obj.update();
        end
        
        function update(obj)
            for i = 1 : numel(obj.registered)
                try
                    other = obj.registered{i};
                    other.FontName = obj.FontName;
                    other.FontSize = obj.FontSize;
                    other.FontWeight = obj.FontWeight;
                    other.FontAngle = obj.FontAngle;
                    fn = obj.functions{i};
                    fn();
                catch err
                    warning(err.message);
                    continue;
                end
            end
        end
    end
    
    properties
        FontName (1,1) string
        FontSize (1,1) double
        FontWeight (1,1) string
        FontAngle (1,1) string
        registered (1,:) cell
        functions (1,:) cell
    end
end

