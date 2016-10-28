; docformat = 'idl'

;+
; NAME:
;   wset_mda
; PURPOSE:
;        This routine extend the functionality of wset.
;        It try to select the index window as the current one.
;        If it is not open, it creates a new window with size
;        set by keyword XSIZE & YSIZE
;        
; CATEGORY
;       visualization, window
;
; CALLING SEQUENCE:
;       wset_mda,index, _EXTRA = ex 
;
; INPUTS:
;       index : window index
;
; KEYWORD PARAMETERS
;       _EXTRA : passes all the keyword to the window procedure
;       useful example are:
;       XSIZE : x size of new window,if it doesn't exist
;       YSIZE : y size of new window,if it doesn't exist 
;
; RESTRICTIONS:
;       Same as wset, window are normally have index 31 as maximum.
; 
; EXAMPLE
;       wset_mda,0,xsize=800,ysize=600
;       It will create a window with 0 index with sizes xsize and ysize.
; 
; MODIFICATION HISTORY:
;       Written by Mario D'Amore, German Aerospace Center (DLR), 2010.
;
; ToDo: 1- Change standard window size externally to minimize keyword.
;       2- If index given, just check for the first available index.
;       3- if window does not exist set it (wset) and resize to xsize and ysize.
;       
;-
pro wset_mda,index, _EXTRA = ex 
device, window_state=windows
case  windows(index) of
  0: if (N_ELEMENTS(ex) ne 0) then window,index,XSIZE=ex.XSIZE,YSIZE=ex.YSIZE else window,index     
  1: wset, index
endcase 
;help,ex,/str
end