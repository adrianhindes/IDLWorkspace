pro correlation_fit_old


asdf = jw_bes_xcorr_old(9127,'4-1','4-1',trange=[3.4,3.8],freq_filter=[0.01, 1.0],subwindow_npts=2048)
xcorr1 = replicate(asdf, 4)
xcorr1[1] = jw_bes_xcorr_old(9127,'4-1','3-1',trange=[3.4,3.8],freq_filter=[0.01, 1.0],subwindow_npts=2048)
xcorr1[2] = jw_bes_xcorr_old(9127,'4-1','2-1',trange=[3.4,3.8],freq_filter=[0.01, 1.0],subwindow_npts=2048)
xcorr1[3] = jw_bes_xcorr_old(9127,'4-1','1-1',trange=[3.4,3.8],freq_filter=[0.01, 1.0],subwindow_npts=2048)
;
corr_value = dblarr(4,4)
corr_value_std = dblarr(4,4)
corr_value_en = dblarr(4,4)
corr_value_en_std = dblarr(4,4)
for i = 0L, 3L do begin
  corr_value[0,i] = mean(xcorr1[i].corr_value[0,*])
  array_size = size(xcorr1[1].corr_value,/dimensions)
  corr_value_std[0,i] = stddev(xcorr1[i].corr_value[0,*])/sqrt(array_size[1])
  corr_value_en[0,i] = mean(xcorr1[i].corr_value[1,*])
  corr_value_en_std[0,i] = stddev(xcorr1[i].corr_value[1,*])/sqrt(array_size[1])
endfor

;;;;;;;;;;;;;;;;;;;;;;;

asdf = jw_bes_xcorr_old(9127,'3-1','4-1',trange=[3.4,3.8],freq_filter=[0.01, 1.0],subwindow_npts=2048)
xcorr2 = replicate(asdf, 4)
xcorr2[1] = jw_bes_xcorr_old(9127,'3-1','3-1',trange=[3.4,3.8],freq_filter=[0.01, 1.0],subwindow_npts=2048)
xcorr2[2] = jw_bes_xcorr_old(9127,'3-1','2-1',trange=[3.4,3.8],freq_filter=[0.01, 1.0],subwindow_npts=2048)
xcorr2[3] = jw_bes_xcorr_old(9127,'3-1','1-1',trange=[3.4,3.8],freq_filter=[0.01, 1.0],subwindow_npts=2048)
;

for i = 0L, 3L do begin
  corr_value[1,i] = mean(xcorr2[i].corr_value[0,*])
  array_size = size(xcorr2[1].corr_value,/dimensions)
  corr_value_std[1,i] = stddev(xcorr2[i].corr_value[0,*])/sqrt(array_size[1])
  corr_value_en[1,i] = mean(xcorr2[i].corr_value[1,*])
  corr_value_en_std[1,i] = stddev(xcorr2[i].corr_value[1,*])/sqrt(array_size[1])
endfor
;;;;;;;;;;;;;;;;;;;;;;;
asdf = jw_bes_xcorr_old(9127,'2-1','4-1',trange=[3.4,3.8],freq_filter=[0.01, 1.0],subwindow_npts=2048)
xcorr3 = replicate(asdf, 4)
xcorr3[1] = jw_bes_xcorr_old(9127,'2-1','3-1',trange=[3.4,3.8],freq_filter=[0.01, 1.0],subwindow_npts=2048)
xcorr3[2] = jw_bes_xcorr_old(9127,'2-1','2-1',trange=[3.4,3.8],freq_filter=[0.01, 1.0],subwindow_npts=2048)
xcorr3[3] = jw_bes_xcorr_old(9127,'2-1','1-1',trange=[3.4,3.8],freq_filter=[0.01, 1.0],subwindow_npts=2048)
;

for i = 0L, 3L do begin
  corr_value[2,i] = mean(xcorr3[i].corr_value[0,*])
  array_size = size(xcorr3[1].corr_value,/dimensions)
  corr_value_std[2,i] = stddev(xcorr3[i].corr_value[0,*])/sqrt(array_size[1])
  corr_value_en[2,i] = mean(xcorr3[i].corr_value[1,*])
  corr_value_en_std[2,i] = stddev(xcorr3[i].corr_value[1,*])/sqrt(array_size[1])
endfor
;;;;;;;;;;;;;;;;;;;;;;;
asdf = jw_bes_xcorr_old(9127,'1-1','4-1',trange=[3.4,3.8],freq_filter=[0.01, 1.0],subwindow_npts=2048)
xcorr4 = replicate(asdf, 4)
xcorr4[1] = jw_bes_xcorr_old(9127,'1-1','3-1',trange=[3.4,3.8],freq_filter=[0.01, 1.0],subwindow_npts=2048)
xcorr4[2] = jw_bes_xcorr_old(9127,'1-1','2-1',trange=[3.4,3.8],freq_filter=[0.01, 1.0],subwindow_npts=2048)
xcorr4[3] = jw_bes_xcorr_old(9127,'1-1','1-1',trange=[3.4,3.8],freq_filter=[0.01, 1.0],subwindow_npts=2048)
;

for i = 0L, 3L do begin
  corr_value[3,i] = mean(xcorr4[i].corr_value[0,*])
  array_size = size(xcorr4[1].corr_value,/dimensions)
  corr_value_std[3,i] = stddev(xcorr4[i].corr_value[0,*])/sqrt(array_size[1])
  corr_value_en[3,i] = mean(xcorr4[i].corr_value[1,*])
  corr_value_en_std[3,i] = stddev(xcorr4[i].corr_value[1,*])/sqrt(array_size[1])
endfor
;;;;;;;;;;;;;;;;;;;;;;;

ycplot,[0:3:1] ,corr_value[0,*], error=corr_value_std[0,*], out_base_id = oid
ycplot,[0:3:1] ,corr_value_en[0,*], error=corr_value_en_std[0,*], oplot_id = oid
ycplot,[-1:2:1] ,corr_value[1,*], error=corr_value_std[1,*], oplot_id = oid
ycplot,[-1:2:1] ,corr_value_en[1,*], error=corr_value_en_std[1,*], oplot_id = oid
ycplot,[-2:1:1] ,corr_value[2,*], error=corr_value_std[2,*], oplot_id = oid
ycplot,[-2:1:1] ,corr_value_en[2,*], error=corr_value_en_std[2,*], oplot_id = oid
ycplot,[-3:0:1] ,corr_value[3,*], error=corr_value_std[3,*], oplot_id = oid
ycplot,[-3:0:1] ,corr_value_en[3,*], error=corr_value_en_std[3,*], oplot_id = oid


stop
end