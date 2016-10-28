
fil='tangmirr5'
path='~/newwrl/'
restore,file=path+fil+'show.sav',/verb

ang=(112.46-90)*!dtor
len=20.
del=[cos(ang),sin(ang),0]*len
for j=0,2 do lns(0,*,*)+=del(j)
for j=0,2 do fcb(0,*,*)+=del(j)

save,lns,file=path+fil+'6'+'show.sav',/verb
save,lns,file='~/idl/clive/nleonw/tang_port/objhidden_mirr_'+'6'+'.sav',/verb

end
