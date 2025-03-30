clc; clear; close all;

%% 1. Load Data dari File BIG (Misalnya CSV atau Excel)
filename = 'Malahayati_3 Hari.txt'; % Ganti dengan nama file yang sesuai
data = readmatrix(filename);

% Ekstrak komponen waktu dan elevasi
time_num = datenum(data(:,1:6)); % Konversi ke format numerik
elevasi = data(:,7);

% Pastikan data tidak ada NaN
valid_idx = ~isnan(elev);
time = time(valid_idx);
elev = elev(valid_idx);

%% 2. Analisis Harmonisa dengan UTide
addpath('path_ke_utide');
cnstit = {}; % Biarkan kosong untuk memilih konstituen optimal secara otomatis
coef = ut_solv(time, elev, [], lat, cnstit, 'LinCI', 'NoTrend', 'Rmin', 0.95);

%% 3. Prediksi Pasang Surut
time_pred = linspace(min(time_num), max(time_num), 1000); % Buat rentang waktu prediksi
elevasi_pred = ut_reconstr(time_pred, coef); % Rekonstruksi sinyal pasut

t_awal = datenum([2019 02 12 00 00 00]); % (YYYY MM DD HH MM SS)
t_akhir = datenum([2019 02 14 23 59 59]); % (YYYY MM DD HH MM SS)

% Buat vektor waktu dengan interval per jam
t_future = linspace(t_awal, t_akhir, (t_akhir - t_awal) * 24);
%% 4. Plot Overlay antara Data BIG & Prediksi
figure;
plot(time, elev, 'b-', 'LineWidth', 1.5); hold on; % Data Observasi (BIG)
plot(time_pred, elev_pred, 'r--', 'LineWidth', 2); % Hasil Prediksi UTide
datetick('x', 'dd-mmm HH:MM', 'keeplimits'); % Format waktu
xlabel('Waktu'); ylabel('Tinggi Muka Air (m)');
legend('Data Observasi (BIG)', 'Prediksi UTide');
title('Perbandingan Data BIG dengan Prediksi UTide');
grid on;
