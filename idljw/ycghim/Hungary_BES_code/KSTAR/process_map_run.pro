pro process_map_run
  set_plot_style, 'foile_eps_kg'
  for i=2,5 do begin
    channel='BES-2-'+strtrim(i,2)
    hardon, /color
    show_ecei_bes_correlation_map, 6123, 1.61, refchannel=channel
    hardfile, 'BES_ECEi_map_'+channel+'.ps'
  endfor
end