clc; clear; close all;

% Define SNR range in dB
SNR_dB = 0:2:20;
SNR_linear = 10.^(SNR_dB/10); % Convert SNR from dB to linear scale

% System Parameters
bandwidth = 10e6; % 10 MHz bandwidth
circuit_power = 1; % Fixed circuit power (in watts)
transmit_power = 0.1 * SNR_linear; % Transmit power increases with SNR

% Spectral Efficiency Model (bps/Hz)
SE_OFDMA = log2(1 + SNR_linear); % OFDMA
SE_PD_NOMA = 0.85 * log2(1 + SNR_linear); % PD-NOMA (affected by interference)
SE_CD_NOMA = 1.2 * log2(1 + SNR_linear); % CD-NOMA (better spectral utilization)

% Throughput Calculation (bps)
Throughput_OFDMA = SE_OFDMA * bandwidth;
Throughput_PD_NOMA = SE_PD_NOMA * bandwidth;
Throughput_CD_NOMA = SE_CD_NOMA * bandwidth;

% Power Consumption Calculation (W)
Power_OFDMA = transmit_power + circuit_power;
Power_PD_NOMA = 1.1 * transmit_power + circuit_power; % PD-NOMA uses extra power due to SIC
Power_CD_NOMA = 1.05 * transmit_power + circuit_power; % CD-NOMA has slight coding overhead

% Energy Efficiency Calculation (bps/Hz/W)
EE_OFDMA = Throughput_OFDMA ./ Power_OFDMA;
EE_PD_NOMA = Throughput_PD_NOMA ./ Power_PD_NOMA;
EE_CD_NOMA = Throughput_CD_NOMA ./ Power_CD_NOMA;

% Plot Energy Efficiency Comparison
figure;
plot(SNR_dB, EE_OFDMA, 'bs-', 'LineWidth', 2, 'MarkerSize', 8); hold on;
plot(SNR_dB, EE_PD_NOMA, 'ro-', 'LineWidth', 2, 'MarkerSize', 8);
plot(SNR_dB, EE_CD_NOMA, 'g^-', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('SNR (dB)');
ylabel('Energy Efficiency (bps/Hz/W)');
title('Energy Efficiency Comparison: OFDMA vs PD-NOMA vs CD-NOMA');
legend('OFDMA', 'PD-NOMA', 'CD-NOMA');
grid on;