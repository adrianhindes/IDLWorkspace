pro srw,it

u=dindgen(it)
for i=0L,it-1 do begin
  u[i]=rw()
endfor
print,'mean: '+pg_num2str(mean(u))
;print,'meanabsdev: '+pg_num2str(meanabsdev(u))
print,'stddev: '+pg_num2str(STDDEV(u))
end