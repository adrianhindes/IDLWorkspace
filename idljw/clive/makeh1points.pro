
lns=fltarr(3,2,1)
ang=352.8*!dtor
zed=-76;mm
radin=1450
radout=radin+50
lns(0,*,0) = cos(ang) * [radin,radout]
lns(1,*,0) = sin(ang) * [radin,radout]
lns(2,*,0) = zed
fn='~/idl/clive/nleonw/gregdown/objhidden_puf.sav'
print,'fn=',fn
save,lns,file=fn,/verb
end


