@gethelrnew

;goto,ee



path=getenv('HOME')+'/idl/clive/settings/'&file='run8fill.csv'

readtextc,path+file,data0,nskip=0
shot=float(data0[0,1:*])
good=data0[1,1:*]
type=data0[2,1:*]

powerlev=float(data0[3,1:*])
phase=data0[4,1:*]
fill_lev=float(data0[5,1:*])
grating=float(data0[6,1:*])
lambda=float(data0[7,1:*])
emgain=float(data0[8,1:*])
pr_pos=float(data0[9,1:*])
pr_vplgain=float(data0[10,1:*])

;mkfig,'~/lr.eps',xsize=28,ysize=20,font_size=10
pos=posarr(3,1,0,cny=0.1)
mkfig,'~/te_powerscan.eps',xsize=27,ysize=11,font_size=11
erase

jjtab=[$
[1.41  ,   1],$
[2     ,   1],$
[2.82  ,   1]]
;[2     ,   2],$
;[2     ,  0.5],$
;[2.54  ,  0.5],$
;[2     ,  0.5],$
;[2.54  ,  0.5]]
jjphase=[replicate('normal',3)]
n=n_elements(jjphase)
for jj=0,n-1 do begin
  
   
;typ=1

      idx=where(good eq 'y' and type eq 'p' and abs(powerlev-jjtab(0,jj)) lt 0.01 and fill_lev eq jjtab(1,jj) and phase eq jjphase(jj))

      title=string(jjtab(0,jj)^2 / 4 * 50.,format=$
                   '("Power=",G0,"kW")')
   
   pr_pos1=pr_pos(idx)
   shot1=shot(idx)
   
   nsh=n_elements(shot1)
   twm=[0.03,0.04];-0.01              ;-0.02
   tesw=fltarr(nsh)
   tebp=fltarr(nsh)
   
   r=(1112+pr_pos1)/10.
   for i=0,nsh-1 do begin
      aa=99
      probe_charnew,shot1(i),tavg=twm,varthres=1e9,filterbw=1e3,qty='tesw',qavg=dum,qst=dum2,doplot=jj eq aa  & tesw(i)=dum & if jj eq aa then stop
      probe_charnew,shot1(i),tavg=twm,varthres=1e9,filterbw=1e3,qty='tebp',qavg=dum,qst=dum2  & tebp(i)=dum
   endfor
   
   plot,r,tesw,psym=4,yr=minmax([-10,40]),pos=pos,/noer,title=title,xr=[122,136],xsty=1,ysty=1,yticklen=1,ygridsty=1,xtitle='R (cm)',ytitle=textoidl('T_e (eV)'),symsize=3
   pos=posarr(/next)
   oplot,r,tebp,psym=5,col=2,symsize=3
   legend,['swept probe','ball pen probe'],psym=[4,5],/right,col=[1,2],textcol=[1,2]



; now for he line ratio effect
   idx=where(good eq 'y' and lambda eq 717 and abs(powerlev-jjtab(0,jj)) lt 0.01 and fill_lev eq jjtab(1,jj) and phase eq jjphase(jj))
   
   shot1=shot(idx)
   pr_pos1=pr_pos(idx)
   r=(1112+pr_pos1)/10.
   nsh=n_elements(shot1)
   telr=fltarr(nsh)
   for i=0,nsh-1 do begin
      gethelrnew, shot1(i),dum,doplot=0 & telr(i)=dum

   endfor
;   oplot,r,telr,psym=6,col=4

;   stop


;wait,2
endfor
endfig,/gs,/jp
end
