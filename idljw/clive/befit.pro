@newmakeefitnl
@newcmpmseefit

;@getptsnew
;goto,af

;goto,ee

;newdemod,img,cars,/doload,/doplot,sh=sh,ifr=ifr,demodtype=demodtype
sh=9324; 9243
tarr=1.9
ifr=frameoftime(sh,tarr,db='k')&only2=1&demodtype='sm32013mse'
newdemodflclt,sh, ifr,dopc=dopc1,angt=ang1,eps=eps1,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,cars=cars1,istata=istata1,demodtype=demodtype,/noid2;,/cacheread,/cachewrite
;ang1b=ang1


tarra=[2.1];2.2500 + findgen(31) * 0.025
na=n_elements(tarra)
;goto,ee
for i=0,na-1 do begin
   tarr=tarra(i)
;tarr=2.7
ifr=frameoftime(sh,tarr,db='k')&only1=1&only2=0
newdemodflclt,sh, ifr,dopc=dopc1,angt=ang1b,eps=eps1b,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,only1=only1,cars=cars1b,istata=istata1b,demodtype=demodtype,/noid2;,/cacheread,/cachewrite
;
   

ang1b-=12.8;d + 2
ang1b*=-1
inperr=.1
newmakeefitnl,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr,wt=3.,drcm=6,rrng=[160,220],inperr=inperr;,/doplot

runefit1,sh=sh,tw=tarr,kpp=2,kff=3
!p.title=string(tarr)

newcmpmseefit,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr,inperr=inperr,g=g
!p.title=''
stop
endfor
ee:
qarr=fltarr(na,65)
for i=0,na-1 do begin
   tarr=tarra(i)
   fspec=string(sh,tarr*1000,format='(I6.6,".",I6.6)')
   dir='/home/cam112/ikstar/my2/EXP00'+string(sh,format='(I0)')+'_k'+''
   gfile=dir+'/g'+fspec
   g=readg(gfile)
   qarr(i,*)=g.qpsi
   print,gfile
endfor


end
