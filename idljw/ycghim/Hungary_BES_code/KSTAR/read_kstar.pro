pro read_kstar,shot,signal,errormess=errormess

errormess = ''

mdsconnect,'172.17.250.100:8005',status=stat
if ((stat mod 2) eq 0) then begin
  errormess = 'Error opening shot.'
  if (not keyword_set(silent)) then print,error
endif
mdsopen,'kstar',shot,status=stat
erase
!p.multi=[0,3,3]
ip = mdsvalue('_y=\PCRC03/(-1000000.)',status=stat)
t = mdsvalue('dim_of(_y)',status=stat)
plot,t,ip

p_nbi = mdsvalue('_y=(((\nb11_vg1))/1.5+4)*(DATA(\nb11_ig1))*0.58/1000',status=stat)
t = mdsvalue('dim_of(_y)',status=stat)
plot,t,p_nbi

p_ecrh = mdsvalue('_y=(\ECH_VFWD1:FOO-0.23)*105/1000.',status=stat)
t = mdsvalue('dim_of(_y)',status=stat)
plot,t,p_ecrh

mdsclose,'kstar',shot,status=stat
mdsdisconnect

plot,t,ip

end
