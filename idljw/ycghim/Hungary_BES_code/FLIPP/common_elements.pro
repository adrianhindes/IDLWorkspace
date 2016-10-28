function common_elements,a,b,ind_a=ind_a,ind_b=ind_b
;*******************************************************************************
;   COMMON_ELEMENTS.PRO                 S. Zoletnik   27.06.2004               *
;                                                                              *
; Find common elements in 1D vectors a and be and return the indices           *
; to the common elements in ind_a and ind_b. This way a[ind_a] and             *
; b[ind_b] will be the same arrays. The input arrays should have all different *
; values.                                                                      *
;                                                                              *
; Return value:                                                                *
;   This function returns 1 if there is at least one common element,           *
;   otherwise it returns 0.                                                    *
;                                                                              *
; INPUT:                                                                       *
;   a: 1D array                                                                *
;   b: 1D array (length of two arrays can be different)                        *
;                                                                              *
; OUTPUT:                                                                      *
;   ind_a: index array to common elements in a (-1 if no common elements)      *
;   ind_b: index array to common elements in b (-1 if no common elements)      *
;*******************************************************************************


ind_a = -1
ind_b = -1

for ia=0,n_elements(a)-1 do begin
  ind = where(a[ia] eq b)
  if (ind[0] ge 0) then begin
    if (ind_a[0] eq -1) then begin
      ind_a = ia
      ind_b = ind
    endif else begin
      ind_a = [ind_a,ia]
      ind_b = [ind_b,ind]
    endelse
  endif
endfor

if (ind_a[0] eq -1) then return,0 else return,1
        
end        
