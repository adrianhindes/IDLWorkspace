pro tview, fil,zr=zr
d=read_tiff(fil)
imgplot,d,/cb,zr=zr,title=fil
d='' & read,d
end
