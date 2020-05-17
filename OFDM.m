clear; clc
SNR=8;% ���
fl=32; % ����FFT����
Ns=2; %����һ�����ṹ��OFDM�źŵĸ���
para=32;%���ò��д�������ز�����
sr=250000; %��������
br=sr.*2;% ÿ�����ز��ı�����
gl=8 %����ʱ϶�ĳ��� 
nloop=1 ;%����ѭ������
noe=0; %������
nod=0; %�������������
eop=0; %������
nop=0; %����ķ�����
for iii=1:nloop
%-------------��������------------
Signal=rand(1,para.*Ns.*2)>0.5
%����0��1 �漴���У�������Ϊpara*Ns*2��Signalʵ�ʵõ������ұ��߼����ʽ�Ľ����
%rand������ֵ�������0.5����SignalΪ1�����С��0.5����SignalΪ0%
%------------����ת��---------
paradata=reshape(Signal,para,Ns.*2)
%�任��ʽ��ǰ32bit��Ϊ��һ�У�����32bit��Ϊ�ڶ��У��Դ�����
%------------QPSK����--------
[ich,qch]=qpskmod(paradata,para,Ns,2) 
kmod=1./sqrt(2);
ich1=ich.*kmod; 
qch1=qch.*kmod; 
qpsk_x=ich1+qch1.*sqrt(-1)
%Ƶ�����ݱ�ʱ��
%---------------IFFT------------
fy=ifft(qpsk_x) 
ich2=real(fy) 
qch2=imag(fy)
%--------------���뱣�����------------
ich3=[ich2(fl-gl+1:fl,:);ich2] 
qch3=[qch2(fl-gl+1:fl,:);qch2]
%--------------����˥��--------------
spow=sum(ich3.^2+qch3.^2)/Ns./para; 
attn= 0.5.*spow.*sr/br.*10.^(-SNR./10);
attn=sqrt(attn);
%�����任
ich4=reshape(ich3,1,(fl+gl) .*Ns)
qch4=reshape(qch3,1,(fl+gl) .*Ns)
%�γɸ�����������
TrData=ich4+qch4.*sqrt(-1)
%���ջ�
%----------�����˹������-----------
ReData=awgn(TrData,SNR,'measured')
%���ն�
%��ȥ�������
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
%QPSK���
RePara=qpskdemod(ReIchan,ReQchan,para,Ns,2)
%���ն��ź� 
ReSig=reshape(RePara,1,para.*Ns.* 2);
%-----------��������ʣ�BER��------
% ------��ʱ�����������---------
noe2=sum(abs(ReSig-Signal)); %�����ս������ź���ԭʼ�ź���Ƚϣ��ۼƲ�һ���� 
nod2=length(Signal);%�����źŵ��ܳ���
%�ۼ������������ܵ�����
noe=noe+noe2;
%��Ϊ������nloop�ε�ѭ�������԰�ÿ��ѭ�������ݺ������������ۻ�����
nod=nod+nod2;
%���������ʣ�PER����ÿ��ѭ����Ϊһ�����飩 
if noe2 ~=0
eop=eop+1; 
else
eop=eop;
end
eop; 
nop=nop+1;
fprintf('%d\t%e\t%d\n',iii,noe2/nod2,eop);%��Ļ��ʾ
end
%----------������------------
per=eop/nop;%�ܵ������� 
ber=noe/nod; %�ܵ�������
figure(1)%�����ź�������źŵ�ͼ��
subplot(2,1,1),stem(Signal),grid minor;
title('�����ź�'); 
xlabel('x'),ylabel('y');
subplot(2,1,2),stem(ReSig),grid minor;
title('�����ź�')
figure(2) 
subplot(2,1,1),stem(ich2),grid minor;
xlabel('x'),ylabel('y');
title('ifft�任֮���I·����')
subplot(2,1,2),stem(qch2),grid minor;
xlabel('x'),ylabel('y');
title('ifft�任֮���Q·����')%�����������I��Q·�ķ��Ȳ���
figure(3) 
subplot(2,1,1),stem(idata),grid minor;
xlabel('ʱ��'),ylabel('����');
title('��������I·����')
subplot(2,1,2),stem(qdata),grid minor; 
xlabel('ʱ��'),ylabel('����'); 
title('��������Q·����')
figure(4)
subplot(2,1,1),stem(ReIChan),grid minor ;
title('fft�任֮���I·����')
subplot(2,1,2),stem(ReQChan),grid minor;
title('fft�任֮���Q·����') 
xlabel('x'),ylabel('y');
figure(5) 
subplot(2,1,1),stem(TrData);
title('δ��������ʱ��Ĳ���')
subplot(2,1,2),stem(ReData); 
title('����������Ĳ���') 
xlabel('x'),ylabel('y');
%QPSK����ͼ
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
xlabel('I·');
ylabel('Q·');
title('���ƺ��źŵ�����ͼ');
hold off
figure(7)
plot(abs(fy));
title('ifft�������Ĳ���'); %IFFT�������Ĳ���
figure(8) 
plot(abs(ry));
title('fft�������Ĳ���'); %FFT�������Ĳ���
figure(9)
plot(ich4, qch4,'r.'); 
titile('ofdm����ͼ');
