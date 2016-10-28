pro loadctb,pal
if pal eq -2 then begin

    tek_color
;    tvlct,hue1,li1,sat1,/get,/hls
    tvlct,v1,v2,v3,/get
    color_convert,v1,v2,v3,hue1,li1,sat1,/rgb_hls
;    zscl=max(abs(zrange(0:1)))
    nt=256-32
    hue=fltarr(nt)
    sat=fltarr(nt)
    li=fltarr(nt)
 ;   zp = (interpol([0,nt],[zrange(0),zrange(1)],0.))(0)
    hue(0:nt/2-1) = 240.
    hue(nt/2:*) = 0.
    default,darkness,1.0
    lightness=1-darkness
    if keyword_set(ctfix) or !d.name eq 'PS' then $
;    if 1 eq 0 then $
      li=[linspace(lightness,1,nt/2-2),linspace(1,lightness,nt/2+2)] $
      else $
      li=[linspace(1,lightness,nt/2),linspace(lightness,1,nt/2)]

;      li=[linspace(0,1,nt/2-2),linspace(1,0,nt/2+2)] $
;      else $
;      li=[linspace(1,0,nt/2),linspace(0,1,nt/2)]



;abs(linspace(zrange(0),zrange(1),nt))/zscl
    sat(*) = 1.
    hue=[hue1(0:31),hue]
    li=[li1(0:31),li]
    sat=[sat1(0:31),sat]

    tvlct,hue,li,sat,/hls

;    tek_color
;    !p.background=0
;    !p.color=255
    !p.background=0
    !p.color=1
;    contour,z,nl=100,/fill
;    return
;    stop
endif else begin



    loadct,pal,/silent
    tvlct,ct1,ct2,ct3,/get
;endif else begin
    nt=256
    hue=fltarr(nt)
    sat=fltarr(nt)
    li=fltarr(nt)

    hue(0:nt/2-1) = 0.
    hue(nt/2:*) = 120.
    li=abs(linspace(-1,1,nt))
    sat(*) = 1.
    color_convert,hue,li,sat,ct1,ct2,ct3,/hls_rgb
    
;    tvlct,hue,li,sat,/hls
;    stop


    tek_color
    ct1b=[fltarr(32),interpol(float(ct1),findgen(256),linspace(0,255,256-32))]
    ct2b=[fltarr(32),interpol(float(ct2),findgen(256),linspace(0,255,256-32))]
    ct3b=[fltarr(32),interpol(float(ct3),findgen(256),linspace(0,255,256-32))]
    tvlct,ct1b,ct2b,ct3b
;print,n_elements(ct1b)
    tek_color
endelse


!p.color=1
!p.background=0
end
