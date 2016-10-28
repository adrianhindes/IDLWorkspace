pro stringtest
;d=['an1','an2','an3','an4','an5','an6','an7','an8','an9','an10']
;for i=0,10 do begin
  ;j=string(i)
  ;print, 'channgel'+d(i)
  ;endfor
r=findgen(10)*0.2/10.0
case r of 
 1: print,'0.<r<0.2'
 2: print,'0.2<r<0.4'
 else:print, 'null'
 endcase

 
 
 
 
 
  stop
  end