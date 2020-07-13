%%
%����ԭ����
[y,fs]=audioread('music_5s.wav'); 
sound(y,fs);
n=length(y);
Y=fft(y,n);
figure;
subplot(2,1,1);
plot(y);
title('ԭʼ�����ź�','fontweight','bold');
grid;
subplot(2,1,2);
plot(abs(Y));
title('ԭʼ�ź�Ƶ��','fontweight','bold');
grid;
%%
%���������źš������ź�
[y,fs]=audioread('music_5s.wav'); 
n=length(y);
noise=0.01*randn(n,1);                 %����������
y=y(:,1);
s=y+noise;
audiowrite('RLSrefns.wav',noise,fs);   %���������ź��ļ�
audiowrite('RLSprimsp.wav',s,fs);      %���ɼ����ź��ļ�
sound(s,fs);

S=fft(s,n);
N=fft(noise,n);
%��ͼ
figure;
subplot(3,1,1);
plot(s);
title('���벨���ź�','fontweight','bold');
grid;
subplot(3,1,2);
plot(abs(S));
title('�����ź�Ƶ��','fontweight','bold');
subplot(3,1,3);
plot(abs(N));
title('�����ź�Ƶ��','fontweight','bold');
grid;
