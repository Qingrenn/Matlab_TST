%%
%播放原语音
[y,fs]=audioread('music_5s.wav'); 
sound(y,fs);
n=length(y);
Y=fft(y,n);
figure;
subplot(2,1,1);
plot(y);
title('原始波形信号','fontweight','bold');
grid;
subplot(2,1,2);
plot(abs(Y));
title('原始信号频谱','fontweight','bold');
grid;
%%
%生成噪音信号、加噪信号
[y,fs]=audioread('music_5s.wav'); 
n=length(y);
noise=0.01*randn(n,1);                 %产生白噪音
y=y(:,1);
s=y+noise;
audiowrite('RLSrefns.wav',noise,fs);   %生成噪音信号文件
audiowrite('RLSprimsp.wav',s,fs);      %生成加噪信号文件
sound(s,fs);

S=fft(s,n);
N=fft(noise,n);
%画图
figure;
subplot(3,1,1);
plot(s);
title('加噪波形信号','fontweight','bold');
grid;
subplot(3,1,2);
plot(abs(S));
title('加噪信号频谱','fontweight','bold');
subplot(3,1,3);
plot(abs(N));
title('噪音信号频谱','fontweight','bold');
grid;
