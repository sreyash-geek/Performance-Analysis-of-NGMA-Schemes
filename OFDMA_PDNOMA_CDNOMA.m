clc; clear; close all;

% Define SNR range
SNR_dB = 0:2:20;
SNR = 10.^(SNR_dB/10); % Convert dB to linear scale

% System Parameters
BW = 10e6; % Bandwidth (10 MHz)
P_total = 1; % Total transmission power
N_users = 2; % Number of users
% BER Calculation (Assumed QPSK Modulation for all)
BER_OFDMA = 0.5 * erfc(sqrt(SNR));
BER_PD_NOMA = 0.5 * erfc(sqrt(SNR/2)) + 0.5 * erfc(sqrt(SNR/4)); % Considering 2 users
BER_CD_NOMA = 0.5 * erfc(sqrt(SNR/3)); % Assuming code-based power gain

% Spectral Efficiency Calculation (bps/Hz)
SE_OFDMA = log2(1 + SNR);
SE_PD_NOMA = 0.5 * log2(1 + SNR) + 0.5 * log2(1 + SNR/2);
SE_CD_NOMA = log2(1 + SNR) .* (1 + 0.5); % CD-NOMA assumes an extra coding gain
% Energy Efficiency Calculation (bps/Hz/W)
EE_OFDMA = SE_OFDMA ./ P_total;
EE_PD_NOMA = SE_PD_NOMA ./ (P_total * 1.2); % Extra power for SIC
EE_CD_NOMA = SE_CD_NOMA ./ (P_total * 1.1); % Small power overhead for spreading

% Plot BER
figure;
semilogy(SNR_dB, BER_OFDMA, 'bs-', 'LineWidth', 1.5, 'MarkerSize', 7); hold on;
semilogy(SNR_dB, BER_PD_NOMA, 'ro-', 'LineWidth', 1.5, 'MarkerSize', 7);
semilogy(SNR_dB, BER_CD_NOMA, 'g^-', 'LineWidth', 1.5, 'MarkerSize', 7);
xlabel('SNR (dB)'); ylabel('BER');
legend('OFDMA', 'PD-NOMA', 'CD-NOMA');
title('BER Comparison'); grid on;

% Plot Spectral Efficiency
figure;
plot(SNR_dB, SE_OFDMA, 'bs-', 'LineWidth', 1.5, 'MarkerSize', 7); hold on;
plot(SNR_dB, SE_PD_NOMA, 'ro-', 'LineWidth', 1.5, 'MarkerSize', 7);
plot(SNR_dB, SE_CD_NOMA, 'g^-', 'LineWidth', 1.5, 'MarkerSize', 7);
xlabel('SNR (dB)'); ylabel('Spectral Efficiency (bps/Hz)');
legend('OFDMA', 'PD-NOMA', 'CD-NOMA');
title('Spectral Efficiency Comparison'); grid on;

% Plot Energy Efficiency
figure;
plot(SNR_dB, EE_OFDMA, 'bs-', 'LineWidth', 1.5, 'MarkerSize', 7); hold on;
plot(SNR_dB, EE_PD_NOMA, 'ro-', 'LineWidth', 1.5, 'MarkerSize', 7);
plot(SNR_dB, EE_CD_NOMA, 'g^-', 'LineWidth', 1.5, 'MarkerSize', 7);
xlabel('SNR (dB)'); ylabel('Energy Efficiency (bps/Hz/W)');
legend('OFDMA', 'PD-NOMA', 'CD-NOMA');
title('Energy Efficiency Comparison'); grid on;

