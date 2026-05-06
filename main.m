%% TEMİZLİK VE HAZIRLIK
clear; clc; close all;
rng(42); % Tekrarlanabilirlik için

%% 1. VERİ YÜKLEME (Ionosphere)
fprintf('Ionosphere Veri Seti Yükleniyor...\n');
load ionosphere; % MATLAB yerleşik veri seti

% X (34 özellik) ve Y (0-1) hazırlığı
X_raw = X; 
Y_raw = strcmp(Y, 'g'); % 'good' = 1, 'bad' = 0

% Veriyi karıştır (Shuffle)
idx = randperm(size(X_raw, 1));
X_raw = X_raw(idx, :);
Y_raw = Y_raw(idx, :);

% Normalizasyon (KNN performansı için hayati)
X_norm = (X_raw - mean(X_raw)) ./ (std(X_raw) + 1e-6);

%% 2. "BEFORE" ANALİZİ (Özellik Seçimi Öncesi)
% Tüm özellikleri kullanarak temel başarıyı ölçelim
evaluator = Evaluator(X_norm, Y_raw);
fullMask = true(1, size(X_norm, 2));
[fullAcc, ~] = evaluator.calculate(fullMask);

fprintf('\n%s\n', repmat('*', 1, 50));
fprintf('[BEFORE] Tüm Özellikler Kullanılıyor: %d Adet\n', size(X_norm, 2));
fprintf('Başlangıç Doğruluğu: %.2f\n', fullAcc * 100);
fprintf('%s\n', repmat('*', 1, 50));

%% 3. PSO BAŞLATMA VE BAŞLANGIÇ POPÜLASYONU
pso = PSO_Manager(15,10 , evaluator); % 20 Parçacık, 25 İterasyon

% --- İSTEK: Başlangıç Popülasyonunu Görselleştir ---
fprintf('\nBAŞLANGIÇ: İlk popülasyon rastgele dağıtılıyor...\n');
pso.Pop.show(0, 0); % 0. iterasyon görseli
pause(2); % İlk hali görebilmek için kısa bir duraklama

% Optimizasyonu Başlat (İçeride iterasyonlar dönecek)
pso.solve();

%% 4. "AFTER" ANALİZİ VE KIYASLAMA
bestFeatIdx = find(pso.GBestPos > 0.5);
nBest = length(bestFeatIdx);

fprintf('\n%s\n', repmat('*', 1, 50));
fprintf('[AFTER] PSO İle Optimize Edilmiş Sonuç:\n');
fprintf('Seçilen Özellik Sayısı: %d / %d\n', nBest, size(X_norm, 2));
fprintf('Final Doğruluğu: %.2f\n', pso.GBestFit * 100);

% Verimlilik Artışı Hesabı
improvement = (pso.GBestFit - fullAcc) * 100;
fprintf('Başarı Artış Oranı: %%+%.2f\n', improvement);
fprintf('Elenen Özellik Sayısı: %d\n', size(X_norm, 2) - nBest);
fprintf('%s\n', repmat('*', 1, 50));

% Final Sonuçlarını Yazdır
colNames = arrayfun(@(n) sprintf('Feat_%d', n), 1:size(X_norm, 2), 'UniformOutput', false);
% Eski karmaşık çıktı yerine şunu kullan:
fprintf('Seçilen Kritik Özellikler:\n');
selectedNames = colNames(bestFeatIdx);
for k = 1:length(selectedNames)
    fprintf('  - %s\n', selectedNames{k});
end
disp(colNames(bestFeatIdx));