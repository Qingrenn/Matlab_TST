[primary,fs]=audioread('RLSprimsp.wav');%�����ļ�
[fref,fs2]=audioread('RLSrefns.wav');
[source,fs3]=audioread('music_5s.wav');

source = source(:,1);
primary = primary';
fref = fref';

Worder=32;                             %�˲�������
lambda=1;                              %������������
Delta=0.001;                          
p=(1/Delta) * eye(Worder,Worder);      
w=zeros(Worder,1);
output=primary;                        %���������
loopsize=max(size(primary));           %��Ƶ����󳤶�
for i=1+Worder:loopsize                %RLS�㷨
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

%��ͼ
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
title('ԭ��Ƶ�����ź�');

subplot(1,2,2);
plot(abs(S));
title('ԭ��ƵƵ���ź�');

figure(2);
subplot(1,2,1);
plot(y1);
title('����˷粨���ź�');

subplot(1,2,2);
plot(abs(P));
title('����˷��ź�Ƶ��');

figure(3);
subplot(1,2,1);
plot(y2);
title('���������ź�');
%axis([0 10e3 -2 2]);

subplot(1,2,2);
plot(abs(F));
title('�����ź�Ƶ��');

figure(4);
subplot(1,2,1);
plot(y3);
title('�˲������ź�');

subplot(1,2,2);
plot(abs(O));
title('�˲����ź�Ƶ��');

key=1;
while key==1
    flag=input('1-ԭʼ����\n2-����������\n3-��������\n4-���������\n0-�˳�\n');
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