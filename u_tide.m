% Script MATLAB untuk Analisis Pasang Surut dengan UTide
% Menggunakan data dalam format: yyyy mm dd hh mm ss elevasi

clc; clear; close all;

%% 1. Load Data Pasang Surut
filename = 'Malahayati_2019.txt'; % Ganti dengan nama file yang sesuai
data = readmatrix(filename);

% Ekstrak komponen waktu dan elevasi
time_num = datenum(data(:,1:6)); % Konversi ke format numerik
elevasi = data(:,7);

% Hitung rata-rata elevasi
MSL_data = mean(elevasi);

%% 2. Analisis Harmonik Menggunakan UTide
addpath('path_ke_utide'); % Pastikan UTide sudah terinstal dan path ditambahkan

% Estimasi konstituen pasut
constituents = 'auto'; % Mode otomatis agar mendapatkan sebanyak mungkin konstituen
coef = ut_solv(time_num, elevasi, [], 10, 'auto', 'LinCI', 'NoTrend', 'Rmin', 0.95);

% Tampilkan hasil analisis harmonik
disp('Konstituen yang ditemukan:');
disp(coef.name); % Menampilkan nama konstituen

disp('Amplitudo konstituen (meter):');
disp(coef.A); % Amplitudo konstituen

disp('Fase konstituen (derajat):');
disp(coef.g); % Fase konstituen

% Simpan hasil dalam bentuk tabel
hasil_analisis = table(string(coef.name), coef.A, coef.g, ...
    'VariableNames', {'Konstituen', 'Amplitudo', 'Fase'});

% Tampilkan hasil analisis
disp(hasil_analisis);

% Simpan hasil analisis dalam format ASCII
save hasil_analisis -ascii

%% 3. Prediksi Pasang Surut Menggunakan Koefisien Konstituen
time_pred = linspace(min(time_num), max(time_num), 1000); % Buat rentang waktu prediksi
elevasi_pred = ut_reconstr(time_pred, coef); % Rekonstruksi sinyal pasut

%% 4. Visualisasi Hasil

% Plot data observasi dan prediksi pasang surut
figure;
plot(time_num, elevasi, 'b', 'DisplayName', 'Data Observasi');
hold on;
plot(time_pred, elevasi_pred, 'r', 'DisplayName', 'Prediksi UTide');
datetick('x', 'dd-mm-yyyy HH:MM', 'keeplimits');
xlabel('Waktu');
ylabel('Elevasi (m)');
title('Analisis & Prediksi Pasang Surut dengan UTide');
legend;
grid on;

% Plot hanya prediksi pasang surut
figure;
plot(time_pred, elevasi_pred, 'r', 'DisplayName', 'Prediksi UTide');
datetick('x', 'dd-mm-yyyy HH:MM', 'keeplimits');
xlabel('Waktu');
ylabel('Elevasi (m)');
title('Prediksi Pasang Surut dengan UTide');
legend;
grid on;

% Konversi waktu ke jam relatif dari waktu pertama
time_hours = (time_num - time_num(1)) * 24;

% Buat figure baru untuk plot
figure;
hold on;
colors = lines(length(coef.name)); % Warna berbeda untuk setiap konstituen

for i = 1:length(coef.name)
    % Ambil parameter konstituen
    A_i = coef.A(i); % Amplitudo
    g_i = deg2rad(coef.g(i)); % Fase dalam radian
    omega_i = coef.aux.frq(i) * 2 * pi; % Frekuensi sudut (radian/jam)
    
    % Hitung sinyal pasut individu
    h_i = A_i * cos(omega_i * time_hours + g_i);
    
    % Plot masing-masing konstituen
    plot(time_num, h_i, 'Color', colors(i,:), 'LineWidth', 1.5, 'DisplayName', coef.name{i});
end

datetick('x', 'dd-mm-yyyy HH:MM', 'keeplimits');
xlabel('Waktu');
ylabel('Elevasi (cm)');
title('Konstituen Pasang Surut');
legend;
grid on;
hold off;

%% 3. Pilih Satu Konstituen yang Akan Ditampilkan
konstituen_pilih = 'M2'; % Ganti dengan konstituen lain jika perlu

% Cari indeks konstituen yang dipilih
idx = find(strcmp(coef.name, konstituen_pilih));

% Jika konstituen tidak ditemukan, tampilkan error
if isempty(idx)
    error('Konstituen %s tidak ditemukan dalam hasil analisis.', konstituen_pilih);
end

% Ambil parameter konstituen
A_i = coef.A(idx); % Amplitudo
g_i = deg2rad(coef.g(idx)); % Fase dalam radian
omega_i = coef.aux.frq(idx) * 2 * pi; % Frekuensi sudut (radian/jam)

% Hitung sinyal pasut untuk konstituen yang dipilih
h_i = A_i * cos(omega_i * time_hours + g_i);

%% 4. Plot Grafik Konstituen yang Dipilih
figure;
plot(time_num, h_i, 'b', 'LineWidth', 2);
datetick('x', 'dd-mm-yyyy HH:MM', 'keeplimits');

xlabel('Waktu');
ylabel('Elevasi (cm)');
title(['Gelombang Pasut Konstituen ', konstituen_pilih]);
grid on;

%% 5. Simpan Hasil Prediksi ke File
output_filename = 'prediksi_pasut_3_hari.txt';
prediksi_data = [time_pred(:), elevasi_pred(:)];

dlmwrite(output_filename, prediksi_data, 'delimiter', '\t', 'precision', 6);

disp(['Prediksi pasang surut telah disimpan dalam file: ', output_filename]);

%% 3. Input Rentang Waktu untuk Prediksi
% Masukkan waktu awal dan akhir prediksi
t_awal = datenum([2019 02 12 00 00 00]); % (YYYY MM DD HH MM SS)
t_akhir = datenum([2019 02 14 23 59 59]); % (YYYY MM DD HH MM SS)

% Buat vektor waktu dengan interval per jam
t_future = linspace(t_awal, t_akhir, (t_akhir - t_awal) * 24);

%% 4. Prediksi Pasut Menggunakan UTide
elevasi_pred = ut_reconstr(t_future, coef);

%% 5. Plot Hasil Prediksi
figure;
% plot(time_num, elevasi, 'k', 'DisplayName', 'Data Asli'); % Opsional jika ingin menampilkan data asli
hold on;
plot(t_future, elevasi_pred, 'r', 'LineWidth', 2, 'DisplayName', 'Prediksi Pasut');
datetick('x', 'dd-mm-yyyy HH:MM', 'keeplimits');

xlabel('Waktu');
ylabel('Elevasi (cm)');
title('Prediksi Pasang Surut');
legend;
grid on;
hold off;

%% 6. Simpan Hasil Prediksi ke File
hasil_prediksi = [datestr(t_future, 'yyyy-mm-dd HH:MM:SS'), num2str(elevasi_pred)];
writematrix(hasil_prediksi, 'prediksi_pasut.txt', 'Delimiter', 'tab');