classdef Color < handle
    properties (Dependent)
        rgb (1,3) double
        rgb_uint8 (1,3) double
    end
    
    methods (Static)
        function obj = BLACK()
            obj = Color();
            obj.rgb = [0.0 0.0 0.0];
        end
        
        function obj = RED()
            obj = Color();
            obj.rgb = [1.0 0.0 0.0];
        end
        
        function obj = GREEN()
            obj = Color();
            obj.rgb = [0.0 1.0 0.0];
        end
        
        function obj = BLUE()
            obj = Color();
            obj.rgb = [0.0 0.0 1.0];
        end
        
        function obj = CYAN()
            obj = Color();
            obj.rgb = [0.0 1.0 1.0];
        end
        
        function obj = MAGENTA()
            obj = Color();
            obj.rgb = [1.0 0.0 1.0];
        end
        
        function obj = YELLOW()
            obj = Color();
            obj.rgb = [1.0 1.0 0.0];
        end
        
        function obj = WHITE()
            obj = Color();
            obj.rgb = [1.0 1.0 1.0];
        end
    end
    
    methods % properties
        function value = get.rgb(obj)
            value = obj.rgb_impl;
        end
        
        function set.rgb(obj, value)
            assert(isnumeric(value));
            assert(isvector(value));
            assert(numel(value) == 3);
            assert(all(0.0 <= value));
            assert(all(value <= 1.0));
            
            obj.rgb_impl = value;
        end
        
        function value = get.rgb_uint8(obj)
            value = obj.rgb;
            value = value .* 255.0;
            value = round(value);
        end
        
        function set.rgb_uint8(obj, value)
            value = value ./ 255.0;
            obj.rgb = value;
        end
    end
    
    properties (Access = private)
        rgb_impl (1,3) double = [0.0 0.0 0.0];
    end
end

