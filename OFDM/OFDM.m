clear; clc
SNR=8;% 噪比
fl=32; % 设置FFT长度
Ns=2; %设置一个祯结构中OFDM信号的个数
para=32;%设置并行传输的子载波个数
sr=250000; %符号速率
br=sr.*2;% 每个子载波的比特率
gl=8 %保护时隙的长度 
nloop=1 ;%仿真循环次数
noe=0; %误码数
nod=0; %传输的数据数量
eop=0; %误组数
nop=0; %传输的分组数
for iii=1:nloop
%-------------产生数据------------
Signal=rand(1,para.*Ns.*2)>0.5
%产生0，1 随即序列，符号数为para*Ns*2，Signal实际得到的是右边逻辑表达式的结果，
%rand产生的值如果大于0.5，则Signal为1，如果小于0.5，则Signal为0%
%------------串并转换---------
paradata=reshape(Signal,para,Ns.*2)
%变换方式：前32bit变为第一列，随后的32bit变为第二列，以此类推
%------------QPSK调制--------
[ich,qch]=qpskmod(paradata,para,Ns,2) 
kmod=1./sqrt(2);
ich1=ich.*kmod; 
qch1=qch.*kmod; 
qpsk_x=ich1+qch1.*sqrt(-1)
%频域数据变时域
%---------------IFFT------------
fy=ifft(qpsk_x) 
ich2=real(fy) 
qch2=imag(fy)
%--------------插入保护间隔------------
ich3=[ich2(fl-gl+1:fl,:);ich2] 
qch3=[qch2(fl-gl+1:fl,:);qch2]
%--------------计算衰减--------------
spow=sum(ich3.^2+qch3.^2)/Ns./para; 
attn= 0.5.*spow.*sr/br.*10.^(-SNR./10);
attn=sqrt(attn);
%并串变换
ich4=reshape(ich3,1,(fl+gl) .*Ns)
qch4=reshape(qch3,1,(fl+gl) .*Ns)
%形成复数发射数据
TrData=ich4+qch4.*sqrt(-1)
%接收机
%----------加入高斯白噪声-----------
ReData=awgn(TrData,SNR,'measured')
%接收端
%移去保护间隔
idata=real(ReData); 
qdata=imag(ReData); 
idata1=reshape(idata,fl+gl,Ns);
qdata1=reshape(qdata,fl+gl,Ns);
idata2=idata1(gl+1:gl+fl,:);
qdata2=qdata1(gl+1:gl+fl,:);
%FFT
Rex=idata2+qdata2.*sqrt(-1);
ry=fft(Rex);
ReIChan=real(ry); 
ReQChan=imag(ry);
ReIchan=ReIChan/kmod;
ReQchan=ReQChan/kmod;
%QPSK解调
RePara=qpskdemod(ReIchan,ReQchan,para,Ns,2)
%接收端信号 
ReSig=reshape(RePara,1,para.*Ns.* 2);
%-----------误码比特率（BER）------
% ------即时的误码和数据---------
noe2=sum(abs(ReSig-Signal)); %将接收解调后的信号与原始信号相比较，累计不一样的 
nod2=length(Signal);%发送信号的总长度
%累计误码组数和总的数据
noe=noe+noe2;
%因为进行了nloop次的循环，所以把每次循环的数据和误码组数累累积起来
nod=nod+nod2;
%计算误组率（PER）（每次循环作为一个分组） 
if noe2 ~=0
eop=eop+1; 
else
eop=eop;
end
eop; 
nop=nop+1;
fprintf('%d\t%e\t%d\n',iii,noe2/nod2,eop);%屏幕显示
end
%----------输出结果------------
per=eop/nop;%总的误组数 
ber=noe/nod; %总的误码率
figure(1)%发送信号与接收信号的图形
subplot(2,1,1),stem(Signal),grid minor;
title('发送信号'); 
xlabel('x'),ylabel('y');
subplot(2,1,2),stem(ReSig),grid minor;
title('接收信号')
figure(2) 
subplot(2,1,1),stem(ich2),grid minor;
xlabel('x'),ylabel('y');
title('ifft变换之后的I路波形')
subplot(2,1,2),stem(qch2),grid minor;
xlabel('x'),ylabel('y');
title('ifft变换之后的Q路波形')%加入噪声后的I、Q路的幅度波形
figure(3) 
subplot(2,1,1),stem(idata),grid minor;
xlabel('时间'),ylabel('幅度');
title('加噪声后I路波形')
subplot(2,1,2),stem(qdata),grid minor; 
xlabel('时间'),ylabel('幅度'); 
title('加噪声后Q路波形')
figure(4)
subplot(2,1,1),stem(ReIChan),grid minor ;
title('fft变换之后的I路波形')
subplot(2,1,2),stem(ReQChan),grid minor;
title('fft变换之后的Q路波形') 
xlabel('x'),ylabel('y');
figure(5) 
subplot(2,1,1),stem(TrData);
title('未加入噪声时候的波形')
subplot(2,1,2),stem(ReData); 
title('加入噪声后的波形') 
xlabel('x'),ylabel('y');
%QPSK星座图
figure(6)
for alfa=0:0.001.*pi:2.*pi
plot(cos(alfa),sin(alfa),'g')
hold on
end
for i=1:Ns.*para
plot(ich1(i),qch1(i),'ro'); 
hold on
end
grid;
xlabel('I路');
ylabel('Q路');
title('调制后信号的星座图');
hold off
figure(7)
plot(abs(fy));
title('ifft运算结果的波形'); %IFFT运算结果的波形
figure(8) 
plot(abs(ry));
title('fft运算结果的波形'); %FFT运算结果的波形
figure(9)
plot(ich4, qch4,'r.'); 
titile('ofdm星座图');
