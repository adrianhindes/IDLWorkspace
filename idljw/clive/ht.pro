;spectrometer or coherence imaging--etendue argument.


;disp=2.342*1e-9/1e-3 ; nm/mm for 1200l/mm

disp=0.922*1e-9/1e-3 ; for 2400l/mm

psiz  = 12.8e-6 * 1.5

;print, psiz * disp/1e-9

swidth = 10e-6

;etendue = swidth * sheight (of plasma say) * angle

 ifuncwidth = swidth * disp

;for hydrogen, vth

l0=486e-9
nlam=101
fr=0.01
lam=linspace(-fr,fr,nlam)*l0 + l0
temp = 30./2
echarge=1.6e-19
mi=1.67e-27
c=3e8

spec=exp(-mi * c^2 / 2 / echarge/temp * ((lam-l0)/l0)^2)

oewid=sqrt(1/ (mi * c^2 / 2 / echarge/temp )) * l0
plot,lam,spec
print,'1/e width for char temp is ',oewid/1e-9,'nm'
print,'ifunc width is',ifuncwidth/1e-9,'nm'
print,'pix nm is',psiz * disp/1e-9,'nm'
print,'gaussian full width 1/e to 1/e would be ',oewid*2 / (psiz * disp),'pixels'

print,'gaussian full width 1/e to 1/e divided by ifunc wdith would be ',oewid*2 / ifuncwidth  

print,'slit width divided by pixel width is',swidth/psiz
end


