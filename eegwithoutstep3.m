clc;
clear;
close all;


% Define image filename
filename = ('/Users/anaghasarswathy/Downloads/1003814407.png');  
% Check if the file exists before reading
if exist(filename, 'file') ~= 2
    error('Error: The specified file "%s" does not exist or cannot be found.', filename);
end

% Read the EEG image
try
    img = imread(filename);  
catch ME
    error('Error reading the image file: %s', ME.message);
end

% Convert to grayscale if needed
if size(img, 3) == 3  % Check if it's an RGB image
    img_gray = rgb2gray(img);
else
    img_gray = img;  % Already grayscale
end

% Extract data from the image (convert it into a time-domain signal)
eeg_signal_from_image = mean(img_gray, 2);  % Averaging intensity across rows

% Define sampling parameters
fs = 256;  % Sampling frequency (adjust as needed)
t = (0:length(eeg_signal_from_image)-1) / fs;  % Time vector in seconds

% Plot extracted signal
figure;
subplot(2,2,1)
plot(t, eeg_signal_from_image);
xlabel('Time (s)');
ylabel('Amplitude');
title('Extracted EEG Signal from Image');
grid on;

%% Step 2: Perform DFT (Frequency Analysis)
N = length(eeg_signal_from_image);
f = (0:N-1) * (fs / N); % Frequency axis
eeg_fft = fft(eeg_signal_from_image);

% Plot original EEG spectrum

subplot(2,2,2)
plot(f(1:N/2), abs(eeg_fft(1:N/2))); % Only show positive frequencies
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('EEG Signal Spectrum (Before Filtering)');
grid on;

%% Step 4: Extract Alpha Waves (8-13 Hz) Using Bandpass Filter
alpha_filter = designfilt('bandpassiir', 'FilterOrder', 4, ...
                          'HalfPowerFrequency1', 8, 'HalfPowerFrequency2', 13, ...
                          'SampleRate', fs);
alpha_wave = filtfilt(alpha_filter, eeg_signal_from_image); % Extract Alpha waves

% Plot Alpha wave

subplot(2,2,3)
plot(t, alpha_wave);
xlabel('Time (s)');
ylabel('Amplitude');
title('Extracted Alpha Waves (8-13 Hz)');
grid on;

%% Step 5: Compute EEG Features
mean_value = mean(alpha_wave);       % Mean of the Alpha wave
std_dev = std(alpha_wave);           % Standard deviation
peak_amplitude = max(abs(alpha_wave)); % Maximum absolute peak
rms_value = rms(alpha_wave);         % Root Mean Square (RMS) value
energy = sum(alpha_wave.^2);         % Signal energy
skewness_value = skewness(alpha_wave); % Skewness (asymmetry)
kurtosis_value = kurtosis(alpha_wave); % Kurtosis (peakedness)

% Compute Power Spectral Density (PSD)
[pxx, f] = pwelch(alpha_wave, [], [], [], fs);

% Compute total power in Alpha band (8-13 Hz)
alpha_band_power = bandpower(alpha_wave, fs, [8 13]);

%% Step 6: Classify Stressed vs. Relaxed State
alpha_threshold = 1.5; % Example threshold for classification

if alpha_band_power > alpha_threshold
    state = 'Relaxed';
else
    state = 'Stressed';
end

%% Step 7: Display Extracted Features and Classification Result
fprintf('\nEEG Alpha Wave Features:\n');
fprintf('Mean: %.4f\n', mean_value);
fprintf('Standard Deviation: %.4f\n', std_dev);
fprintf('Peak Amplitude: %.4f\n', peak_amplitude);
fprintf('RMS Value: %.4f\n', rms_value);
fprintf('Signal Energy: %.4f\n', energy);
fprintf('Skewness: %.4f\n', skewness_value);
fprintf('Kurtosis: %.4f\n', kurtosis_value);
fprintf('Alpha Band Power: %.4f\n', alpha_band_power);
fprintf('Mental State: %s\n\n', state);

% Plot Power Spectrum of Alpha Waves

subplot(2,2,4)
plot(f, 10*log10(pxx));
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
title('Power Spectrum of Alpha Waves');
grid on;