classdef Color < handle
    properties (Dependent)
        rgb (1,3) double
        rgb_uint8 (1,3) double
        lab (1,3) double
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
    
    methods
        function new = inverse_rgb(obj)
            value = imcomplement(obj.rgb);
            new = Color();
            new.rgb = value;
        end
        
        function new = inverse_lab(obj)
            value = obj.lab;
            value(1) = 100.0 - value(1);
            value(2:3) = -value(2:3);
            new = Color();
            new.lab = value;
        end
        
        function show_swatch(obj)
            im = reshape(obj.rgb, [1 1 3]) .* ones(256, 256, 3);
            figure();
            imshow(im);
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
        
        function value = get.lab(obj)
            value = obj.rgb;
            value = rgb2lab(value, "colorspace", "adobe-rgb-1998");
        end
        
        function set.lab(obj, value)
            value = value(:).';
            value = obj.find_closest_lab(value);
            value = lab2rgb(value);
            value = max([value; 0.0 0.0 0.0]);
            value = min([value; 1.0 1.0 1.0]);
            obj.rgb = value;
        end
    end
    
    properties (Access = private)
        rgb_impl (1,3) double = [0.0 0.0 0.0];
    end
    
    methods (Access = private, Static)
        function lab_out = find_closest_lab(lab_init)
            rgb_init = lab2rgb(lab_init);
            i = [find(rgb_init < 0.0) find(1.0 < rgb_init)];
            if all(0.0 <= rgb_init & rgb_init <= 1.0)
                lab_out = lab_init;
                return;
            end
            
            m = lab_init - [50.0 0.0 0.0];
            function c = cost(x)
                lab_c = lab_init - (m .* x);
                rgb_c = lab2rgb(lab_c);
                c = sum(abs(rgb_c(i)));
            end
            x = fminbnd(@cost, 0.0, 1.0);
            lab_out = lab_init - (m .* x);
        end
    end
end

