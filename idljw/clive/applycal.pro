pro applycal, strtmp, xpar
j=0
for pl=2,4 do begin
strtmp.(pl).thicknessmm+=xpar(j++)
strtmp.(pl).angle+=xpar(j++)
;if pl eq 4 then strtmp.(pl).facetilt+=xpar(j++)
endfor
end
