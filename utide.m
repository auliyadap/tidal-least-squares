clear; clc; close all;

% Membaca data dari file Excel
A = xlsread('Malahayati_3 Hari.xlsx'); % Ganti dengan nama file yang sesuai

% Ekstraksi data dari kolom yang sesuai
year = A(:,1);
month = A(:,2);
day = A(:,3);
hour = A(:,4);
minute = A(:,5);
second = A(:,6);
elev = A(:,7);

% Konversi waktu ke format numerik
time = datenum(year, month, day, hour, minute, second);

% Menghitung rata-rata elevasi
s0 = mean(elev);

% Plot data elevasi terhadap waktu
figure;
plot(time, elev);

xlabel('Waktu');
ylabel('Tinggi Pasang Surut');
title('Analisis Pasang Surut');
legend('Data Aktual', 'Konstituen Pasang Surut');

% Analisis data pasang surut menggunakan UTide
lat = -6.7; % Latitude lokasi

% Konstituen pasang surut yang ingin dihitung
cnstit = {'M2', 'S2', 'N2', 'K2', 'K1', 'O1', 'P1', 'Q1', 'M4'}; 

% Menghitung parameter pasang surut menggunakan UTide
coef = ut_solv(time, elev, [], lat, cnstit);

% Menghitung amplitudo pasang surut
amp = abs(coef.A);

% Transformasi Fourier untuk menghitung fase
fourier_transform = fft(coef.A);
phase = angle(fourier_transform); % Menghitung fase dengan FFT

% Menampilkan hasil amplitudo dan fase masing-masing konstituen
for i = 1:length(coef.name)
    fprintf(' %s: Amplitudo = %.3f m, Fase = %.2f deg\n', coef.name{i}, amp(i), phase(i));
end

% Menghitung frekuensi pasang surut
for i = 1:length(coef.name)
    freq(i) = 1 / (12.42 / (i + 1));
end

% Plot hasil analisis
figure;
for i = 1:length(cnstit)
    plot(time, amp(i) * sin(2 * pi * time / 12.42 + phase(i) * pi / 180), ...
        'DisplayName', cnstit{i});
    hold on;
end

xlabel('Waktu (jam)');
ylabel('Elevasi Pasang Surut (m)');
legend;

% Inisialisasi array pasang surut
pasut = zeros(size(time));

% Menghitung superposisi gelombang pasang surut dari semua konstituen
for i = 1:length(cnstit)
    pasut = pasut + amp(i) * sin(2 * pi * time / 12.42 + phase(i) * pi / 180);
end

hold on;
% Plotting data pasang surut dalam bentuk superposisi gelombang
figure;
plot(time, pasut, 'DisplayName', 'Superposisi Gelombang');

% Memberikan label pada sumbu grafik
xlabel('Waktu (jam)');
ylabel('Elevasi Pasang Surut (m)');

% Menampilkan legenda
legend;

%Plot Data
figure;
plot(time, elev);

xlabel('Waktu');
ylabel('Tinggi Pasang Surut');
title('Analisis Pasang Surut');
legend('Data Aktual','Konstituen Pasang Surut');
