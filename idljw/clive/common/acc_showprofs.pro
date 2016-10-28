pro acc_showprofs, pm=pmain, ilos=ilos, plotmask=plotmask, xrange=xrange, trange=trange, $
						 vrange=vrange, chordno=chordno, addslice=addslice, cutoff=cutoff, $
						 acc_showprofsstop=stop, _extra=extra

;----------------------------------------------------------------------------------------------------------;
;MW, 16/11/04
;Plots the data returned by acc_cutoff. Which data is plotted is determined by 
;'plotmask':
;
;bit	 0 v
;		 1	t
;		 2	YAG data
;		 3	S/N ratio
;		 4	beam penetration 
;		 5	errors
;		 6	chord numbers on v and t profiles
;		 7	spectrum, with fit overlaid, for chord 'chordno'
;		 8	print 'failedreason' to the screen
;		 9 raw spectra for this chord, for selected time slice from 'trendvec' time range
;		10 draw a vertical line to indicate the chords
;		11 plot some extra info
;		12 plot the q profile
;		13 Lock the y-axis on the CX spectrum plot
;		14	Lock the y-axis on the raw spectrum plot
;----------------------------------------------------------------------------------------------------------;

;Start plotting in the top left corner:
!p.multi[0]=0


;Extract relevant info from pmain:
vs 			= (*pmain).vs
numchords 	= (*(*pmain).pviewsets[vs]).numchords
radii 		= (*(*pmain).pviewsets[vs]).radii
chrel 		= ilos.chrel


;Set some colours/charsizes etc:
graphcol			= 0
errcol1			= 3	;Blue
errcol2			= 2	;Light green
errcol3			= 1	;Red
yagcol			= 6	;Purple
rubycol			= 5	;Cyan
nbicol			= 8
chordnumcol		= 4	;Yellow
subspeccol		= 8
fitspeccol		= 2
rawwidcol		= 3
rawposcol		= 2
inbicol			= 1	
intsigcol		= 4
rawfitcol		= 2
indicatorcol	= 2
qcol				= 3

vtitle 	= string((*pmain).shot)+' '+(*pmain).id + ' VELOCITY'
vxtitle 	= 'Radius (mm)'
vytitle 	= 'Velocity (km/s)'
ttitle 	= string((*pmain).shot)+' '+(*pmain).id + ' TEMPERATURE'
txtitle 	= 'Radius (mm)'
tytitle 	= 'Temperature (eV)'
sntitle	= 'signal/noise ratio'
bptitle	= 'Beam penetration profile and rel. signal'
bpytitle	= 'Normalized intensity'
fittitle = 'spectrum from chord: ' + strtrim(chordno,2) + ', Radius: ' + strtrim(radii[chordno],2)

chars  = 2	;Character size
charth = 2	;Character thickness


;;----------- VELOCITY PROFILE -----------
if plotmask[0] then begin
	xrange = keyword_set(xrange)? xrange:[min(radii), max(radii)]
	yrange = keyword_set(vrange)? vrange:[min(ilos.verr[0,*]/1e3),1.1*max(ilos.verr[1,*]/1e3)]
	plot, radii, ilos.v/1e3, title=vtitle, xtitle=vxtitle, ytitle=vytitle, col=graphcol, $
	xrange=xrange, yrange=yrange, chars=chars, yst=plotmask[12]? 8:0, _extra=extra
	if plotmask[5] then errplot, radii, ilos.verr[0,*]/1e3, ilos.verr[1,*]/1e3, col=graphcol

	;Plot indication of reliability
	w = WHERE((chrel LT 1.0) AND (chrel GE 0.5), count)
	IF count GT 0 THEN BEGIN
   	IF count EQ 1 THEN w = [w[0], w[0]] 									;to stop plot from complaining
   	oplot, radii[w], ilos.v[w]/1e3, color=errcol1, psym=2,  _extra=extra 	;blue
   	if plotmask[5] then errplot, radii[w], ilos.verr[0, w]/1e3, ilos.verr[1, w]/1e3, color=errcol1
	ENDIF
	w = WHERE(chrel EQ 0.0, count)
	IF count GT 0 THEN BEGIN
   	IF count EQ 1 THEN w = [w[0], w[0]]
   	oplot, radii[w], ilos.v[w]/1e3, color=errcol3, psym=2, _extra=extra		;red
   	if plotmask[5] then errplot, radii[w], ilos.verr[0,w]/1e3, ilos.verr[1, w]/1e3, color=errcol3
	ENDIF

	;Show which chord we're looking at:
	if plotmask[10] then begin
		xyouts, !d.x_size*.06, !d.y_size*.93, 'chord: ', /dev, col=graphcol & xyouts, strtrim(chordno,2), col=graphcol
		xyouts, !d.x_size*.06, !d.y_size*.91, 'v: ', /dev, col=graphcol & xyouts, strtrim(fix(ilos.v[chordno]/1e3),2), col=graphcol
		if radii[chordno] ge xrange[0] then begin	;plot a vertical line to indicate the chord
			col = chrel[chordno] eq 1? graphcol : (chrel[chordno] eq 0.5 ? errcol1 : errcol3)
			plots, [radii[chordno],radii[chordno]],[yrange[0],yrange[1]], col=col
		endif
	endif
	
	;Plot chord numbers
	if plotmask[6] then for i=0,numchords-1 do xyouts, al=0.5, radii[i], 1.1*ilos.verr[1,i]/1e3, strtrim(i,2),noclip=0, col=graphcol

	;Overplot the q-profile
	if plotmask[12] then begin
		qr = (*pmain).qprof.r
		q = (*pmain).qprof.q
		ind = where(reverse(q) gt 0)	;use this to cut off outboardmost crap
		max = n_elements(q)-ind[0]-1
		axis, yax=1, yr=[0,6], col=qcol, ytitle='EFIT q-profile', chars=chars, /save
		oplot, qr[0:max], q[0:max], col=qcol

		;Find q for the current chord:
		qnow = interpol(q, qr, radii[chordno],/quadratic)
		xyouts, !d.x_size*.06, !d.y_size*.89, 'q: ', /dev, col=3 & xyouts, strtrim(qnow,2), col=3
	endif
endif


;;------------- TEMPERATURE PROFILE ------------
if plotmask[1] then begin
	xrange = keyword_set(xrange)? xrange:[0,0]
	tyrange = keyword_set(trange)? trange:[min(ilos.terr[0,*]),1.1*max(ilos.terr[1,*])]
	plot, radii, ilos.t, title=ttitle, xtitle=txtitle, ytitle=tytitle, col=graphcol, $
	xrange=xrange, yrange=tyrange, chars=chars, yst=plotmask[12]? 8:0, _extra=extra
	if plotmask[5] then errplot, radii, ilos.terr[0,*] , ilos.terr[1,*], col=graphcol

	;Plot an indication of the reliability
	w = WHERE((chrel LT 1.0) AND (chrel GE 0.5), count)
	IF count GT 0 THEN BEGIN
   	IF count EQ 1 THEN w = [w[0], w[0]] ;To stop plot from complaining
   	oplot, radii[w], ilos.t[w], color=errcol1, psym=2, _extra=extra		;blue
   	if plotmask[5] then errplot, radii[w], ilos.terr[0, w], ilos.terr[1, w], color=errcol1
	ENDIF
	w = WHERE(chrel EQ 0.0, count)
	IF count GT 0 THEN BEGIN
   	IF count EQ 1 THEN w = [w[0], w[0]]
   	oplot, radii[w], ilos.t[w], color=errcol3, psym=2, _extra=extra		;red
   	if plotmask[5] then errplot, radii[w], ilos.terr[0, w], ilos.terr[1, w], color=errcol3
	ENDIF

	;Show which chord we're looking at:
	if plotmask[10] and radii[chordno] ge xrange[0] then begin
		xyouts, !d.x_size*.31, !d.y_size*.93, 'chord: ', /dev, col=graphcol & xyouts, strtrim(string(chordno),2), col=graphcol
		xyouts, !d.x_size*.31, !d.y_size*.91, 'T: ', /dev, col=graphcol & xyouts, strtrim(string(fix(ilos.t[chordno])),2), col=graphcol
		col = chrel[chordno] eq 1? graphcol : (chrel[chordno] eq 0.5 ? errcol1 : errcol3)
		plots, [radii[chordno],radii[chordno]] ,[tyrange[0], tyrange[1]], col=col
	endif
	
	;Plot chord numbers
	if plotmask[6] then for i=0,numchords-1 do xyouts,al=.5,radii[i],1.1*ilos.terr[1,i],strtrim(i,2),noclip=0, col=graphcol

	;Overplot the q-profile
	if plotmask[12] then begin
		qr = (*pmain).qprof.r
		q = (*pmain).qprof.q
		ind = where(reverse(q) gt 0)	;use this to cut off outboardmost crap
		max = n_elements(q)-ind[0]-1
		axis, yax=1, yr=[0,6], col=qcol, ytitle='EFIT q-profile', chars=chars, /save
		oplot, qr[0:max], q[0:max], col=qcol
	endif
endif


;;-------------- YAG DATA --------------
if plotmask[2] then begin
	if isstruct((*pmain).ts.yag) then begin
	   oplot, (*pmain).ts.yag.r*1e3, (*pmain).ts.yag.t_e, color=yagcol	;purple
	endif
	oplot,(*pmain).ts.ruby.r*1e3, (*pmain).ts.ruby.t_e, col=rubycol 	;cyan, if no data, will be a flat-line at zero
endif


;;----------- SIGNAL/NOISE RATIO ---------
if plotmask[3] then begin 
	plot, radii, ilos.snratio, title=sntitle, xtitle='Radius (mm)', chars=chars, col=graphcol, _extra=extra

	;Show which chord we're looking at:
	if plotmask[10] then plots, [radii[chordno],radii[chordno]] ,[0,max(ilos.snratio)], col=indicatorcol, _extra=extra
endif


;;----------- BEAM PENETRATION -----------
if plotmask[4] then begin
	plot, radii, norm_marco(ilos.inputsig), title=bptitle , xtitle='Radius (mm)', ytitle = bpytitle, chars=chars, col=graphcol, _extra=extra
	oplot, radii, (*pmain).bi, col=graphcol, _extra=extra

	;Show which chord we're looking at:
	if plotmask[10] then plots, [radii[chordno],radii[chordno]] ,[0,1], col=indicatorcol
endif


;------------ FITS --------------
if plotmask[7] then begin
	yrange = plotmask[13]? [min(ilos.spectra),max(ilos.spectra)]:[0,0]
	plot, ilos.spectra[*,chordno], title=fittitle , xtitle='Pixel', chars=chars, yrange=yrange, col=graphcol
	oplot, ilos.fitspec[*,chordno],col=fitspeccol
endif


;---------- FAILEDREASON --------
if plotmask[8] then begin
	failmask=ilos.failmask[*,chordno]
	ind = where(failmask ne 0, cnt)
	if cnt gt 0 then begin
		for i=0,cnt-1 do print, string(chordno)+': '+(*pmain).failedreason[ind[i]]
	endif else begin
		print, string(chordno)+': -'
	endelse
endif


;------------ RAW SIGNALS ---------------
if plotmask[9] then begin
	slice = (*pmain).cutoff[0,cutoff]+addslice
	rawsigtitle = 'Raw signal from chord: ' + strtrim(chordno,2) + ', ' + 'slice: ' + strtrim(slice,2)
	yrange = plotmask[14]? [min((*pmain).rawspectra[*,chordno,*]),max((*pmain).rawspectra[*,chordno,*])]:[0,0]
	plot, (*pmain).rawspectra[*,chordno,slice], title=rawsigtitle, xtitle='Radius (mm)', chars=chars, yrange=yrange, col=graphcol, _extra=extra
endif


;-------- PLOT SOME INFO ---------------
if plotmask[11] then begin
	plot, fltarr(2), yr=[0,10]	;This is not visible, but we'll use it as a coordinate frame for xyouts.
	xyouts, 0,9, strupcase((*pmain).whatbeam) + ' Cutoff at slice: ', col=0 & xyouts, strtrim((*pmain).cutoff[0,cutoff],2), col=0 
	xyouts,  '  Time: ', col=0 & xyouts, strtrim((*pmain).cutofftime[0,cutoff],2), col=0
	xyouts, 0,8, 'Last slice: ', col=0 & xyouts, strtrim((*pmain).cutoff[1,cutoff],2), col=0 
	xyouts, '   Time: ', col=0 & xyouts, strtrim((*pmain).cutofftime[1,cutoff],2), col=0

	if isstruct((*pmain).ts.yag) then begin
		xyouts, 0,7, 'Yag time: ', col=0 & xyouts, strtrim((*pmain).ts.yag.time,2), col=0
	endif else xyouts, 0,7, 'No YAG data available', col=1

	if isstruct((*pmain).ts.ruby) then begin
		xyouts, 0,6, 'Ruby time: ', col=0 & xyouts, strtrim((*pmain).ts.ruby.time,2), col=0
	endif else xyouts, 0,6, 'No Ruby data available', col=1

	alpha = dims((*pmain).alpha,1) gt 1? (*pmain).alpha[chordno,cutoff] : $
				n_elements((*pmain).alpha) gt 1? (*pmain).alpha[0,cutoff] : (*pmain).alpha
	xyouts, 0, 5, 'ALPHA: ', col=0 & xyouts, strtrim(alpha,2), col=0

	xyouts, 0, 4, 'tbin: ', col=0 & xyouts, strtrim((*pmain).tbin,2), col=0
	xyouts, 0, 3, 'rbin: ', col=0 & xyouts, strtrim((*pmain).rbin,2), col=0
	xyouts, 0, 2, 'first chord: ', col=0 & xyouts, strtrim((*pmain).firstchord,2), col=0
	xyouts, 0, 1, 'last chord: ', col=0 & xyouts, strtrim((*pmain).lastchord,2), col=0
endif


if keyword_set(stop) then stop
end
