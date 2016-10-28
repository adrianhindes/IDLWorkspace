pro applycal_wb1, strtmp, xpar,dodel=dodel,test1=test1

j=0
ipl=[1,4]
iplb=[2,5]
nn=2
for ii=0,nn-1 do begin
strtmp.(ipl(ii)).thicknessmm+=xpar(j++)
strtmp.(ipl(ii)).angle+=xpar(j)
if not keyword_set(test1) then strtmp.(iplb(ii)).angle+=xpar(j++)
if keyword_set(test1) and ii eq 0 then strtmp.(iplb(ii)).angle+=xpar(j++)
endfor
if keyword_set(dodel) then begin
for ii=0,nn-1 do begin
if not keyword_set(test1) then strtmp.(iplb(ii)).thicknessmm+=xpar(j++) ;; maybe not
if keyword_set(test1) and ii eq 0 then strtmp.(iplb(ii)).thicknessmm+=xpar(j++) ;; maybe not


;if pl eq 4 then strtmp.(pl).facetilt+=xpar(j++)
endfor
endif

end
