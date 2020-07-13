[primary,fs]=audioread('RLSprimsp.wav');%读入文件
[fref,fs2]=audioread('RLSrefns.wav');
[source,fs3]=audioread('music_5s.wav');

source = source(:,1);
primary = primary';
fref = fref';

Worder=32;                             %滤波器阶数
lambda=1;                              %设置遗忘因子
Delta=0.001;                          
p=(1/Delta) * eye(Worder,Worder);      
w=zeros(Worder,1);
output=primary;                        %主语音输出
loopsize=max(size(primary));           %音频的最大长度
for i=1+Worder:loopsize                %RLS算法
    z=primary(i)-w'*(fref(i-Worder+1:i))';
    n2=fref(i-Worder+1:i)';
    k=(1/lambda)*p*n2;
    K=k/(1+n2'*k);
    w=w+K*z;
    p0=K*n2';
    p=(p-p0*p)/lambda;
    output(i-Worder)=z;
    disp(i);
end
audiowrite('output.wav',output',fs);
sound(output,fs);

%作图
[y1,Fs1]=audioread('RLSprimsp.wav');
[y2,Fs2]=audioread('RLSrefns.wav');
[y3,Fs3]=audioread('output.wav');

P=fft(y1,4096);
F=fft(y2,4096);
O=fft(y3,4096);
S=fft(source,4096);

figure(1);
subplot(1,2,1);
plot(source);
title('原音频波形信号');

subplot(1,2,2);
plot(abs(S));
title('原音频频谱信号');

figure(2);
subplot(1,2,1);
plot(y1);
title('主麦克风波形信号');

subplot(1,2,2);
plot(abs(P));
title('主麦克风信号频谱');

figure(3);
subplot(1,2,1);
plot(y2);
title('噪声波形信号');
%axis([0 10e3 -2 2]);

subplot(1,2,2);
plot(abs(F));
title('噪声信号频谱');

figure(4);
subplot(1,2,1);
plot(y3);
title('滤波后波形信号');

subplot(1,2,2);
plot(abs(O));
title('滤波后信号频谱');

key=1;
while key==1
    flag=input('1-原始语音\n2-加噪主语音\n3-噪声语音\n4-降噪后语音\n0-退出\n');
    switch flag
        case 0
            key = 0;
        case 1
            sound(source,fs3);
        case 2
            sound(primary,fs);
        case 3
            sound(fref,fs2);
        case 4
            sound(output,fs);
    end
end