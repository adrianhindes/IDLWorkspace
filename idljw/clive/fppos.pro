;% Fork probe position
;% determine position (r,z,rho)
;% when the long probe on angle (theta) and distance (D)
;% 
;% WORKS ON MATLAB 2013/2014: ON LAPTOP, NOT SERVER


;%function [r2,z2,rho22,phi22]=fppos_extra6(Dm,theta)
pro fppos, Dm, theta1, r2, z2,alpha=alpha
;Dm=281; theta=0;
;r=csvread('r1f.csv').'*1e3;      r0=r(end,1);
;z=csvread('z1f.csv').'*1e3;      z0=z(end,1);
;rho=csvread('rhof.csv');         

;phi=[0:pi/49:pi,-pi:pi/49:0];%phi=0:(2*pi)/99:(2*pi);
;rhop=1;
;%[~,i]=min(abs(rho-rhop));
;i=99;

;rm=mean(r(1,:));    zm=mean(z(1,:));

theta=theta1*2*!pi/360;
default,alpha,30*2*!pi/360;


pt=3812/2;      %Tank outer
pf=pt+650;      %Flange outer
lpt=280;        %Length of probe
ppo=pf-lpt;     %Probe outermost position  (with steppingmotor disconnected, otherwise 1439)
lpv=135;        %lenght of part attached to tank (pivot)
ppv=pt+lpv;     %pivot point 
ls=1237+610;    %length of probe shaft (1215??)
lp=lpt+ls;      %Total length of probe
ps=25;          %Probe seperation
pyf=75;         %Vertical position of flange
hp=2;           %Probe height/dia
fh=100;         %Diam. of port


;%% Calculate distance and angle

Tr=ppv&             Tz=pyf;     %coordinates of turning/pivot point
          
dout=Dm+650+610-lpv;
din=lp-dout;

r1=Tr-din*cos(theta)&       z1=Tz+din*sin(theta);
r2=r1+(ps/2)*sin(theta)&    z2=z1+(ps/2)*cos(theta)-(ps/2)*sin(alpha);


end
