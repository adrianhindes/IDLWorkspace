pro newcmpmseefit_calc

;,rix2=rix2,ph1=ph1,iy12=iy12,rpr=rpr,iy11=iy11,ang2r=ang2r,$
;  tgam=tgam,ix12=ix12,zpr=zpr,rxs=rxs,rys=rys,sz=sz,ix11=ix11,ngam=ngam,dir1=di;r,idxarr=idxarr,$
;                    g=g,m=m,iy0=iy,ix0=ix,$
;                    ixa1=ix1,iya1=iy1,ixa2=ix2,iya2=iy2,$
;                    intens=intens,fspec=fspec,$
; sh=sh,tw=tw,trueerr=trueerr,dirmod=dirmod,refsh=refsh,refi0=refi0,coff=coff,no;calc=nocalc,res=res

;default,trueerr,-2.


;gettim,sh=sh,tstart=tstart,ft=ft,folder=folder,type=type,wid=wid

spawn,'hostname',host
if host eq 'ikstar.nfri.re.kr' then dir='/home/users/cmichael/my2/EXP00'+string(sh,format='(I0)')+'_k'+dirmod else dir='/home/cam112/idl'

g=readg(dir+'/g'+fspec)
m=readm(dir+'/m'+fspec)
;g=readg('/home/cam112/idl/g007485.002500')
;m=readm('/home/cam112/idl/m007485.002500')

calculate_bfield,bp,br,bt,bz,g
ix=interpol(findgen(n_elements(g.r)),g.r,rp*.01)
iy=interpol(findgen(n_elements(g.z)),g.z,zp*.01)
bt1=interpolate(bt,ix,iy)
br1=interpolate(br,ix,iy)
bz1=interpolate(bz,ix,iy)
;rys(0,*)=0.
ey=rys(0,*) * br1 + rys(1,*) * bt1 + rys(2,*) * bz1
ex=rxs(0,*) * br1 + rxs(1,*) * bt1 + rxs(2,*) * bz1
tang2=ey/ex                     ;atan(ex,ey)*!radeg
tang2r=reform(tang2,sz(0),sz(1))

ang2=atan(ex,ey)*!radeg
ang2r=reform(ang2,sz(0),sz(1))

br1r=reform(br1,sz(0),sz(1))
bz1r=reform(bz1,sz(0),sz(1))
bt1r=reform(bt1,sz(0),sz(1))

end
