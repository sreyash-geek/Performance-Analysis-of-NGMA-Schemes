clc; 
clear;
close all;

% Simulation Parameters
N = 1e6; % Number of symbols
SNR_dB = 0:2:30; % SNR range in dB
SNR = 10.^(SNR_dB/10); % Convert to linear scale

% Power Allocation Coefficients (User 1 gets highest power)
P1 = 0.5; % User 1 (Farthest, weakest channel, highest power)
P2 = 0.25; % User 2
P3 = 0.15; % User 3
P4 = 0.10; % User 4 (Nearest, strongest channel, lowest power)

% Generate Random BPSK Symbols for Both Users
bits1 = randi([0 1], 1, N); % User 1's bits
bits2 = randi([0 1], 1, N); % User 2's bits
bits3 = randi([0 1], 1, N); % User 3's bits
bits4 = randi([0 1], 1, N); % User 4's bits

x1 = 2*bits1 - 1; % BPSK Mapping (0 to -1,1 to +1)
x2 = 2*bits2 - 1;
x3 = 2*bits3 - 1;
x4 = 2*bits4 - 1;

% Superimposed NOMA Signal (Power-Domain Multiplexing)
s = sqrt(P1)*x1 + sqrt(P2)*x2 + sqrt(P3)*x3 + sqrt(P4)*x4;

% Initialize BER arrays
BER1 = zeros(1, length(SNR_dB));
BER2 = zeros(1, length(SNR_dB));
BER3 = zeros(1, length(SNR_dB));
BER4 = zeros(1, length(SNR_dB));

% Loop Over SNR Values
for k = 1:length(SNR_dB)
    % Add AWGN Noise
    noise = (1/sqrt(2)) * (randn(1, N) + 1j*randn(1, N));
    y = s + (10^(-SNR_dB(k)/20)) * noise; % Received Signal

    % User 4 Decoding (Strongest channel, lowest power)
    y4_hat = y / sqrt(P4);
    decoded_x4 = real(y4_hat) > 0;
    s_cancelled_4 = y - sqrt(P4) * (2*decoded_x4 - 1);
    
    % User 3 Decoding
    y3_hat = s_cancelled_4 / sqrt(P3);
    decoded_x3 = real(y3_hat) > 0;
    s_cancelled_3 = s_cancelled_4 - sqrt(P3) * (2*decoded_x3 - 1);
    
    % User 2 Decoding
    y2_hat = s_cancelled_3 / sqrt(P2);
    decoded_x2 = real(y2_hat) > 0;
    s_cancelled_2 = s_cancelled_3 - sqrt(P2) * (2*decoded_x2 - 1);
    
    % User 1 Decoding (Weakest channel, highest power)
    y1_hat = s_cancelled_2 / sqrt(P1);
    decoded_x1 = real(y1_hat) > 0;

    % Compute BER
    BER1(k) = sum(decoded_x1 ~= bits1) / N;
    BER2(k) = sum(decoded_x2 ~= bits2) / N;
    BER3(k) = sum(decoded_x3 ~= bits3) / N;
    BER4(k) = sum(decoded_x4 ~= bits4) / N;
end

% Plot BER vs. SNR
figure;
semilogy(SNR_dB, BER1, 'ro-', 'LineWidth', 2); hold on;
semilogy(SNR_dB, BER2, 'bs-', 'LineWidth', 2);
semilogy(SNR_dB, BER3, 'k*-', 'LineWidth', 2); 
semilogy(SNR_dB, BER4, 'md-', 'LineWidth', 2);
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('BER Performance of PD-NOMA with SIC');
legend('User 1 (Weakest Channel, Highest Power)', 'User 2 (Medium Channel 1, Medium Power 1)', 'User 3 (Medium Channel 2, Medium Power 2)', 'User 4 (Strongest Channel, Lowest Power)');