classdef Particle < handle
    properties
        Position
        Velocity
        BestPos
        BestFit = -inf
    end
    
    methods
        function obj = Particle(nFeatures)
            % Konum: 1 satır, nFeatures sütun (0 ile 1 arası)
            obj.Position = rand(1, nFeatures);
            % Hız: Küçük rastgele değerler
            obj.Velocity = (rand(1, nFeatures) - 0.5) * 0.1;
            obj.BestPos = obj.Position;
        end
    end
end