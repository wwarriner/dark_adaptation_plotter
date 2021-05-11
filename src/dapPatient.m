classdef dapPatient < handle
    properties (SetAccess = private)
        id (1,1) string
        recovery_time (1,1) double
        time (:,1) double
        sensitivity (:,1) double
    end
    
    properties (SetAccess = private, Dependent)
        data (:,2) double % time, sensitivity
    end
    
    methods
        function obj = dapPatient(id, recovery_time, time, sensitivity)
            d = [time sensitivity];
            time = d(:, 1);
            sensitivity = d(:, 2);
            
            obj.id = id;
            obj.recovery_time = recovery_time;
            obj.time = time;
            obj.sensitivity = sensitivity;
        end
    end
    
    methods % properties
        function data = get.data(obj)
            data = [obj.time obj.sensitivity];
        end
    end
end

