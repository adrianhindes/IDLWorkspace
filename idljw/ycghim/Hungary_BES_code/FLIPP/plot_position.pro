function plot_position, n, m, xgap=xgap, ygap=ygap, corner=corner, horizontal=horizontal, block=block, fromthetop=fromthetop

;**********************************************************
;*         plot_position       M. Lampert 2012. 04. 24.   *
;**********************************************************
;* This function returns a vector for the plot position.  *
;* It can be used effectively, when the number of plots   *
;* are quite high.                                        *
;**********************************************************
;* INPUTs:                                                *
;*      n: number of rows                                 *
;*      m: number of columns                              *
;*      xgap: the gap between rows (normal) (/OPT)        *
;*            default: 0                                  *
;*      ygap: the gap between columns (normal) (/OPT)     *
;*            default: 0                                  *
;*      corner: the coordinate of the outer 4 corner      *
;*              in normal (/OPT)                          *
;*              default: [0.05,0.05,0.95,0.95]            *
;*      /horizontal: the output vector numbers are        *
;*                   ascending in the horizontal direction*
;*                   default: 0                           *
;*	/fromthetop: the row number starts at the top     *
;*      block: if set, the output will be [n,m,4] array   *
;* OUTPUTs:                                               *
;*          [n*m,4] vector                                *
;**********************************************************

default, xgap, 0
default, ygap, 0
default, corner, [0.05,0.05,0.95+xgap,0.95+ygap]
default, horizontal, 0
default, block, 0
default, fromthetop,0

if not keyword_set(block) then begin
  table=dblarr(n*m,4)
  for i=0, n-1 do begin
    for j=0, m-1 do begin
      a=corner[0]+(corner[2]-corner[0])/double(m)*j
      b=corner[1]+(corner[3]-corner[1])/double(n)*i
      c=corner[0]+(corner[2]-corner[0])/double(m)*(j+1)-xgap
      d=corner[1]+(corner[3]-corner[1])/double(n)*(i+1)-ygap
      if not keyword_set(fromthetop) then begin
	  if keyword_set(horizontal) then begin
	    table[i*m+j,*]=fix([a,b,c,d]*10000.)/10000.
	  endif else begin
	    table[j*n+i,*]=fix([a,b,c,d]*10000.)/10000.
	  endelse
      endif else begin
	  if keyword_set(horizontal) then begin
	    table[(n-1-i)*m+j,*]=fix([a,b,c,d]*10000.)/10000.
	  endif else begin
	    table[j*n+n-i-1,*]=fix([a,b,c,d]*10000.)/10000.
	  endelse
      endelse
    endfor
  endfor
endif else begin
  if keyword_set(horizontal) then begin
      print,'Warning! If block option is set, horizontal option is omitted.'
  endif
  if keyword_set(fronthetop) then begin
      print,'Warning! If block option is set, fromthetop option is omitted.'
  endif
  table=dblarr(n,m,4)
  for i=0, n-1 do begin
    for j=0, m-1 do begin
      a=corner[0]+(corner[2]-corner[0])/double(m)*j
      b=corner[1]+(corner[3]-corner[1])/double(n)*i
      c=corner[0]+(corner[2]-corner[0])/double(m)*(j+1)-xgap
      d=corner[1]+(corner[3]-corner[1])/double(n)*(i+1)-ygap
      table[i,j,*]=fix([a,b,c,d]*10000.)/10000.
    endfor
  endfor
endelse
return, table
end
