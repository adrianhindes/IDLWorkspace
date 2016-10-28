;% Fork probe position
;% determine position (r,z,rho)
;% when the long probe on angle (theta) and distance (D)
;% 
;% WORKS ON MATLAB 2013/2014: ON LAPTOP, NOT SERVER


;%function [r2,z2,rho22,phi22]=fppos_extra6(Dm,theta)
pro fppos2, Dm, theta1, r2, z2,phi2,short=short,new=new,alpha=alpha
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
default,alpha,!pi/2 ; 30*2*!pi/360;


pt=3812./2;      %Tank outer
pf=pt+650.;      %Flange outer
lpt=280.;        %Length of probe
if keyword_set(short) then lpt = lpt - 20.
if keyword_set(new) then lpt=lpt - 10; 270 is new probe length
ppo=pf-lpt;     %Probe outermost position  (with steppingmotor disconnected, otherwise 1439)
lpv=135.;        %lenght of part attached to tank (pivot)
ppv=pt+lpv;     %pivot point 
ls=1237.+610;    %length of probe shaft (1215??)
lp=lpt+ls;      %Total length of probe
ps=25.;          %Probe seperation
if keyword_set(short) then ps = -ps
pyf=75.;         %Vertical position of flange
hp=2.;           %Probe height/dia
fh=100.;         %Diam. of port


;%% Calculate distance and angle

Tr=ppv&             Tz=pyf;     %coordinates of turning/pivot point
          
dout=Dm+650+610-lpv;
din=lp-dout;

r1=Tr-din*cos(theta)&       z1=Tz+din*sin(theta);
r2=r1+(ps/2)*sin(theta)*(alpha*0+1)&    z2=z1+(ps/2)*cos(theta)*sin(alpha);

torp=pt * 7.2*!dtor

torp2=torp + (ps/2) * cos(alpha)

phi2 = torp2 / pt

;stop
end
pro tst
alpha=linspace(0,2*!pi,100)

fppos2, 271, 0., rlong,zlong,plong,alpha=alpha
fppos2, 271, 0., rshort,zshort,pshort,alpha=alpha,/short

plot,zlong
oplot,zshort,col=2

end
