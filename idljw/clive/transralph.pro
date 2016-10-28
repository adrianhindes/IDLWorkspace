pro tr, lns,mat,dp
sz=size(lns,/dim)
lns2=lns
for i=0,sz(1)-1 do for j=0,sz(2)-1 do lns2(*,i,j)=mat # reform(lns(*,i,j))+dp

lns=lns2

end
fil='RalphCam_displaced'
path='~/rsphy/newwrl/'
restore,file=path+fil+'show.sav',/verb

th0=0.7*!dtor
mat=[[cos(th0),sin(th0),0],$
     [-sin(th0),cos(th0),0],$
     [0,0,1]]
dp=[0,0,40.]
tr,lns,mat,dp
tr,fcb,mat,dp
save,lns,fcb,file=path+fil+'2'+'show.sav',/verb

end
