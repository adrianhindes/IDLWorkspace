pro rawchannel,shot,diag,module,nchan,amount,sigbuf,time,parameter,$
	start=start,help=help,print=print,plot=plot,oplot=oplot

if keyword_set(help) then begin
	print,'rawchannel,shot,diag,module,',$
		'nchan,amount,sigbuf,time,parameter,start=start'
	return
endif
if not keyword_set(start) then start=1
nchan=long(nchan)
dform='VOLT'
amount=long(amount)
rcount=0L
sigbuf=fltarr(amount)
time=fltarr(amount)
pbuf=lonarr(1)
p2buf='                  '
shotfl= 'en'+string(format='(i6.6)',shot)+'.W7AS'

status = ud_open(unit,shotfl)    
if keyword_set(print) then print,status

if strpos(status,'File is open for read') eq -1 then begin
	print,status
	return
endif
status = ud_select(unit,diag,module)           	 ;& print,status
if keyword_set(print) then print,status
if strpos(status,'Diagnostic and module selected') eq -1 then begin
	print,status
	status = ud_close(unit)  
	return
endif
status = ud_getchn(unit,sigbuf,start,amount,rcount,dform,nchan)
if keyword_set(print) then print,status

status = ud_gettim(unit,time,start,amount,rcount)
if keyword_set(print) then print,status

status = ud_getpar(unit,'MOD ','Timebase',pbuf)  	 ;get sampling rate
if keyword_set(print) then print,status
parameter=fix(pbuf(0))

status = ud_close(unit) 				 ; close shot file
if keyword_set(print) then print,status

if keyword_set(plot) then plot,time,sigbuf,title=string(shot)+string(nchan)
if keyword_set(oplot) then oplot,time,sigbuf

end



