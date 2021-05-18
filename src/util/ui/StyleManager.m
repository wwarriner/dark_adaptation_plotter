classdef StyleManager < handle
    methods
        function obj = StyleManager(ui_t)
            obj.style_key_order_map = containers.Map();
            obj.vargs = containers.Map();
            obj.ui_t = ui_t;
        end
        
        function value = has_style(obj, key)
            value = obj.style_key_order_map.isKey(key);
        end
        
        function add_style(obj, key, style, varargin)
            assert(isa(style, "matlab.ui.style.Style"));
            assert(~obj.has_style(key));
            
            addStyle(obj.ui_t, style, varargin{:});
            obj.styles = [obj.styles; style];
            order = numel(obj.styles);
            obj.style_key_order_map(key) = order;
            obj.vargs(key) = varargin;
        end
        
        function style = get_style(obj, key)
            assert(obj.has_style(key));
            
            order = obj.style_key_order_map(key);
            style = obj.styles(order);
        end
        
        function update_style(obj, key, style)
            v = obj.vargs(key);
            obj.remove_style(key);
            obj.add_style(key, style, v{:});
        end
        
        function style = remove_style(obj, key)
            assert(obj.has_style(key));
            
            order = obj.style_key_order_map(key);
            style = obj.styles(order);
            
            removeStyle(obj.ui_t, order); % may need to swallow MATLAB:badsubscript
            obj.style_key_order_map.remove(key);
            obj.vargs.remove(key);
            obj.styles(order) = [];
            obj.reset_orders(order);
        end
        
        function clear(obj)
            keys = obj.style_key_order_map.keys();
            for i = 1 : numel(keys)
                obj.remove_style(keys{i});
            end
        end
    end
    
    properties (Access = private)
        ui_t matlab.ui.control.Table
        
        style_key_order_map containers.Map
        styles (:,1) matlab.ui.style.Style
        vargs containers.Map
    end
    
    methods (Access = private)
        function reset_orders(obj, order_removed)
            keys = obj.style_key_order_map.keys();
            for i = 1 : numel(keys)
                value = obj.style_key_order_map(keys{i});
                if order_removed < value
                    obj.style_key_order_map(keys{i}) = value - 1;
                end
            end
        end
    end
end

