classdef PSO_Manager < handle
    properties
        Pop, Eval, MaxIt
        GBestPos, GBestFit = -inf
        GBestStats
        ConvergenceCurve % Başarı takibi için
        w = 0.7, c1 =2.1, c2 = 1.9   %bilişsel bileşen,sosyal bileşen
    end
    
    methods
        function obj = PSO_Manager(popSize, maxIt, evaluator)
            obj.MaxIt = maxIt;
            obj.Eval = evaluator;
            obj.Pop = Population(popSize, size(evaluator.X, 2));
            obj.ConvergenceCurve = zeros(1, maxIt);
        end
        
        function solve(obj)
            nF = size(obj.Eval.X, 2);
            
            fprintf('\n%s\n', repmat('=', 1, 95));
            fprintf('   PSO ÖZNİTELİK SEÇİMİ VE ANALİZ MOTORU BAŞLATILDI\n');
            fprintf('%s\n', repmat('=', 1, 95));

            for it = 1:obj.MaxIt
                fprintf('\n--- İTERASYON %02d / %02d ---\n', it, obj.MaxIt);
                fprintf('%-4s | %-8s | %-12s | %-35s | %-10s\n', ...
                    'P#', 'Acc', 'P-Best', 'Özellik Maskesi (■:Seçildi, □:Elendi)', 'Sayı');
                fprintf('%s\n', repmat('-', 1, 95));
                
                for i = 1:obj.Pop.Size
                    p = obj.Pop.Members(i);
                    mask = p.Position > 0.5;
                    [fit, stats] = obj.Eval.calculate(mask);
                    
                    % Kişisel En İyi (P-Best) Güncelleme
                    if fit > p.BestFit
                        p.BestFit = fit; p.BestPos = p.Position;
                    end
                    
                    % Küresel En İyi (G-Best) Güncelleme
                    if fit > obj.GBestFit
                        obj.GBestFit = fit; obj.GBestPos = p.Position;
                        obj.GBestStats = stats;
                    end
                    
                    % --- Görsel Vektör Oluşturma ---
                    visualStr = char(ones(1, length(mask)) * '□');
                    visualStr(mask) = '■'; 
                    
                    % Terminal Çıktısı (Şık ve Hizalı)
                    fprintf('P%02d | %6.2f%% | %10.2f%% | [%-35s] | %2d Feat\n', ...
                        i, fit*100, p.BestFit*100, visualStr, sum(mask));
                end
                
                % Yakınsama eğrisini kaydet
                obj.ConvergenceCurve(it) = obj.GBestFit;
                
                % Hareket Güncelleme (Velocity & Position)
                for i = 1:obj.Pop.Size
                    p = obj.Pop.Members(i);
                    r1 = rand(1, nF); r2 = rand(1, nF);
                    p.Velocity = obj.w*p.Velocity + ...
                                 obj.c1*r1.*(p.BestPos - p.Position) + ...
                                 obj.c2*r2.*(obj.GBestPos - p.Position);
                    
                    % Konum güncelleme ve sınır kontrolü
                    p.Position = max(min(p.Position + p.Velocity, 1), 0);
                end
                
                % Canlı Scatter Plot Güncelleme
                obj.Pop.show(it, obj.GBestFit);
            end
            
            % Tüm süreç bittiğinde analiz paneli aç
            obj.plotFinalResults();
        end
        
        function plotFinalResults(obj)
            fig = figure('Name', 'PSO Model Analiz Paneli', 'Color', 'w', 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.7]);
            
            % 1. Yakınsama Eğrisi (Fitness Curve)
            subplot(2, 2, 1);
            plot(obj.ConvergenceCurve, 'LineWidth', 2, 'Color', [0 0.5 0.8], 'Marker', 's');
            title('Algoritma Yakınsama Grafiği');
            xlabel('İterasyon'); ylabel('Doğruluk (Accuracy)');
            grid on;

            % 2. Karışıklık Matrisi (Confusion Matrix)
            subplot(2, 2, 2);
            confusionchart(obj.GBestStats.confMat, {'Negatif', 'Pozitif'});
            title('Final Karışıklık Matrisi');

            % 3. ROC Eğrisi (AUC Analizi)
            subplot(2, 2, 3);
            [Xroc, Yroc, ~, AUC] = perfcurve(obj.GBestStats.labels, obj.GBestStats.scores, 1);
            plot(Xroc, Yroc, 'LineWidth', 2, 'Color', 'r');
            hold on; plot([0 1], [0 1], '--k'); hold off;
            title(['ROC Eğrisi (AUC: ', num2str(AUC, '%.4f'), ')']);
            xlabel('FPR'); ylabel('TPR'); grid on;

            % 4. Özellik Seçim Dağılımı (Bar Chart)
            subplot(2, 2, 4);
            bar(obj.GBestPos, 'FaceColor', [0.5 0.2 0.6]);
            title('Seçilen Özelliklerin Ağırlık Dağılımı');
            xlabel('Özellik İndeksi'); ylabel('Olasılık Değeri');
            grid on;
        end
    end
end