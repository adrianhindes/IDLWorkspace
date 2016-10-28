pro save_corr_map

i=1
corr_map020 = corr_ex(9133, 3, trange = [0.0, 8.0],window_npts = 25088)
save, corr_map020, FILENAME = '/home/ijwkim/IDL/BES_data_analysis/shot9133_0.0-8.0sec_25msec.sav'
;i=2
;corr_map030 = corr_ex(9286, 1, trange = [1.0, 9.0],time_size = 0.030)
;save, corr_map030, FILENAME = '/home/ijwkim/IDL/BES_data_analysis/shot9286_2-9sec_30msec.sav'
;i=3
;corr_map040 = corr_ex(9286, 1, trange = [1.0, 9.0],time_size = 0.040)
;save, corr_map040, FILENAME = '/home/ijwkim/IDL/BES_data_analysis/shot9286_2-9sec_40msec.sav'
;i=4
;corr_map050 = corr_ex(9286, 1, trange = [1.0, 9.0],time_size = 0.050)
;save, corr_map050, FILENAME = '/home/ijwkim/IDL/BES_data_analysis/shot9286_2-9sec_50msec.sav'
stop

end