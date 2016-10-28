pro plotsymbol,n,color=color,thick=thick,size=size
;Defines a plot symbol for the user symbol in PSYM
; Use PSYM=8 to use this symbol
; n:  0: filled circle
;     1: filled square
;     2: open circle
;     3: open square
;	  4: filled triangle
;     5: open triangle
;     6: x
;     7: asterisk

default,size,1

if (not keyword_set(color)) then color=!p.color
if (not keyword_set(thick)) then thick=!p.thick
if (n eq 0) then begin
  a=findgen(20)*(!PI*2/20.)
  usersym,cos(a)*size,sin(a)*size,/fill,color=color,thick=thick
  return
endif
if (n eq 1) then begin
  x=[-1,1,1,-1]
  y=[-1,-1,1,1]
  usersym,x*size,y*size,/fill,color=color,thick=thick
endif
if (n eq 2) then begin
  a=findgen(20)*(!PI*2/19.)
  usersym,cos(a)*size,sin(a)*size,color=color,thick=thick
  return
endif
if (n eq 3) then begin
  x=[-1,1,1,-1,-1]
  y=[-1,-1,1,1,-1]
  usersym,x*size,y*size,color=color,thick=thick
endif
if (n eq 4) then begin
  r=sqrt(1.0/2/(1-cos(2*!pi/3)))*2
	m=sqrt(1-0.5*0.5)*2
  x=[-1,1,0,-1]
  y=[-(m-r),-(m-r),r,-(m-r)]
  usersym,x*size,y*size,color=color,/fill,thick=thick
endif
if (n eq 5) then begin
  r=sqrt(1.0/2/(1-cos(2*!pi/3)))*2
	m=sqrt(1-0.5*0.5)*2
  x=[-1,1,0,-1]
  y=[-(m-r),-(m-r),r,-(m-r)]
  usersym,x*size,y*size,color=color,thick=thick
endif
if (n eq 6) then begin
  x=[-1,0,1,0,1,0,-1]
  y=[-1,0,-1,0,1,0,1]
  usersym,x*size,y*size,color=color,thick=thick
endif
if (n eq 7) then begin
  d=1/sqrt(2)
  x=[-1,0,-d,0,0,0,d,0,1,0,d,0,0,0,-d,0]
  y=[0,0,-d,0,-1,0,-d,0,0,0,d,0,1,0,d,0]
  usersym,x*size,y*size,color=color,thick=thick
endif

end
