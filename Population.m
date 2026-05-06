classdef Population < handle
    properties
        Members
        Size
    end
    methods
        function obj = Population(popSize, nFeatures)
            obj.Size = popSize;
            % Pre-allocation: Parçacık dizisini oluştur
            obj.Members = Particle.empty(popSize, 0);
            for i = 1:popSize
                obj.Members(i) = Particle(nFeatures);
            end
        end
        
        function show(obj, it, gBestAcc)
            % Görselleştirme için bir figür seç veya oluştur
            persistent fig_handle;
            if isempty(fig_handle) || ~isvalid(fig_handle)
                fig_handle = figure('Name', 'Canlı Populasyon Takibi', 'Color', 'w');
            else
                figure(fig_handle);
            end
            
            % Tüm parçacıkların ilk iki özelliğe göre dağılımını çiz
            % (Yüksek boyutlu veride ilk 2 boyut genel bir fikir verir)
            allPos = zeros(obj.Size, 2);
            for i = 1:obj.Size
                allPos(i, :) = obj.Members(i).Position(1:2);
            end
            
            scatter(allPos(:,1), allPos(:,2), 50, 'r', 'filled');
            title(['İterasyon: ', num2str(it), ' | G-Best: ', num2str(gBestAcc*100, '%.2f'), '%%']);
            xlabel('Özellik 1 (Olasılık)'); ylabel('Özellik 2 (Olasılık)');
            grid on; axis([0 1 0 1]);
            drawnow;
        end
    end
end