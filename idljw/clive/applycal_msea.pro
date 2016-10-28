pro applycal_msea, strtmp, xpar
j=0
for pl=4,4 do begin
strtmp.(pl).thicknessmm+=xpar(j++)
strtmp.(pl).angle+=xpar(j++)
;if pl eq 4 then strtmp.(pl).facetilt+=xpar(j++)
endfor
end
