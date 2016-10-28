pro write_local_kstar_data, shotno, d1,d2,d3,d4,d5,d6,d7,d8,$
      d9,d10,d11,d12,d13,d14,d15,d16, subtree=subtree, create=create

    if n_params() gt 17 then stop,'cannot write more than 16 nodes'
    default, tree, 'kstar'
    
    mdsedit, tree, shotno, status=status, /quiet
;    mdstcl,'edit '+tree+' /shot='+strtrim(shotno, 2), status=status
      
    if not status then begin
      if keyword_set(create) then answer = 'Y' else begin
        answer = 'y'
        read,prompt = 'Shot not found.  Create new pulse at shot # '+strtrim(shotno,2)+' (y/n):  ', answer
      end
      
      if strupcase(answer) eq 'Y' then begin
        mdstcl,'set tree '+tree
        mdstcl,'create pulse '+strtrim(shotno,2)
        mdstcl,'edit '+tree+' /shot='+strtrim(shotno, 2), status=status
      end else begin
        print,'Write request cancelled'
        return
      end
    end
 
; this is a kludge
    find_or_create_node, '.KSTAR'
    if keyword_set(subtree) then find_or_create_node, '.KSTAR.'+subtree
    
    if n_elements(d1) ne 0 then write_local_kstar_node, d1
    if n_elements(d2) ne 0 then write_local_kstar_node, d2
    if n_elements(d3) ne 0 then write_local_kstar_node, d3
    if n_elements(d4) ne 0 then write_local_kstar_node, d4
    if n_elements(d5) ne 0 then write_local_kstar_node, d5
    if n_elements(d6) ne 0 then write_local_kstar_node, d6
    if n_elements(d7) ne 0 then write_local_kstar_node, d7
    if n_elements(d8) ne 0 then write_local_kstar_node, d8
    if n_elements(d9) ne 0 then write_local_kstar_node, d9
    if n_elements(d10) ne 0 then write_local_kstar_node, d10
    if n_elements(d11) ne 0 then write_local_kstar_node, d11
    if n_elements(d12) ne 0 then write_local_kstar_node, d12
    if n_elements(d13) ne 0 then write_local_kstar_node, d13
    if n_elements(d14) ne 0 then write_local_kstar_node, d14
    if n_elements(d15) ne 0 then write_local_kstar_node, d15
    if n_elements(d16) ne 0 then write_local_kstar_node, d16

    mdswrite, tree, shotno
;    mdstcl, 'write', quiet=quiet
;    mdsclose, tree, shotno

;print,'Cleaning the tree ..''
;    mdsclean, tree, shotno
 
end
    