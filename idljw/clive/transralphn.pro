function cart2pol, p
return,[sqrt(p(0)^2+p(1)^2),atan(p(1),p(0)),p(2)]
end
function pol2cart,p
return,[p(0) * cos(p(1)),p(0)*sin(p(1)),p(2)]
end


pro tr, lns,mat,dp
sz=size(lns,/dim)
lns2=lns
for i=0,sz(1)-1 do for j=0,sz(2)-1 do lns2(*,i,j)=mat # reform(lns(*,i,j))+dp

lns=lns2

end
fil='ralphcamn'
;fil='RalphCam_displaced5'
path='~/rsphy/newwrl/'
restore,file=path+fil+'show.sav',/verb

th0=-1.3*!dtor
mat=[[cos(th0),sin(th0),0],$
     [-sin(th0),cos(th0),0],$
     [0,0,1]]
;tt=-7.2*!dtor
;dr=-50
;dp=[cos(tt),sin(tt),0]*dr
dp=[0,0,0]
tr,lns,mat,dp
tr,fcb,mat,dp
save,lns,fcb,file=path+fil+'4'+'show.sav',/verb

end
