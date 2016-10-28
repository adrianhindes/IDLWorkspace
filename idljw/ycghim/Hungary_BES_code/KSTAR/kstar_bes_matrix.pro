function kstar_bes_matrix,row,column,vertical=vert
;***************************************************************
;* KSTAR_BES_MATRIX.PRO (FUNCTION)     S. Zoletnik 28.08.2013  *
;***************************************************************
;* Returns a channel name (BES-x-x) for a row, column position *
;* on a plot which represents the view of the BES matrix as    *
;* on the NBI from the other side than the real observation:   *
;* right is edge and top is top.                               *
;* INPUT:                                                      *
;*   column: 1...8  from left to right                         *
;*   row: 1...4 from bottom to top                             *
;*   /vertical: vertical camera position                       *
;***************************************************************

if (keyword_set(vert)) then begin
   chname = 'BES-'+i2str(5-column)+'-'+i2str(9-row)
endif else begin
  chname = 'BES-'+i2str(row)+'-'+i2str(9-column)
endelse
return,chname
end
