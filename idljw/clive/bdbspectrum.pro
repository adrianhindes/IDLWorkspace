pro bdbspectrum, sh,dostop=dostop
err=0L
;catch,err
if err ne 0 then return
;read_spe,'~/share/greg/ipad_1000ms_717nm.spe',l,t,d
read_spe,'~/share/greg/shaun_'+string(sh,format='(I0)')+'.spe',l,t,d 


l=reverse(l)

t=-20 + findgen(11) * 10.
d=d*1.
dd=reform(d(*,20/2,*))
dd2=reform(totaldim(d,[0,1,0]))
;stop
contourn2,dd,l,t,/cb,xsty=1,offx=1.,xtitle='wavelength/nm',ytitle='time/ms',title=sh
if keyword_set(dostop) then stop

end


pro loopit
sh=0
aa:
mdstcl,'show current h1data',output=output
sh1=long(((strsplit(output,/extract))(0))[3])
if sh1 eq sh then begin
   wait,5
   goto,aa
endif

sh=sh1

bdbspectrum,sh
goto,aa
end


;bdbspectrum,86826

;end
