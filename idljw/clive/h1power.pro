function cof,x
y=x-mean(x)
y2=hilbert(y)
z=complex(y,y2)
return,z
end

pro h1power,sh,fr=fr,oplot=oplot,col=col

fil='/home/cam112/prl45/RF_'+string(sh,format='(I0)')+'.h5'

s=h5_parse(fil,/read_data)
a1=s.waveforms.channel_1_data._data
a2=s.waveforms.channel_2_data._data
a3=s.waveforms.channel_3_data._data
a4=s.waveforms.channel_4_data._data
a2 = a2 / 0.97
b1=cof(a1)
b2=cof(a2)
b3=cof(a3)
b4=cof(a4)
nsm=500
c1=smooth(abs(b1)^2,nsm)
c2=smooth(abs(b2)^2,nsm)
c3=smooth(abs(b3)^2,nsm)
c4=smooth(abs(b4)^2,nsm)

d1=c1+c3
d2=c2+c4

e=d1-d2
if keyword_set(fr) then begin
if not keyword_set(oplot) then plot,d1 else oplot,d1
oplot,d2,col=2
endif else begin
if not keyword_set(oplot) then plot,e,title=string(sh,format='(I0)') else oplot,e,col=col
endelse

;s=fft(a1)

;; d1c  = d1_mag*exp(i*(d1_pha*pi/180))
;;                              |
;;  =  0.0356 + 0.0008i

;; d2c = d2_mag*exp(i*(d2_pha*pi/180));

;; =    0.9655 + 0.1402i




;; CH2 = CH2 + CH1.*d1c;
;; CH2 = CH2.*d2c;


;; plot,c1,pos=posarr(2,1,0)
;; oplot,c2,col=2

;; plot,c3,pos=posarr(/next),/noer
;; oplot,c4,col=2

















stop

end


;h1power,82685;714

;end
