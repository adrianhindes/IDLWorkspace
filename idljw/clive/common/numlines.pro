; Copyright (c) 1999, Strathclyde University.
; SCCS info: Module @(#)$Header: /home/adascvs/idl/adaslib/util/numlines.pro,v 1.1 2004/07/06 14:25:01 whitefor Exp $ Date $Date: 2004/07/06 14:25:01 $
;+
; PROJECT:
;       ADAS 
;
; NAME:
;	NUMLINES
;
; PURPOSE:
;	Calculates how many lines in a text file are occupied by a vector
;       given a fixed number of enteries per line.
;
; EXPLANATION:
;
; INPUTS:
;       ndim   - size of vector.
;       lenght - number of numbers permitted in a line.
;
; OPTIONAL INPUTS:
;	None.
;
; OUTPUTS:
;       The number of lines.
;
; EXAMPLE:
;       Say a vector of 25 elements and 7 numbers permitted per line
;                      1 2 3 4 5 6 7 
;                      7 6 5 4 3 2 1
;                      1 2 3 4 5 6 7
;                      1 2 3 4
;       print,numlines(25,7) gives 4
;
; OPTIONAL OUTPUTS:
;       None
;
; KEYWORD PARAMETERS:
;       None
;
; CALLS:
;       None
;	
; SIDE EFFECTS:
;	None
;
; CATEGORY:
;	Utility
;
; WRITTEN:
;       Martin O'Mullane
;
; MODIFIED:
;	1.1	Martin O'Mullane
;		First release 
;
; VERSION:
;       1.1	17-03-99
;
;-
;-----------------------------------------------------------------------------

function numlines, ndim, length

return, ( (ndim/length) + min([1,ndim mod length]) )

end
