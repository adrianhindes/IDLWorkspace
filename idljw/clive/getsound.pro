pro getsound, sh,d,t

fil='/home/cmichael/'+string(sh,format='(I0)')+'.wav'
dum=file_search(fil,count=cnt)
if cnt eq 0 then begin
   d=randomu(sd,100000)
   t=findgen(100000)/44.1e3
return
endif

d=read_wav(fil,rate)
n=n_elements(d)
t=findgen(n) * 1./rate

end
