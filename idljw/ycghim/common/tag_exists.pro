;--------------------------------------------------------------------------
; Function: TAG_EXISTS
; Date: 16.02.06
; Author: R.Martin
;--------------------------------------------------------------------------
; TAG_EXISTS
; 
; Checks for the existance of a tag inside an IDL structure.
;
; Calling Sequence
;
; result=TAG_EXISTS(struct, tag_list, count=count, index=index)
;
; struct      - IDL-structure
; tag_list    - String array containing list of tag names to be tested for. 
;               
; result      - Bytarr True(1B) if tag_exists False(0B) otherwise
; index       - Index/position of tag name in structure, -1 if tag not
;               found.
; count       - Number of matching tags found.
;
; Notes:
;  If either arguement is invalid i.e. STRUCT is not an IDL structure,
;  or TAG_LIST arguement is not a string array the function returns
;  FALSE(0B) for all elements in TAG_LIST. 
;
;  In both cases a warning message is produced.
;
;--------------------------------------------------------------------------
;

function tag_exists, struct, arg, index=index, count=count

  count=0L
  if (n_elements(arg) le 1) then index=-1 else index=replicate(-1, size(arg, /dim))
  if not_structure(struct) then begin
    print, 'TAG_EXISTS: Warning Arg[1] not a structure'
    return, (index ne -1)
  endif

  if not_string(arg) then begin
    print, 'TAG_EXISTS: Arg[2] must be a string array'
    return, (n_elements(arg) le 1) ? 0B : bytarr(n_elements(arg))
  endif

  tags=tag_names(struct[0])

  ctags=strupcase(arg)

  for i=0, n_elements(arg)-1 do index[i]=where(tags eq ctags[i])

  count=total(index ne-1, /integer)
  return, (index ne -1)

end
