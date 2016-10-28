
pro tdms_get_pmt_all,ig=ig,data=data,file=file,path=path,ch=outchannels,time=time
default,ig,0
tdms_get_pmt,/noget,outchannels=outchannels,outgroups=outgroups,file=file,path=path

idx=where(outgroups ne '')
outgroups=outgroups(idx)

idx=where(outchannels ne 'Time' and outchannels ne '')
outchannels=outchannels(idx)

nch=n_elements(outchannels)
ng=n_elements(outgroups)

group=outgroups(ig)
for i=0,nch-1 do begin

tdms_get_pmt,file=file,path=path,group=group,channel=outchannels(i),data=tmp
if i eq 0 then begin
   nn=n_elements(tmp)
   data=fltarr(nn,nch)
endif
data(*,i)=tmp
endfor
tdms_get_pmt,file=file,path=path,group=group,channel='Time',data=time

end


