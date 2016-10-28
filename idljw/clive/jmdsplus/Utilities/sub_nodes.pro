;--------------------------------------------------------------
function sub_nodes, node, list=list, child=child, member=member, $
                    status=status, quiet=quiet
;
; find all nodes directly under input NODE (fullpath)
; restrict search to LIST if it is supplied
;

  if n_params() eq 0 then begin
      print,'Please supply node name'
      status = 0B
      return, ''
  end
  
  name = mdsvalue('getnci($,"FULLPATH")',node, quiet=quiet, stat=status)
  if not status then begin
      print,'Please open a tree for search or provide valid node name'
      return, ''
  end

;  mdssetdefault, name

  if n_elements(list) eq 0 then begin
      ids = mdsvalue('getnci("***","NID_NUMBER")', qui=quiet, stat=status)
      list = mdsvalue('getnci($,"FULLPATH")', ids, quiet=quiet, stat=status)
  end else ids = mdsvalue('getnci($,"NID_NUMBER")', list, $
                          qui=quiet, stat=status)
  
  p = strpos(list, name) 
  p0 = where(p ne -1, np0) 
  if np0 gt 0 then ids = ids(p0) else begin
      ids = -1L  &  return, '' 
  end

  if keyword_set(child) then begin
    ch = mdsvalue('getnci($,"IS_CHILD")', ids)
    ch_ids = where(ch eq 1, n_ch)
    if n_ch gt 0 then ids = ids(ch_ids)
  end

  if keyword_set(member) then begin
    mbr = mdsvalue('getnci($,"IS_MEMBER")', ids)
    mbr_ids = where(mbr eq 1, n_mbr)
    if n_mbr gt 0 then ids = ids(mbr_ids)
  end

  return, mdsvalue('getnci($,"FULLPATH")', ids)

end               

