clc; clear;
close all;

% Simulation Parameters
N = 1e6; % Number of symbols
SNR_dB = 0:2:30; % SNR range in dB
SNR = 10.^(SNR_dB/10); % Convert to linear scale

% Power Allocation Coefficients (User 1 gets higher power)
P1 = 0.8; % Power for User 1 (farther user - weak channel)
P2 = 0.2; % Power for User 2 (closer user - strong channel)

% Generate Random BPSK Symbols for Both Users
bits1 = randi([0 1], 1, N); % User 1's bits
bits2 = randi([0 1], 1, N); % User 2's bits

x1 = 2*bits1 - 1; % BPSK Mapping (0 to -1,1 to +1)
x2 = 2*bits2 - 1;

% Superimposed NOMA Signal (Power-Domain Multiplexing)
s = sqrt(P1)*x1 + sqrt(P2)*x2;

% Initialize BER arrays
BER1 = zeros(1, length(SNR_dB));
BER2 = zeros(1, length(SNR_dB));

% Loop Over SNR Values
for k = 1:length(SNR_dB)
    % Add AWGN Noise
    noise = (1/sqrt(2)) * (randn(1, N) + 1j*randn(1, N));
    y = s + (10^(-SNR_dB(k)/20)) * noise; % Received Signal
    % SIC at User 2 (Decodes User 1's signal first)
    y1_hat = y / sqrt(P1); % Scale by power
    decoded_x1 = real(y1_hat) > 0; % BPSK Demodulation
    % Subtract User 1's decoded signal
    s_cancelled = y - sqrt(P1) * (2*decoded_x1 - 1);
    % User 2 Decoding
    y2_hat = s_cancelled / sqrt(P2);
    decoded_x2 = real(y2_hat) > 0; % BPSK Demodulation
    % Compute BER
    BER1(k) = sum(decoded_x1 ~= bits1) / N;
    BER2(k) = sum(decoded_x2 ~= bits2) / N;
end

% Plot BER vs. SNR
figure;
semilogy(SNR_dB, BER1, 'ro-', 'LineWidth', 2); hold on;
semilogy(SNR_dB, BER2, 'bs-', 'LineWidth', 2);
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('BER Performance of PD-NOMA with SIC');
legend('User 1 (Weak Channel, High Power)', 'User 2 (Strong Channel, Low Power)');