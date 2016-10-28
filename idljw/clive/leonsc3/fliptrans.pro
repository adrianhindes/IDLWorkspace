pro rotmat,z,rotation1,zflip
rotation=-rotation1*!dtor
z2=z
z2(0,*,*)=z(0,*,*)*cos(rotation) + z(1,*,*)*sin(rotation)
z2(1,*,*)=-z(0,*,*)*sin(rotation) + z(1,*,*)*cos(rotation)
z2(2,*,*)=zflip*z(2,*,*)
z=z2
end
;num 12 and 26 are absent when counting on patch panel upwards


pro fliptrans,infil,outfil,rotation,zflip,pth=pth
default,pth,'~/newwrl/'
restore,file=pth+infil,/verb
stop
rotmat,lns,rotation,zflip
rotmat,fcb,rotation,zflip
;stop
save,lns,fcb,file=pth+outfil,/verb
;stop
end


;fliptrans,'taelimb_sec1_lowershow.sav','taelimb_sec2_lower_cp_show.sav',30.,1.
;fliptrans,'taelimb_sec1_lowershow.sav','taelimb_sec3_lower_cp_show.sav',-60.,1.
;fliptrans,'M09100035_bshow.sav','M09100035_b_p30show.sav',30.,1.
;fliptrans,'M09100035_bshow.sav','M09100035_b_m30show.sav',-30.,1.
;fliptrans,'M09100035_bshow.sav','M09100035_b_m150show.sav',-150.,1.
;fliptrans,'M09100035_bshow.sav','M09100035_b_p150show.sav',150.,1.
;fliptrans,'M09100035_bshow.sav','M09100035_b_p180show.sav',180.,1.
;fliptrans,'M09100035_bshow.sav','M09100035_b_flipshow.sav',0.,-1.
;fliptrans,'M09100215_bshow.sav','M09100215_b_flipshow.sav',0.,-1.

;fliptrans,'M09100035_bshow.sav','M09100035_b_m90show.sav',-90.,1.
;fliptrans,'M09100035_bshow.sav','M09100035_b_m30fshow.sav',-30.,-1.
;fliptrans,'M09100035_bshow.sav','M09100035_b_m90fshow.sav',-90.,-1.
;fliptrans,'M09100035_bshow.sav','M09100035_b_m60fshow.sav',-60.,-1.
;fliptrans,'M09100035_bshow.sav','M09100035_b_m120fshow.sav',-120.,-1.


;fliptrans,'M09100035_bshow.sav','M09100035_b_m60show.sav',-60.,1.
;fliptrans,'M09100035_bshow.sav','M09100035_b_m120show.sav',-120.,1.
;fliptrans,'M09100035_bshow.sav','M09100035_b_m90show.sav',-60.,1.

;fliptrans,'M09100035_bshow.sav','M09100035_b_p120fshow.sav',120.,-1.
;fliptrans,'M09100035_bshow.sav','M09100035_b_p120show.sav',120.,1.

;fliptrans,'M09100035_bshow.sav','M09100035_b_m150show.sav',-150.,1.
;fliptrans,'M09100035_bshow.sav','M09100035_b_m90show.sav',-90.,1.
;fliptrans,'M09100035_bshow.sav','M09100035_b_m30show.sav',-30.,1.
fliptrans,'M09100035_bshow.sav','M09100035_b_p30show.sav',30.,1.
fliptrans,'M09100035_bshow.sav','M09100035_b_p60show.sav',60.,1.
;fliptrans,'M09100035_bshow.sav','M09100035_b_p60fshow.sav',60.,-1.
;fliptrans,'M09100035_bshow.sav','M09100035_b_p180fshow.sav',180.,-1.



end
