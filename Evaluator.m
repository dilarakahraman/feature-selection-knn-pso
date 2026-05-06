classdef Evaluator < handle
    properties
        X, Y
    end
    methods
        function obj = Evaluator(X, Y)
            obj.X = X;
            obj.Y = Y;
        end
        
        function [fitness, stats] = calculate(obj, binaryMask)
            % Varsayılan değerler
            stats = struct('acc', 0, 'confMat', [], 'labels', [], 'scores', []);
            if sum(binaryMask) == 0, fitness = 0; return; end
            
            X_sub = obj.X(:, binaryMask == 1);
            
            % KNN Modeli ve Çapraz Doğrulama
            knnModel = fitcknn(X_sub, obj.Y, 'NumNeighbors', 3, 'Standardize', true);
            cvModel = crossval(knnModel, 'KFold', 5);
            
            % Tahminleri ve Skorları Al (ROC için skorlar gereklidir)
            [predictions, scores] = kfoldPredict(cvModel);
            
            fitness = 1 - kfoldLoss(cvModel); % Fitness hala Accuracy
            
            % İstatistikleri doldur
            stats.acc = fitness;
            stats.confMat = confusionmat(obj.Y, predictions);
            stats.labels = obj.Y;
            stats.scores = scores(:, 2); % Pozitif sınıfın (Fraud) skorları
        end
    end
end