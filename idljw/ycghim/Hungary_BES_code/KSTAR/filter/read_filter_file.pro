pro read_filter_file
  cd, 'D:\KFKI\svn\KSTAR'
  data=read_csv('Andover_660nmfilter_spectra.csv')
  temp=double(strsplit(data.field1[2], ';', /extract))
  n_row=n_elements(data.field1)
  n_col=n_elements(temp)
  data_matrix=dblarr(n_row-2,n_col)
  for i=0,n_row-3 do begin
    data_matrix[i,*]=double(strsplit(data.field1[i+2], ';', /extract))
  endfor
  data=data_matrix
  angle=[0,2,4,6,8,10,12,14,0,6,0,6,0,6,0,6,0,6,0,6]
  wavelength=data[*,0]
  data=data[*,1:20]
  save, data, angle, wavelength, filename='Andover_660nmfilter_spectra.sav'
  stop
end