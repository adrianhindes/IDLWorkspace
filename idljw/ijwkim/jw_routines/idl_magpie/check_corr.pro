pro check_corr
   shot_number = 635
   isat = magpie_data('probe_isat',shot_number)
   isatr = magpie_data('probe_isat_rot',shot_number)
   
   isat_cut = select_time((*isat[i]).tvector,(*isat[i]).vvector,trange)
   pmt_cut = select_time((*pmt[i]).tvector,(*pmt[i]).vvector,trange)
   corr_tmp = corr_time(isat_cut.tvector,isat_cut.yvector,isatr_cut.yvector,freq_filter = freq_filter,window_npts = window_npts, subwindow_npts=subwindow_npts, fast = 20)

end