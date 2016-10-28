pro mdswrite, tree, shotno

;  mdstc
;  l,'set tree '+tree+'/shot ='+strtrim(shotno,2)
   mdstcl,'write'
   if n_elements(tree) ne 0 then mdsclose, tree, shotno else mdsclose
; seems some wait time is necessary to make this work!!
wait,1

end


