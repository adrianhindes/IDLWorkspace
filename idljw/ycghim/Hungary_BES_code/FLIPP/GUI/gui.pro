; pickfiledialogban cancelre kattintunk, akkor ne írja ki, hogy betöltöttük.
; OK plot_noise
; windowson tesztelni
; .dat save and load - belerakni az új állapotokat.










pro TimeSelectPro
@gui_common.pro

DisableEnableWidgets, /disable

AddMessage2LogString, "Starting select_time procedure..."

if (Settings.TickTimeAutoChopper eq 1) then begin
 AddMessage2LogString, "Please, click at the beginning and at the end of the time interval with the left mouse button"
 wait, 1
 ; Original message:
 ; Click at the beginning of the time interval to process with the LEFT mouse button.
 ; Click at end of the time interval to process with the LEFT mouse button.
end
if (Settings.TickTimeAutoChopper eq 0) then begin
 AddMessage2LogString, "Please, click at the beginning and at the end of each time interval with the left mouse button"
 AddMessage2LogString, "Click anywhere on the plot with the right mouse button, if you wish no more intervals."
 wait, 1
 ; Click at the beginning of the time interval 1 with the LEFT mouse button.
 ; Click the RIGHT mouse button IF you wish no more intervals.
end

select_time, Settings.ShotNumber, Settings.Channel1, datapath=Settings.DataPath, data_source=Settings.DataSource, $
inttime=25, auto_chopper=Settings.TickTimeAutoChopper, on_name=Settings.TimeFileNameONString, off_name=Settings.TimeFileNameOFFString, $
on_times=tmp1, off_times=tmp2, ERRORMESS=ErrorStr, /noquery

*Settings.TimeVectorON=tmp1

if (Settings.TickTimeAutoChopper eq 1) then begin
*Settings.TimeVectorOFF=tmp2
end

; print, *Settings.TimeVectorON
; AddMessage2LogString, strtrim(string(*Settings.TimeVectorON), 2)
; AddMessage2LogString, strtrim(string(*Settings.TimeVectorOFF), 2)

AddError2LogString, ErrorStr, "select_time procedure is ready."

DisableEnableWidgets, /enable

end










pro PlotSpectraCrossPhasePro
@gui_common.pro

DisableEnableWidgets, /disable

; pltmsg <-- plot message
pltmsg="Calculating and plotting "
if (Settings.AutoOrCross eq 0) then begin ; AUTO
  PlotCha=Settings.Channel1
  pltmsg=pltmsg+'auto'
end
if (Settings.AutoOrCross eq 1) then begin ; CROSS
  PlotCha=Settings.Channel2
  pltmsg=pltmsg+'cross'
end
if (Settings.PickSpectraCoh eq 0) then begin ; SPECTRA
  pltmsg=pltmsg+'spectra'
end
if (Settings.PickSpectraCoh eq 1) then begin ; COHERENCE
  pltmsg=pltmsg+'coherence'
end
  pltmsg=pltmsg+' and crossphase. This may take a few seconds. Please wait a moment!'

ShotNr=Settings.ShotNumber

if (Settings.PickTimeFileOffOn eq 1) then begin
TimeON=Settings.TimeFileNameONString
endif else begin
TimeON=Settings.TimeFileNameOFFString
endelse

Ref=Settings.Channel1
IntTime=Settings.SpectraIntTime*Settings.TickSpectraIntTime
YRange=Settings.TickSpectraYRange*Settings.SpectraYRange
XType=Settings.PickFreqXType
FType=Settings.PickFreqType
YType=Settings.PickSpectraYType

;AUTO OR CROSS
if (Settings.AutoOrCross eq 0) then begin ; AUTO
  PlotCha=Settings.Channel1
end
if (Settings.AutoOrCross eq 1) then begin ; CROSS
  PlotCha=Settings.Channel2
end

; SPECTRA OR COHERENCE 
Norm=Settings.PickSpectraCoh

; WINDOW
if (Settings.PickWindow eq 0) then begin ; NONE
    Hamming=0
    Hanning=0
end
if (Settings.PickWindow eq 1) then begin ;HAMMING
    Hamming=1
    Hanning=0
end
if (Settings.PickWindow eq 2) then begin ; HANNING
    Hamming=0
    Hanning=1
end

; Amik bonyolitjak a dolgokat...
Fres=Settings.FreqRes
Frange=Settings.FreqRange
FilterH=Settings.SpectraFilter(0)
FilterO=Settings.SpectraFilterOrder

; Last command string
lcmd='fluc_correlation, '
lcmd=lcmd + i2str(Settings.ShotNumber)
lcmd=lcmd + ', '
lcdm=lcmd + string(byte(39)) + TimeOn + string(byte(39))
lcmd=lcmd + ', '
lcmd=lcmd + 'ref='
lcmd=lcmd + string(byte(39)) + Settings.Channel1 + string(byte(39)) 
lcmd=lcmd + ', '
lcmd=lcmd + 'norm='
lcmd=lcmd + i2str(Settings.PickSpectraCoh)
lcmd=lcmd + ', /plot_spectra'
lcmd=lcmd + ', xtype=' + i2str(Settings.PickFreqXType) + ', ftype=' + i2str(Settings.PickFreqType) + ', ytype=' + i2str(Settings.PickSpectraYType)
if (Settings.AutoOrCross eq 1) then begin ; CROSS
  lcmd=lcmd + ', '
  lcmd=lcmd + 'plotcha='
  lcmd=lcmd + string(byte(39)) + Settings.Channel2 + string(byte(39))
end
if (Settings.TickFreqRes eq 1) then begin ;
  lcmd=lcmd + ', '
  lcmd=lcmd + 'fres='
  lcmd=lcmd + i2str(Settings.FreqRes)
end
if (Settings.TickSpectraIntTime eq 1) then begin
  lcmd=lcmd + ', '
  lcmd=lcmd + 'inttime='
  lcmd=lcmd + i2str(Settings.SpectraIntTime)
end
if (Settings.PickWindow eq 1) then begin ;HAMMING
  lcmd=lcmd + ', '
  lcmd=lcmd + 'hamming=1'
end
if (Settings.PickWindow eq 2) then begin ;HAMMING
  lcmd=lcmd + ', '
  lcmd=lcmd + 'hanning=1'
end
if (Settings.TickSpectraYRange eq 1) then begin
  lcmd=lcmd + ', '
  lcmd=lcmd + 'yrange=[' + strtrim(string(Settings.SpectraYRange(0)), 2) + ', ' + strtrim(string(Settings.SpectraYRange(1)), 2) + ']'
end
if (Settings.TickFreqRange eq 1) then begin
  lcmd=lcmd + ', '
  lcmd=lcmd + 'frange=[' + strtrim(string(Settings.FreqRange(0)), 2) + ', ' + strtrim(string(Settings.FreqRange(1)), 2) + ']'
end
if (Settings.TickSpectraFilter(0) eq 1) then begin
  lcmd=lcmd + ', '
  lcmd=lcmd + 'filter_high=' + strtrim(string(Settings.SpectraFilter(0)), 2)
end
if (Settings.TickSpectraFilter(1) eq 1) then begin
  lcmd=lcmd + ', '
  lcmd=lcmd + 'filter_low=' + strtrim(string(Settings.SpectraFilter(1)), 2)
end
if (Settings.TickSpectraFilterOrder eq 1) then begin
  lcmd=lcmd + ', '
  lcmd=lcmd + 'filter_order=' + strtrim(string(Settings.SpectraFilterOrder), 2)
end
lcmd=lcmd + ', ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase'

AddMessage2LogString, lcmd
AddMessage2LogString, pltmsg

;0000
if ((Settings.TickFreqRes eq 0) and (Settings.TickFreqRange eq 0) and (Settings.TickSpectraFilter(0) eq 0) and (Settings.TickSpectraFilterOrder eq 0)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_spectra, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning, xtype=XType, ytype=YType, ftype=FType, ERRORMESS=ErrorStr, $
  outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;1000
if ((Settings.TickFreqRes eq 1) and (Settings.TickFreqRange eq 0) and (Settings.TickSpectraFilter(0) eq 0) and (Settings.TickSpectraFilterOrder eq 0)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_spectra, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, fres=FRes, $
  ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;0100
if ((Settings.TickFreqRes eq 0) and (Settings.TickFreqRange eq 1) and (Settings.TickSpectraFilter(0) eq 0) and (Settings.TickSpectraFilterOrder eq 0)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_spectra, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, fres=FRes, $
  frange=FRange, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, $
  outphase=outphase
end
;1100
if ((Settings.TickFreqRes eq 1) and (Settings.TickFreqRange eq 1) and (Settings.TickSpectraFilter(0) eq 0) and (Settings.TickSpectraFilterOrder eq 0)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_spectra, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, frange=FRange, $
  ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;0001
if ((Settings.TickFreqRes eq 0) and (Settings.TickFreqRange eq 0) and (Settings.TickSpectraFilter(0) eq 0) and (Settings.TickSpectraFilterOrder eq 1)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_spectra, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, filter_order=FilterO, $
  ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;0101
if ((Settings.TickFreqRes eq 0) and (Settings.TickFreqRange eq 1) and (Settings.TickSpectraFilter(0) eq 0) and (Settings.TickSpectraFilterOrder eq 1)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_spectra, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, frange=FRange, $
  filter_order=FilterO, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, $
  outphase=outphase
end
;1101
if ((Settings.TickFreqRes eq 1) and (Settings.TickFreqRange eq 1) and (Settings.TickSpectraFilter(0) eq 0) and (Settings.TickSpectraFilterOrder eq 1)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_spectra, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, fres=FRes, $
  frange=FRange, filter_order=FilterO, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, $
  outspectrum=outspectrum, outphase=outphase
end
;0010
if ((Settings.TickFreqRes eq 0) and (Settings.TickFreqRange eq 0) and (Settings.TickSpectraFilter(0) eq 1) and (Settings.TickSpectraFilterOrder eq 0)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource,  ref=Ref, plotcha=PlotCha, /plot_spectra, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, filter_high=FilterH, $
  ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;1010
if ((Settings.TickFreqRes eq 1) and (Settings.TickFreqRange eq 0) and (Settings.TickSpectraFilter(0) eq 1) and (Settings.TickSpectraFilterOrder eq 0)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_spectra, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, fres=FRes, $
  filter_high=FilterH, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, $
  outphase=outphase
end
;0110
if ((Settings.TickFreqRes eq 0) and (Settings.TickFreqRange eq 1) and (Settings.TickSpectraFilter(0) eq 1) and (Settings.TickSpectraFilterOrder eq 0)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_spectra, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, frange=FRange, $
  filter_high=FilterH, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, $
  outphase=outphase
end
;1110
if ((Settings.TickFreqRes eq 1) and (Settings.TickFreqRange eq 1) and (Settings.TickSpectraFilter(0) eq 1) and (Settings.TickSpectraFilterOrder eq 0)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_spectra, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, fres=FRes, $
  frange=FRange, filter_high=FilterH, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, $
  outspectrum=outspectrum, outphase=outphase
end
;1001=9
if ((Settings.TickFreqRes eq 1) and (Settings.TickFreqRange eq 0) and (Settings.TickSpectraFilter(0) eq 0) and (Settings.TickSpectraFilterOrder eq 1)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_spectra, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, fres=FRes, $
  filter_order=FilterO, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, $
  outphase=outphase
end
;0011
if ((Settings.TickFreqRes eq 0) and (Settings.TickFreqRange eq 0) and (Settings.TickSpectraFilter(0) eq 1) and (Settings.TickSpectraFilterOrder eq 1)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_spectra, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, filter_high=FilterH, $
  filter_order=FilterO, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, $
  outphase=outphase
end
;1011
if ((Settings.TickFreqRes eq 1) and (Settings.TickFreqRange eq 0) and (Settings.TickSpectraFilter(0) eq 1) and (Settings.TickSpectraFilterOrder eq 1)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_spectra, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, fres=FRes, $
  filter_high=FilterH, filter_order=FilterO, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, $
  outspectrum=outspectrum, outphase=outphase
end
;0111
if ((Settings.TickFreqRes eq 0) and (Settings.TickFreqRange eq 1) and (Settings.TickSpectraFilter(0) eq 1) and (Settings.TickSpectraFilterOrder eq 1)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_spectra, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, frange=FRange, $
  filter_high=FilterH, filter_order=FilterO, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, $
  outspectrum=outspectrum, outphase=outphase
end
;1111
if ((Settings.TickFreqRes eq 1) and (Settings.TickFreqRange eq 1) and (Settings.TickSpectraFilter(0) eq 1) and (Settings.TickSpectraFilterOrder eq 1)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_spectra, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, fres=FRes, $
  frange=FRange, filter_high=FilterH, filter_order=FilterO, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, $
  outpower=outpower, outspectrum=outspectrum, outphase=outphase
end

*Settings.outTau=outtime
*Settings.outCorr=outcorr
*Settings.outFreqScale=outfscale
*Settings.outPower=outpower
*Settings.outSpectrum=outspectrum
*Settings.outPhase=outphase

AddError2LogString, ErrorStr, "Plot is ready."
; SpectraCrossPhase
Settings.FlagLastPlot=4

DisableEnableWidgets, /enable

end











pro PlotSpectraPro
@gui_common.pro

DisableEnableWidgets, /disable

; pltmsg <-- plot message
pltmsg="Calculating and plotting "
if (Settings.AutoOrCross eq 0) then begin ; AUTO
  PlotCha=Settings.Channel1
  pltmsg=pltmsg+'auto'
end
if (Settings.AutoOrCross eq 1) then begin ; CROSS
  PlotCha=Settings.Channel2
  pltmsg=pltmsg+'cross'
end
if (Settings.PickSpectraCoh eq 0) then begin ; SPECTRA
  pltmsg=pltmsg+'spectra.'
end
if (Settings.PickSpectraCoh eq 1) then begin ; Coherence
  pltmsg=pltmsg+'coherence.'
end
  pltmsg=pltmsg+' This may take a few seconds. Please wait a moment!'

ShotNr=Settings.ShotNumber
Ref=Settings.Channel1
Norm=Settings.PickSpectraCoh
IntTime=Settings.SpectraIntTime*Settings.TickSpectraIntTime
YRange=Settings.TickSpectraYRange*Settings.SpectraYRange
;TimeON=Settings.TimeFileNameONString
if (Settings.PickTimeFileOffOn eq 1) then begin
TimeON=Settings.TimeFileNameONString
endif else begin
TimeON=Settings.TimeFileNameOFFString
endelse
XType=Settings.PickFreqXType
FType=Settings.PickFreqType
YType=Settings.PickSpectraYType

;  , plot_noiselevel=NoiseLevel
if (Settings.PickSpectraCoh eq 0) then begin
 NoiseLevel=0
end
if (Settings.PickSpectraCoh eq 1) then begin
 NoiseLevel=Settings.TickSpectraNoiseLevel
end




; Auto or cross
if (Settings.AutoOrCross eq 0) then begin ; AUTO
  PlotCha=Settings.Channel1
end
if (Settings.AutoOrCross eq 1) then begin ; CROSS
  PlotCha=Settings.Channel2
end

; window
if (Settings.PickWindow eq 0) then begin ; NONE
    Hamming=0
    Hanning=0
end
if (Settings.PickWindow eq 1) then begin ; HAMMING
    Hamming=1
    Hanning=0
end
if (Settings.PickWindow eq 2) then begin ; HANNING
    Hamming=0
    Hanning=1
end

; command
lcmd='fluc_correlation, '
lcmd=lcmd + i2str(Settings.ShotNumber)
lcmd=lcmd + ', '
lcdm=lcmd + string(byte(39)) + TimeOn + string(byte(39))
lcmd=lcmd + ', '
lcmd=lcmd + 'ref='
lcmd=lcmd + string(byte(39)) + Settings.Channel1 + string(byte(39))
lcmd=lcmd + ', '
lcmd=lcmd + 'norm='
lcmd=lcmd + i2str(Settings.PickSpectraCoh)
lcmd=lcmd + ', /plot_power'
lcmd=lcmd + ', xtype=' + i2str(Settings.PickFreqXType) + ', ftype=' + i2str(Settings.PickFreqType) + ', ytype=' + i2str(Settings.PickSpectraYType)
if (Settings.AutoOrCross eq 1) then begin ; CROSS
  lcmd=lcmd + ', '
  lcmd=lcmd + 'plotcha='
  lcmd=lcmd + string(byte(39)) + Settings.Channel2 + string(byte(39))
end
if (Settings.TickFreqRes eq 1) then begin ;
  lcmd=lcmd + ', '
  lcmd=lcmd + 'fres='
  lcmd=lcmd + i2str(Settings.FreqRes)
end
if (Settings.TickSpectraIntTime eq 1) then begin
  lcmd=lcmd + ', '
  lcmd=lcmd + 'inttime='
  lcmd=lcmd + i2str(Settings.SpectraIntTime)
end
if (Settings.PickWindow eq 1) then begin ;HAMMING
  lcmd=lcmd + ', '
  lcmd=lcmd + 'hamming=1'
end
if (Settings.PickWindow eq 2) then begin ;HAMMING
  lcmd=lcmd + ', '
  lcmd=lcmd + 'hanning=1'
end
if (Settings.TickSpectraYRange eq 1) then begin
  lcmd=lcmd + ', '
  lcmd=lcmd + 'yrange=[' + strtrim(string(Settings.SpectraYRange(0)), 2) + ', ' + strtrim(string(Settings.SpectraYRange(1)), 2) + ']'
end
if (Settings.TickFreqRange eq 1) then begin
  lcmd=lcmd + ', '
  lcmd=lcmd + 'frange=[' + strtrim(string(Settings.FreqRange(0)), 2) + ', ' + strtrim(string(Settings.FreqRange(1)), 2) + ']'
end
if (Settings.TickSpectraFilter(0) eq 1) then begin
  lcmd=lcmd + ', '
  lcmd=lcmd + 'filter_high=' + strtrim(string(Settings.SpectraFilter(0)), 2)
end
if (Settings.TickSpectraFilter(1) eq 1) then begin
  lcmd=lcmd + ', '
  lcmd=lcmd + 'filter_low=' + strtrim(string(Settings.SpectraFilter(1)), 2)
end
if (Settings.TickSpectraFilterOrder eq 1) then begin
  lcmd=lcmd + ', '
  lcmd=lcmd + 'filter_order=' + strtrim(string(Settings.SpectraFilterOrder), 2)
end
lcmd=lcmd + ', ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase'

AddMessage2LogString, lcmd
AddMessage2LogString, pltmsg

; Amik bonyolitjak a dolgokat...
Fres=Settings.FreqRes
Frange=Settings.FreqRange
FilterH=Settings.SpectraFilter(0)
FilterO=Settings.SpectraFilterOrder

;0000=0
if ((Settings.TickFreqRes eq 0) and (Settings.TickFreqRange eq 0) and (Settings.TickSpectraFilter(0) eq 0) and (Settings.TickSpectraFilterOrder eq 0)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_power, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, ERRORMESS=ErrorStr, $
  outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase, plot_noiselevel=NoiseLevel
end
;0001=1
if ((Settings.TickFreqRes eq 0) and (Settings.TickFreqRange eq 0) and (Settings.TickSpectraFilter(0) eq 0) and (Settings.TickSpectraFilterOrder eq 1)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_power, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, filter_order=FilterO, $
  ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase, plot_noiselevel=NoiseLevel
end
;0010=2
if ((Settings.TickFreqRes eq 0) and (Settings.TickFreqRange eq 0) and (Settings.TickSpectraFilter(0) eq 1) and (Settings.TickSpectraFilterOrder eq 0)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_power, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, filter_high=FilterH, $
  ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase, plot_noiselevel=NoiseLevel
end
;0011=3
if ((Settings.TickFreqRes eq 0) and (Settings.TickFreqRange eq 0) and (Settings.TickSpectraFilter(0) eq 1) and (Settings.TickSpectraFilterOrder eq 1)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_power, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, filter_high=FilterH, $
  filter_order=FilterO, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, $
  outphase=outphase, plot_noiselevel=NoiseLevel
end
;0100=4
if ((Settings.TickFreqRes eq 0) and (Settings.TickFreqRange eq 1) and (Settings.TickSpectraFilter(0) eq 0) and (Settings.TickSpectraFilterOrder eq 0)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_power, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, fres=FRes, $
  frange=FRange, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, $
  outphase=outphase, plot_noiselevel=NoiseLevel
end
;0101=5
if ((Settings.TickFreqRes eq 0) and (Settings.TickFreqRange eq 1) and (Settings.TickSpectraFilter(0) eq 0) and (Settings.TickSpectraFilterOrder eq 1)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_power, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, frange=FRange, $
  filter_order=FilterO, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, $
  outphase=outphase, plot_noiselevel=NoiseLevel
end
;0110=6
if ((Settings.TickFreqRes eq 0) and (Settings.TickFreqRange eq 1) and (Settings.TickSpectraFilter(0) eq 1) and (Settings.TickSpectraFilterOrder eq 0)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_power, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, frange=FRange, $
  filter_high=FilterH, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, $
  outphase=outphase, plot_noiselevel=NoiseLevel
end
;0111=7
if ((Settings.TickFreqRes eq 0) and (Settings.TickFreqRange eq 1) and (Settings.TickSpectraFilter(0) eq 1) and (Settings.TickSpectraFilterOrder eq 1)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_power, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, frange=FRange, $
  filter_high=FilterH, filter_order=FilterO, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, $
  outspectrum=outspectrum, outphase=outphase, plot_noiselevel=NoiseLevel
end
;1000=8
if ((Settings.TickFreqRes eq 1) and (Settings.TickFreqRange eq 0) and (Settings.TickSpectraFilter(0) eq 0) and (Settings.TickSpectraFilterOrder eq 0)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_power, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, fres=FRes, $
  ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase, plot_noiselevel=NoiseLevel
end
;1001=9
if ((Settings.TickFreqRes eq 1) and (Settings.TickFreqRange eq 0) and (Settings.TickSpectraFilter(0) eq 0) and (Settings.TickSpectraFilterOrder eq 1)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_power, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, fres=FRes, $
  filter_order=FilterO, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, $
  outphase=outphase, plot_noiselevel=NoiseLevel
end
;1010=10
if ((Settings.TickFreqRes eq 1) and (Settings.TickFreqRange eq 0) and (Settings.TickSpectraFilter(0) eq 1) and (Settings.TickSpectraFilterOrder eq 0)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_power, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, fres=FRes, $
  filter_high=FilterH, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, $
  outphase=outphase, plot_noiselevel=NoiseLevel
end
;1011=11
if ((Settings.TickFreqRes eq 1) and (Settings.TickFreqRange eq 0) and (Settings.TickSpectraFilter(0) eq 1) and (Settings.TickSpectraFilterOrder eq 1)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_power, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, fres=FRes, $
  filter_high=FilterH, filter_order=FilterO, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, $
  outspectrum=outspectrum, outphase=outphase, plot_noiselevel=NoiseLevel
end
;1100=12
if ((Settings.TickFreqRes eq 1) and (Settings.TickFreqRange eq 1) and (Settings.TickSpectraFilter(0) eq 0) and (Settings.TickSpectraFilterOrder eq 0)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_power, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, frange=FRange, $
  ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase, plot_noiselevel=NoiseLevel
end
;1101=13
if ((Settings.TickFreqRes eq 1) and (Settings.TickFreqRange eq 1) and (Settings.TickSpectraFilter(0) eq 0) and (Settings.TickSpectraFilterOrder eq 1)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_power, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, fres=FRes, $
  frange=FRange, filter_order=FilterO, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, $
  outspectrum=outspectrum, outphase=outphase, plot_noiselevel=NoiseLevel
end
;1110=14
if ((Settings.TickFreqRes eq 1) and (Settings.TickFreqRange eq 1) and (Settings.TickSpectraFilter(0) eq 1) and (Settings.TickSpectraFilterOrder eq 0)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_power, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, fres=FRes, $
  frange=FRange, filter_high=FilterH, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, $
  outspectrum=outspectrum, outphase=outphase, plot_noiselevel=NoiseLevel
end
;1111=15
if ((Settings.TickFreqRes eq 1) and (Settings.TickFreqRange eq 1) and (Settings.TickSpectraFilter(0) eq 1) and (Settings.TickSpectraFilterOrder eq 1)) then begin
  fluc_correlation, ShotNr, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Ref, plotcha=PlotCha, /plot_power, $
  yrange=YRange, inttime=IntTime, norm=Norm, hamming=Hamming, hanning=Hanning,  xtype=XType, ytype=YType, ftype=FType, fres=FRes, $
  frange=FRange, filter_high=FilterH, filter_order=FilterO, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, $
  outpower=outpower, outspectrum=outspectrum, outphase=outphase, plot_noiselevel=NoiseLevel
end

*Settings.outTau=outtime
*Settings.outCorr=outcorr
*Settings.outFreqScale=outfscale
*Settings.outPower=outpower
*Settings.outSpectrum=outspectrum
*Settings.outPhase=outphase

AddError2LogString, ErrorStr, "Plot is ready."
Settings.FlagLastPlot=3

DisableEnableWidgets, /enable

end










pro PlotCorrPro
@gui_common.pro

DisableEnableWidgets, /disable

; pltmsg <-- plot message
pltmsg="Calculating and plotting "
if (Settings.AutoOrCross eq 0) then begin ; AUTO
  PlotCha=Settings.Channel1
  pltmsg=pltmsg+'auto'
end
if (Settings.AutoOrCross eq 1) then begin ; CROSS
  PlotCha=Settings.Channel2
  pltmsg=pltmsg+'cross'
end
if (Settings.CovCorr eq 0) then begin ; CROSS
  pltmsg=pltmsg+'covariance.'
end
if (Settings.CovCorr eq 1) then begin ; CROSS
  pltmsg=pltmsg+'correlation.'
end
  pltmsg=pltmsg+' This may take a few seconds. Please wait a moment!'

if (Settings.PickWindow eq 0) then begin ; NONE
    Hamming=0
    Hanning=0
end
if (Settings.PickWindow eq 1) then begin ;HAMMING
    Hamming=1
    Hanning=0
end
if (Settings.PickWindow eq 2) then begin ; HANNING
    Hamming=0
    Hanning=1
end

TauRes=Settings.TauRes*Settings.TickTauRes
IntTime=Settings.CorrIntTime*Settings.TickCorrIntTime
if (Settings.PickTimeFileOffOn eq 1) then begin
TimeON=Settings.TimeFileNameONString
endif else begin
TimeON=Settings.TimeFileNameOFFString
endelse


; command
lcmd='fluc_correlation, '
lcmd=lcmd + i2str(Settings.ShotNumber)
lcmd=lcmd + ', '
lcdm=lcmd + string(byte(39)) + TimeOn + string(byte(39))
lcmd=lcmd + ', '
lcmd=lcmd + 'ref='
lcmd=lcmd + string(byte(39)) + Settings.Channel1 + string(byte(39))
lcmd=lcmd + ', '
lcmd=lcmd + 'norm='
lcmd=lcmd + i2str(Settings.CovCorr)
lcmd=lcmd + ', /plot_corr'
if (Settings.AutoOrCross eq 1) then begin ; CROSS
  lcmd=lcmd + ', '
  lcmd=lcmd + 'plotcha='
  lcmd=lcmd + string(byte(39)) + Settings.Channel2 + string(byte(39))
end
if (Settings.TickTauRes eq 1) then begin ; CROSS
  lcmd=lcmd + ', '
  lcmd=lcmd + 'taures='
  lcmd=lcmd + i2str(Settings.TauRes)
end
if (Settings.TickCorrIntTime eq 1) then begin ; CROSS
  lcmd=lcmd + ', '
  lcmd=lcmd + 'inttime='
  lcmd=lcmd + i2str(Settings.CorrIntTime)
end
if (Settings.PickWindow eq 1) then begin ;HAMMING
  lcmd=lcmd + ', '
  lcmd=lcmd + 'hamming=1'
end
if (Settings.PickWindow eq 2) then begin ;HAMMING
  lcmd=lcmd + ', '
  lcmd=lcmd + 'hanning=1'
end
if (Settings.TickCorrYRange eq 1) then begin
  lcmd=lcmd + ', '
  lcmd=lcmd + 'yrange=[' + strtrim(string(Settings.CorrYRange(0)), 2) + ', ' + strtrim(string(Settings.CorrYRange(1)), 2) + ']'
end
if (Settings.TickTauRange eq 1) then begin
  lcmd=lcmd + ', '
  lcmd=lcmd + 'taurange=[' + strtrim(string(Settings.TauRange(0)), 2) + ', ' + strtrim(string(Settings.TauRange(1)), 2) + ']'
end
if (Settings.TickCorrFilter(0) eq 1) then begin
  lcmd=lcmd + ', '
  lcmd=lcmd + 'filter_high=' + strtrim(string(Settings.CorrFilter(0)), 2)
end
if (Settings.TickCorrFilter(1) eq 1) then begin
  lcmd=lcmd + ', '
  lcmd=lcmd + 'filter_low=' + strtrim(string(Settings.CorrFilter(1)), 2)
end
if (Settings.TickCorrFilterOrder eq 1) then begin
  lcmd=lcmd + ', '
  lcmd=lcmd + 'filter_order=' + strtrim(string(Settings.CorrFilterOrder), 2)
end
lcmd=lcmd + ', ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase'

AddMessage2LogString, lcmd
AddMessage2LogString, pltmsg

; strtrim(string(Settings.SpectraIntTime), 2)
; /plot_corr ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase

;00000
if ((Settings.TickCorrYRange eq 0) and (Settings.TickTauRange eq 0) and (Settings.TickCorrFilter(0) eq 0) and (Settings.TickCorrFilter(1) eq 0) and (Settings.TickCorrFilterOrder eq 0)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, ERRORMESS=ErrorStr, $
 outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;00001
if ((Settings.TickCorrYRange eq 0) and (Settings.TickTauRange eq 0) and (Settings.TickCorrFilter(0) eq 0) and (Settings.TickCorrFilter(1) eq 0) and (Settings.TickCorrFilterOrder eq 1)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 filter_order=Settings.CorrFilterOrder, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, $
 outspectrum=outspectrum, outphase=outphase
end
;00010
if ((Settings.TickCorrYRange eq 0) and (Settings.TickTauRange eq 0) and (Settings.TickCorrFilter(0) eq 0) and (Settings.TickCorrFilter(1) eq 1) and (Settings.TickCorrFilterOrder eq 0)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 filter_low=Settings.CorrFilter(1), ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, $
 outspectrum=outspectrum, outphase=outphase
end
;00011
if ((Settings.TickCorrYRange eq 0) and (Settings.TickTauRange eq 0) and (Settings.TickCorrFilter(0) eq 0) and (Settings.TickCorrFilter(1) eq 1) and (Settings.TickCorrFilterOrder eq 1)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 filter_low=Settings.CorrFilter(1), filter_order=Settings.CorrFilterOrder, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, $
 outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;00100
if ((Settings.TickCorrYRange eq 0) and (Settings.TickTauRange eq 0) and (Settings.TickCorrFilter(0) eq 1) and (Settings.TickCorrFilter(1) eq 0) and (Settings.TickCorrFilterOrder eq 0)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 filter_high=Settings.CorrFilter(0), ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, $
 outspectrum=outspectrum, outphase=outphase
end
;00101
if ((Settings.TickCorrYRange eq 0) and (Settings.TickTauRange eq 0) and (Settings.TickCorrFilter(0) eq 1) and (Settings.TickCorrFilter(1) eq 0) and (Settings.TickCorrFilterOrder eq 1)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 filter_high=Settings.CorrFilter(0), filter_order=Settings.CorrFilterOrder, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, $
 outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;00110
if ((Settings.TickCorrYRange eq 0) and (Settings.TickTauRange eq 0) and (Settings.TickCorrFilter(0) eq 1) and (Settings.TickCorrFilter(1) eq 1) and (Settings.TickCorrFilterOrder eq 0)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 filter_high=Settings.CorrFilter(0), filter_low=Settings.CorrFilter(1), ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, $
 outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;00111
if ((Settings.TickCorrYRange eq 0) and (Settings.TickTauRange eq 0) and (Settings.TickCorrFilter(0) eq 1) and (Settings.TickCorrFilter(1) eq 1) and (Settings.TickCorrFilterOrder eq 1)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 filter_high=Settings.CorrFilter(0), filter_low=Settings.CorrFilter(1), filter_order=Settings.CorrFilterOrder, ERRORMESS=ErrorStr, $
 outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;01000
if ((Settings.TickCorrYRange eq 0) and (Settings.TickTauRange eq 1) and (Settings.TickCorrFilter(0) eq 0) and (Settings.TickCorrFilter(1) eq 0) and (Settings.TickCorrFilterOrder eq 0)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 taurange=Settings.TauRange, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, $
 outspectrum=outspectrum, outphase=outphase
end
;01001
if ((Settings.TickCorrYRange eq 0) and (Settings.TickTauRange eq 1) and (Settings.TickCorrFilter(0) eq 0) and (Settings.TickCorrFilter(1) eq 0) and (Settings.TickCorrFilterOrder eq 1)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 taurange=Settings.TauRange, filter_order=Settings.CorrFilterOrder, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, $
 outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;01010
if ((Settings.TickCorrYRange eq 0) and (Settings.TickTauRange eq 1) and (Settings.TickCorrFilter(0) eq 0) and (Settings.TickCorrFilter(1) eq 1) and (Settings.TickCorrFilterOrder eq 0)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 taurange=Settings.TauRange, filter_low=Settings.CorrFilter(1), ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, $
 outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;01011
if ((Settings.TickCorrYRange eq 0) and (Settings.TickTauRange eq 1) and (Settings.TickCorrFilter(0) eq 0) and (Settings.TickCorrFilter(1) eq 1) and (Settings.TickCorrFilterOrder eq 1)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 taurange=Settings.TauRange, filter_low=Settings.CorrFilter(1), filter_order=Settings.CorrFilterOrder, ERRORMESS=ErrorStr, $
 outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;01100
if ((Settings.TickCorrYRange eq 0) and (Settings.TickTauRange eq 1) and (Settings.TickCorrFilter(0) eq 1) and (Settings.TickCorrFilter(1) eq 0) and (Settings.TickCorrFilterOrder eq 0)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 taurange=Settings.TauRange, filter_high=Settings.CorrFilter(0), ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, $
 outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;01101
if ((Settings.TickCorrYRange eq 0) and (Settings.TickTauRange eq 1) and (Settings.TickCorrFilter(0) eq 1) and (Settings.TickCorrFilter(1) eq 0) and (Settings.TickCorrFilterOrder eq 1)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 taurange=Settings.TauRange, filter_high=Settings.CorrFilter(0), filter_order=Settings.CorrFilterOrder, ERRORMESS=ErrorStr, outtime=outtime,$
 outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;01110
if ((Settings.TickCorrYRange eq 0) and (Settings.TickTauRange eq 1) and (Settings.TickCorrFilter(0) eq 1) and (Settings.TickCorrFilter(1) eq 1) and (Settings.TickCorrFilterOrder eq 0)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 taurange=Settings.TauRange, filter_high=Settings.CorrFilter(0), filter_low=Settings.CorrFilter(1), ERRORMESS=ErrorStr, outtime=outtime,$
 outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;01111
if ((Settings.TickCorrYRange eq 0) and (Settings.TickTauRange eq 1) and (Settings.TickCorrFilter(0) eq 1) and (Settings.TickCorrFilter(1) eq 1) and (Settings.TickCorrFilterOrder eq 1)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 taurange=Settings.TauRange, filter_high=Settings.CorrFilter(0), filter_low=Settings.CorrFilter(1), filter_order=Settings.CorrFilterOrder, $
 ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;10000
if ((Settings.TickCorrYRange eq 1) and (Settings.TickTauRange eq 0) and (Settings.TickCorrFilter(0) eq 0) and (Settings.TickCorrFilter(1) eq 0) and (Settings.TickCorrFilterOrder eq 0)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 yrange=Settings.CorrYRange, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, $
 outspectrum=outspectrum, outphase=outphase
end
;10001
if ((Settings.TickCorrYRange eq 1) and (Settings.TickTauRange eq 0) and (Settings.TickCorrFilter(0) eq 0) and (Settings.TickCorrFilter(1) eq 0) and (Settings.TickCorrFilterOrder eq 1)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 yrange=Settings.CorrYRange, filter_order=Settings.CorrFilterOrder, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, $
 outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;10010
if ((Settings.TickCorrYRange eq 1) and (Settings.TickTauRange eq 0) and (Settings.TickCorrFilter(0) eq 0) and (Settings.TickCorrFilter(1) eq 1) and (Settings.TickCorrFilterOrder eq 0)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 yrange=Settings.CorrYRange, filter_low=Settings.CorrFilter(1), ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, $
 outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;10011
if ((Settings.TickCorrYRange eq 1) and (Settings.TickTauRange eq 0) and (Settings.TickCorrFilter(0) eq 0) and (Settings.TickCorrFilter(1) eq 1) and (Settings.TickCorrFilterOrder eq 1)) then begin
 fluc_correlation, Settings.ShotNumber, datapath=Settings.DataPath, data_source=Settings.DataSource, TimeON, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 yrange=Settings.CorrYRange, filter_low=Settings.CorrFilter(1), filter_order=Settings.CorrFilterOrder, ERRORMESS=ErrorStr, $
 outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;10100
if ((Settings.TickCorrYRange eq 1) and (Settings.TickTauRange eq 0) and (Settings.TickCorrFilter(0) eq 1) and (Settings.TickCorrFilter(1) eq 0) and (Settings.TickCorrFilterOrder eq 0)) then begin
 fluc_correlation, Settings.ShotNumber, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 yrange=Settings.CorrYRange, filter_high=Settings.CorrFilter(0), ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, $
 outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;10101
if ((Settings.TickCorrYRange eq 1) and (Settings.TickTauRange eq 0) and (Settings.TickCorrFilter(0) eq 1) and (Settings.TickCorrFilter(1) eq 0) and (Settings.TickCorrFilterOrder eq 1)) then begin
 fluc_correlation, Settings.ShotNumber, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 yrange=Settings.CorrYRange, filter_high=Settings.CorrFilter(0), filter_order=Settings.CorrFilterOrder, ERRORMESS=ErrorStr, $
 outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;10110
if ((Settings.TickCorrYRange eq 1) and (Settings.TickTauRange eq 0) and (Settings.TickCorrFilter(0) eq 1) and (Settings.TickCorrFilter(1) eq 1) and (Settings.TickCorrFilterOrder eq 0)) then begin
 fluc_correlation, Settings.ShotNumber, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 yrange=Settings.CorrYRange, filter_high=Settings.CorrFilter(0), filter_low=Settings.CorrFilter(1), ERRORMESS=ErrorStr, $
 outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;10111
if ((Settings.TickCorrYRange eq 1) and (Settings.TickTauRange eq 0) and (Settings.TickCorrFilter(0) eq 1) and (Settings.TickCorrFilter(1) eq 1) and (Settings.TickCorrFilterOrder eq 0)) then begin
 fluc_correlation, Settings.ShotNumber, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 yrange=Settings.CorrYRange, filter_high=Settings.CorrFilter(0), filter_low=Settings.CorrFilter(1), ERRORMESS=ErrorStr, $
 outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;11000
if ((Settings.TickCorrYRange eq 1) and (Settings.TickTauRange eq 1) and (Settings.TickCorrFilter(0) eq 0) and (Settings.TickCorrFilter(1) eq 0) and (Settings.TickCorrFilterOrder eq 0)) then begin
 fluc_correlation, Settings.ShotNumber, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 yrange=Settings.CorrYRange, taurange=Settings.TauRange, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, $
 outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;11001
if ((Settings.TickCorrYRange eq 1) and (Settings.TickTauRange eq 1) and (Settings.TickCorrFilter(0) eq 0) and (Settings.TickCorrFilter(1) eq 0) and (Settings.TickCorrFilterOrder eq 1)) then begin
 fluc_correlation, Settings.ShotNumber, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 yrange=Settings.CorrYRange, taurange=Settings.TauRange, filter_order=Settings.CorrFilterOrder, ERRORMESS=ErrorStr, outtime=outtime, $
 outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;11010
if ((Settings.TickCorrYRange eq 1) and (Settings.TickTauRange eq 1) and (Settings.TickCorrFilter(0) eq 0) and (Settings.TickCorrFilter(1) eq 1) and (Settings.TickCorrFilterOrder eq 0)) then begin
 fluc_correlation, Settings.ShotNumber, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 yrange=Settings.CorrYRange, taurange=Settings.TauRange, filter_low=Settings.CorrFilter(1), ERRORMESS=ErrorStr, outtime=outtime, $
 outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;11011
if ((Settings.TickCorrYRange eq 1) and (Settings.TickTauRange eq 1) and (Settings.TickCorrFilter(0) eq 0) and (Settings.TickCorrFilter(1) eq 1) and (Settings.TickCorrFilterOrder eq 1)) then begin
 fluc_correlation, Settings.ShotNumber, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 yrange=Settings.CorrYRange, taurange=Settings.TauRange, filter_low=Settings.CorrFilter(1), filter_order=Settings.CorrFilterOrder, $
 ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;11100
if ((Settings.TickCorrYRange eq 1) and (Settings.TickTauRange eq 1) and (Settings.TickCorrFilter(0) eq 1) and (Settings.TickCorrFilter(1) eq 0) and (Settings.TickCorrFilterOrder eq 0)) then begin
 fluc_correlation, Settings.ShotNumber, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 yrange=Settings.CorrYRange, taurange=Settings.TauRange, filter_high=Settings.CorrFilter(0), ERRORMESS=ErrorStr, outtime=outtime, $
 outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;11101
if ((Settings.TickCorrYRange eq 1) and (Settings.TickTauRange eq 1) and (Settings.TickCorrFilter(0) eq 1) and (Settings.TickCorrFilter(1) eq 0) and (Settings.TickCorrFilterOrder eq 1)) then begin
 fluc_correlation, Settings.ShotNumber, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 yrange=Settings.CorrYRange, taurange=Settings.TauRange, filter_high=Settings.CorrFilter(0), filter_order=Settings.CorrFilterOrder, $
 ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;11110
if ((Settings.TickCorrYRange eq 1) and (Settings.TickTauRange eq 1) and (Settings.TickCorrFilter(0) eq 1) and (Settings.TickCorrFilter(1) eq 1) and (Settings.TickCorrFilterOrder eq 0)) then begin
 fluc_correlation, Settings.ShotNumber, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 yrange=Settings.CorrYRange, taurange=Settings.TauRange, filter_high=Settings.CorrFilter(0), filter_low=Settings.CorrFilter(1), $
 ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, outspectrum=outspectrum, outphase=outphase
end
;11111
if ((Settings.TickCorrYRange eq 1) and (Settings.TickTauRange eq 1) and (Settings.TickCorrFilter(0) eq 1) and (Settings.TickCorrFilter(1) eq 1) and (Settings.TickCorrFilterOrder eq 1)) then begin
 fluc_correlation, Settings.ShotNumber, TimeON, datapath=Settings.DataPath, data_source=Settings.DataSource, ref=Settings.Channel1, $
 plotcha=PlotCha, /plot_corr, taures=TauRes, inttime=IntTime, norm=Settings.CovCorr, hamming=Hamming, hanning=Hanning, $
 yrange=Settings.CorrYRange, taurange=Settings.TauRange, filter_high=Settings.CorrFilter(0), filter_low=Settings.CorrFilter(1), $
 filter_order=Settings.CorrFilterOrder, ERRORMESS=ErrorStr, outtime=outtime, outcorr=outcorr, outfscale=outfscale, outpower=outpower, $
 outspectrum=outspectrum, outphase=outphase
end

*Settings.outTau=outtime
*Settings.outCorr=outcorr
*Settings.outFreqScale=outfscale
*Settings.outPower=outpower
*Settings.outSpectrum=outspectrum
*Settings.outPhase=outphase

AddError2LogString, ErrorStr, "Plot is ready."
Settings.FlagLastPlot=2

DisableEnableWidgets, /enable

end





pro PlotRawSignalPro
@gui_common.pro
DisableEnableWidgets, /disable
AddMessage2LogString, "plot..."
YRange=Settings.YRange*Settings.TickYRange
NoErase=Settings.TickDontErase
Title=Settings.TitleString
if (Settings.TickTitle eq 0) then begin
  Title=0
end
YLabel=Settings.YLabelString
;PLOT RAW SIGNAL
if ((Settings.TickTimeRange eq 1) and (Settings.TickYLabel eq 1)) then begin
  show_rawsignal, Settings.ShotNumber, Settings.Channel1, datapath=Settings.DataPath, data_source=Settings.DataSource, $
  timerange=Settings.TimeRange, yrange=YRange, linestyle=Settings.LineStyle, charsize=Settings.CharSize, thick=Settings.LineThickness, $
  noerase=Settings.TickDontErase, title=Title, ytitle=YLabel, ERRORMESS=ErrorStr
end
if ((Settings.TickTimeRange eq 1) and (Settings.TickYLabel eq 0)) then begin
  show_rawsignal, Settings.ShotNumber, Settings.Channel1, datapath=Settings.DataPath, data_source=Settings.DataSource, $
  timerange=Settings.TimeRange, yrange=YRange, linestyle=Settings.LineStyle, charsize=Settings.CharSize, thick=Settings.LineThickness, $
  noerase=Settings.TickDontErase, title=Title, ERRORMESS=ErrorStr
end
if ((Settings.TickTimeRange eq 0) and (Settings.TickYLabel eq 1)) then begin
  show_rawsignal, Settings.ShotNumber, Settings.Channel1, datapath=Settings.DataPath, data_source=Settings.DataSource, yrange=YRange, $
  linestyle=Settings.LineStyle, charsize=Settings.CharSize, thick=Settings.LineThickness, noerase=Settings.TickDontErase, $
  title=Title, ytitle=YLabel, ERRORMESS=ErrorStr
end
if ((Settings.TickTimeRange eq 0) and (Settings.TickYLabel eq 0)) then begin
  show_rawsignal, Settings.ShotNumber, Settings.Channel1, datapath=Settings.DataPath, data_source=Settings.DataSource, yrange=YRange, $
  linestyle=Settings.LineStyle, charsize=Settings.CharSize, thick=Settings.LineThickness, noerase=Settings.TickDontErase, title=Title, $
  ERRORMESS=ErrorStr
end
AddError2LogString, ErrorStr, "Plot is ready."

;GET RAW DATA
if ((Settings.TickTimeRange eq 1)) then begin
  get_rawsignal, Settings.ShotNumber, Settings.Channel1, outtime, outdata, datapath=Settings.DataPath, data_source=Settings.DataSource, $
  timerange=Settings.TimeRange, errormess=ErrorStr
end
if ((Settings.TickTimeRange eq 0)) then begin
  get_rawsignal, Settings.ShotNumber, Settings.Channel1, outtime, outdata, datapath=Settings.DataPath, data_source=Settings.DataSource, $
  errormess=ErrorStr
end
AddError2LogString, ErrorStr, "Data saved"

*Settings.outRawTime=outtime
*Settings.outRawData=outdata

Settings.FlagLastPlot=1
DisableEnableWidgets, /enable
end





pro AddError2LogString, TNewErrorMessage, NoErrorMessage
@gui_common.pro 
  if (TNewErrorMessage ne '') then begin
    AddMessage2LogString, "ERROR: " + TNewErrorMessage
  end
  if (TNewErrorMessage eq '') then begin
    AddMessage2LogString, NoErrorMessage
  end
end





pro DisableEnableWidgets, disable=disable, enable=enable
@gui_common.pro 
  if (keyword_set(disable)) then begin
    widget_control, UpperWBase, sensitive=0
  end
  if (keyword_set(enable)) then begin
    widget_control, UpperWBase, sensitive=1
  end

end





pro AddMessage2LogString, TNewLogMessage
@gui_common.pro
  if (LogString eq [['']]) then begin
    LogString=TNewLogMessage
  endif else begin
    LogString=[[TNewLogMessage], LogString]
  endelse
  print, TNewLogMessage
  widget_control, LogWText, set_value=LogString
end





pro gui, config_file=config_file
@gui_common.pro
Settings={ $
  ConfigFileDAT:     'fluct_local_config.dat', $
  DataPath:	"", $ ; example: "/media/HDD/DATA/KSTAR"
  DataSource:    0L, $
  ShotNumber:    0L, $
  Channel1:      'BES-6', $
  Channel2:      'BES-7', $
  AutoOrCross:   1, $
  TickTimeFile:  1, $
  PickTimeFileOffOn: 1, $ 
  TickTimeAutoChopper: 1, $
  TimeFileNameONString: 'shotnron.time', $
  TimeFileNameOFFString: 'shotnroff.time', $
  TimeVectorON: ptr_new(0), $
  TimeVectorOFF: ptr_new(0), $
  TickTimeRange: 0, $
  TimeRange:     [0.1D,4.6D], $
  TickYRange:    0, $
  YRange:    [0.01D,0.575D], $
  TickTitle:     0, $
  TitleString:   'Title String', $
  TickYLabel:    0, $
  YLabelString:  'Y label String', $
  TickXLabel:    0, $
  XLabelString:  'X label String', $
  CharSize:      1, $
  LineThickness: 1, $
  LineStyle:     0, $ ; ['Solid', 'Dotted', 'Dashed', 'Dash-dot', 'Dash-Double dot', 'Long dashed'] 0 is for Solid
  TickDontErase:     0, $
  CovCorr:     0, $ ; Cov: 0, Corr: 1
  TickTauRange: 0, $
  TauRange:      [-30.0,30.0], $
  TickTauRes:   0, $
  TauRes:        1, $
  TickCorrYRange:   0, $
  CorrYRange:   [-1e-6,4.75e-6], $
  TickCorrIntTime:  0, $
  CorrIntTime: 2, $
  TickCorrCutLength: 0, $
  CorrCutLength: 0, $
  TickCorrFilter: [0,0], $
  CorrFilter:  [1e5,2e4], $
  TickCorrFilterOrder: 0, $
  CorrFilterOrder: 100.0, $
  PickWindow: 0, $
  PickSpectraCoh: 0, $
  TickFreqRes: 0, $
  FreqRes: 10.0, $
  PickFreqType: 1, $ ;ftype=0 lin, 1 log
  TickFreqRange: 0, $
  FreqRange: [200.0, 8e5], $
  PickFreqXType: 1, $ ; xtpye 0 lin, 1 log
  TickSpectraYRange: 0, $
  SpectraYRange: [1.4e-13,1.4e-09], $
  PickSpectraYType: 1, $ ; ytpe
  TickSpectraIntTime: 0, $
  SpectraIntTime: 20.0, $
  TickSpectraNoiseLevel: 0, $
  TickSpectraFilter: [0,0], $
  SpectraFilter:  [1e5,2e4], $
  TickSpectraFilterOrder: 0, $
  SpectraFilterOrder: 100, $
  SaveOutputString: 'Output.sav', $
  SaveJPGString: 'Plot.jpg', $
  SaveEPSString: 'Plot.eps', $
  FlagLastPlot: 0, $
  LastCommandString: "", $
  outRawTime: ptr_new(0), $
  outRawData: ptr_new(0), $
  outTau: ptr_new(0), $
  outCorr:  ptr_new(0), $
  outFreqScale:  ptr_new(0), $
  outPower:  ptr_new(0), $
  outSpectrum:  ptr_new(0), $
  outPhase:  ptr_new(0) $
}

default, config_file, 'fluct_local_config.dat'
Settings.ConfigFileDAT=config_file


if (((tmp = local_default('datapath', config_file=Settings.ConfigFileDAT, /silent)) ne '') and (Settings.DataPath eq "")) then begin
  Settings.DataPath=tmp
endif

if (((tmp = local_default('gui_shotnumber', config_file=Settings.ConfigFileDAT, /silent)) ne '') and (Settings.ShotNumber eq 0) ) then begin
  Settings.ShotNumber=long(tmp)
endif

if ((tmp = local_default('data_source', config_file=Settings.ConfigFileDAT, /silent)) ne '') then begin
  Settings.DataSource=fix(tmp)
endif

if (((tmp = local_default('taurange_start', config_file=Settings.ConfigFileDAT, /silent)) ne '') and (Settings.TauRange(0) eq 0)) then begin
  Settings.TauRange(0)=fix(tmp)
endif

if (((tmp = local_default('taurange_end', config_file=Settings.ConfigFileDAT, /silent)) ne '') and (Settings.TauRange(1) eq 0)) then begin
  Settings.TauRange(1)=fix(tmp)
endif





;MainWBase=widget_base(title='FLIPP GUI 0.91', /column, bitmap='H:\FLIPP_svn\gui_icon.ico')

MainWBase=widget_base(title='FLIPP GUI 0.91', /column)

UpperWBase=widget_base(MainWBase, frame=1, column=3)
CommonSettingsWBase=widget_base(UpperWBase, frame=1, /column)
CommonTitleWLabel=widget_label(CommonSettingsWBase, value='  Main  input  parameters  ', /sunken_frame)

DataPathWBase=widget_base(CommonSettingsWBase, /row)
DataPathWField=cw_field(DataPathWBase, value=Settings.DataPath, title='Data path:  ', xsize=26, /return_events)


DataSourceWBase=widget_base(CommonSettingsWBase, /row)
DataSourceWLabel=widget_label(DataSourceWBase, value='Data source: ')
get_rawsignal, data_names=DataSources
DataSourceWDroplist=widget_droplist(DataSourceWBase, value=DataSources)
widget_control, DataSourceWDroplist, set_droplist_select=Settings.DataSource
ShotNumberWBase=widget_base(CommonSettingsWBase, /column)
ShotNumberWField=cw_field(ShotNumberWBase, value=Settings.ShotNumber, title='Shot number:  #', /long, xsize=6, /return_events)
ChannelWBase=widget_base(CommonSettingsWBase, /column)
AutoOrCrossWPick=cw_bgroup(ChannelWBase, ['auto','cross'], set_value=Settings.AutoOrCross, column=2, /exclusive)
Channel1WField=cw_field(ChannelWBase, value=Settings.Channel1, title='Channel 1: ', xsize=12, /return_events)
Channel2WField=cw_field(ChannelWBase, value=Settings.Channel2, title='Channel 2: ', xsize=12, /return_events)
widget_control, Channel2WField, sensitive=Settings.AutoOrCross
TimeFileWBase=widget_base(CommonSettingsWBase, frame=1, /column)
TimeFileNeededWTick=cw_bgroup(TimeFileWBase, 'Time file', set_value=Settings.TickTimeFile, /nonexclusive)
TimeFileOffOnWPick=cw_bgroup(TimeFileWBase, ['off', 'on'], set_value=Settings.PickTimeFileOffOn, column=2, /exclusive)
Settings.TimeFileNameONString=i2str(Settings.ShotNumber)+'on.time'
Settings.TimeFileNameOFFString=i2str(Settings.ShotNumber)+'off.time'
TimeFileNameONWField=cw_field(TimeFileWBase, value=Settings.TimeFileNameONString, title="Beam-on time file: ", xsize=12, /return_events )
TimeFileNameOFFWField=cw_field(TimeFileWBase, value=Settings.TimeFileNameOFFString, title="Beam-off time file: ", xsize=12, /return_events )
TimeAutoChopperWTick=cw_bgroup(TimeFileWBase, 'auto chopper', set_value=Settings.TickTimeAutoChopper, /nonexclusive)
TimeSelectProWButton=widget_button(TimeFileWBase, value='Select time', tooltip='Add tooltip LATER!')
widget_control, TimeFileOffOnWPick, sensitive=Settings.TickTimeFile
widget_control, TimeFileNameONWField, sensitive=Settings.TickTimeFile
widget_control, TimeFileNameOFFWField, sensitive=Settings.TickTimeFile
widget_control, TimeAutoChopperWTick, sensitive=Settings.TickTimeFile
widget_control, TimeSelectProWButton, sensitive=Settings.TickTimeFile

SignalWBase=widget_base(UpperWBase, frame=1)
SignalWTabs=widget_tab(SignalWBase)

SignalVisualizationWTab=widget_base(SignalWTabs, title='Signal visualization', /column)
TimeRangeWBase=widget_base(SignalVisualizationWTab, /row, frame=0)
TimeRangeWTick=cw_bgroup(TimeRangeWBase, 'X axis', set_value=Settings.TickTimeRange, /nonexclusive)
TimeRangeAWField=cw_field(TimeRangeWBase,value=Settings.TimeRange(0), title=' from: ', xsize=8, /return_events)
TimeRangeBWField=cw_field(TimeRangeWBase,value=Settings.TimeRange(1), title=' to ', xsize=8, /return_events)
TimeRangeCursorWButton=widget_button(TimeRangeWBase, value='click!', tooltip='To set X ranges using cursor, click on the points which you would like to set the X range to.')
widget_control, TimeRangeAWField , sensitive=Settings.TickTimeRange
widget_control, TimeRangeBWField , sensitive=Settings.TickTimeRange
; widget_control, TimeRangeCursorWButton , sensitive=Settings.TickTimeRange

YRangeWBase=widget_base(SignalVisualizationWTab, /row, frame=0)
YRangeWTick=cw_bgroup(YRangeWBase, 'Y axis', set_value=Settings.TickYRange, /nonexclusive)
YRangeAWField=cw_field(YRangeWBase,value=Settings.YRange(0), title=' from: ', xsize=8, /return_events)
YRangeBWField=cw_field(YRangeWBase,value=Settings.YRange(1), title=' to ', xsize=8, /return_events)
YRangeCursorWButton=widget_button(YRangeWBase, value='click!', scr_xsize=50, tooltip='To set time ranges using cursor, click on the points which you would like to set y range to.')
widget_control, YRangeAWField , sensitive=Settings.TickYRange
widget_control, YRangeBWField , sensitive=Settings.TickYRange
; widget_control, YRangeCursorWButton , sensitive=Settings.TickYRange

LabelsWBase=widget_base(SignalVisualizationWTab, /column)
TitleWBase=widget_base(LabelsWBase, /row, frame=0)
TitleWTick=cw_bgroup(TitleWBase, 'Title', set_value=Settings.TickTitle, /nonexclusive) 
TitleWField=cw_field(TitleWBase, value=Settings.TitleString, title='', xsize=25, /return_events)
widget_control, TitleWField, sensitive=Settings.TickTitle
YLabelWBase=widget_base(LabelsWBase, /row, frame=0)
YLabelWTick=cw_bgroup(YLabelWBase, 'Y label', set_value=Settings.TickYLabel, /nonexclusive) 
YLabelWField=cw_field(YLabelWBase, value=Settings.YLabelString, title='', xsize=25, /return_events)
widget_control, YLabelWField, sensitive=Settings.TickYLabel
XLabelWBase=widget_base(LabelsWBase, /row, frame=0)
XLabelWTick=cw_bgroup(XLabelWBase, 'X label', set_value=Settings.TickXLabel, /nonexclusive) 
XLabelWField=cw_field(XLabelWBase, value=Settings.XLabelString, title='', xsize=25, /return_events)
widget_control, XLabelWField, sensitive=Settings.TickXLabel
PlotDetailsWBase=widget_base(SignalVisualizationWTab, row=2, frame=1)
CharSizeWField=cw_field(PlotDetailsWBase, value=Settings.CharSize, title='Font size: ', xsize=2, /return_events)
LineThicknessWField=cw_field(PlotDetailsWBase ,value=Settings.LineThickness, title='Line-thickness: ', xsize=2, /return_events)
LineStyleWBase=widget_base(PlotDetailsWBase, /row, frame=0)
LineStyleWLabel=widget_label(LineStyleWBase, value='Line style: ')
LineStyles=['Solid', 'Dotted', 'Dashed', 'Dash-dot', 'Dash-Double dot', 'Long dashed']
LineStyleWDroplist=widget_droplist(LineStyleWBase, value=LineStyles)
widget_control, LineStyleWDroplist, set_droplist_select=Settings.LineStyle
DontEraseWTick=cw_bgroup(PlotDetailsWBase, "Don't erase plot", set_value=Settings.TickDontErase, /nonexclusive) 
PlotRawSignalWButton=widget_button(SignalVisualizationWTab, value='Plot signal', scr_xsize=10)

CorrelationWTab=widget_base(SignalWTabs, title='Covariance and correlation', /column)
CovCorrWBase=widget_base(CorrelationWTab, /row)
CovCorrWPick=cw_bgroup(CovCorrWBase, ['covariance','correlation'], /exclusive, set_value=Settings.CovCorr, column=2)
TauWBase=widget_base(CorrelationWTab, column=2)
TauRangeWBase=widget_base(TauWBase, /row)
TauRangeWTick=cw_bgroup(TauRangeWBase, 'Tau range', set_value=Settings.TickTauRange, /nonexclusive)
TauRangeAWField=cw_field(TauRangeWBase,value=Settings.TauRange(0), title=' ',xsize=8,/return_events)
TauRangeBWField=cw_field(TauRangeWBase, value=Settings.TauRange(1), title=' to ', xsize=8, /return_events)
widget_control, TauRangeAWField, sensitive=Settings.TickTauRange
widget_control, TauRangeBWField, sensitive=Settings.TickTauRange
TauRangeCursorWButton=widget_button(TauRangeWBase, value='click!', tooltip='To set X ranges using cursor, click on the points which you would like to set the X range to.')
TauResWBase=widget_base(CorrelationWTab, /row)
TauResWTick=cw_bgroup(TauResWBase, 'Tau resolution', set_value=Settings.TickTauRes, /nonexclusive)
TauResWField=cw_field(TauResWBase, value=Settings.TauRes, title=' ', xsize=8, /return_events)
widget_control, TauResWField, sensitive=Settings.TickTauRes
CorrYRangeWBase=widget_base(CorrelationWTab, /row)
CorrYRangeWTick=cw_bgroup(CorrYRangeWBase, 'Y range', set_value=Settings.TickCorrYRange, /nonexclusive)
CorrYRangeAWField=cw_field(CorrYRangeWBase, value=Settings.CorrYRange(0), title=' ', xsize=8, /return_events)
CorrYRangeBWField=cw_field(CorrYRangeWBase, value=Settings.CorrYRange(1), title=' to ', xsize=8, /return_events)
widget_control, CorrYRangeAWField, sensitive=Settings.TickCorrYRange
widget_control, CorrYRangeBWField, sensitive=Settings.TickCorrYRange
CorrYRangeCursorWButton=widget_button(CorrYRangeWBase, value='click!', scr_xsize=50, tooltip='To set Y ranges using cursor, click on the points which you would like to set Y range to.')
CorrIntTimeWBase=widget_base(CorrelationWTab, /row)
CorrIntTimeWTick=cw_bgroup(CorrIntTimeWBase, 'Integration time', set_value=Settings.TickCorrIntTime, /nonexclusive)
CorrIntTimeWField=cw_field(CorrIntTimeWBase, value=Settings.CorrIntTime, title=' ', xsize=4, /return_events)
widget_control, CorrIntTimeWField, sensitive=Settings.TickCorrIntTime
CorrCutLengthWBase=widget_base(CorrelationWTab, /row)
CorrCutLengthWTick=cw_bgroup(CorrCutLengthWBase, 'Cut length', set_value=Settings.TickCorrCutLength, /nonexclusive)
CorrCutLengthWField=cw_field(CorrCutLengthWBase, value=Settings.CorrCutLength, title=' ', xsize=4, /return_events)
widget_control, CorrCutLengthWField, sensitive=Settings.TickCorrCutLength
CorrFreqFilterWBase=widget_base(CorrelationWTab, /row)
CorrFilterAWTick=cw_bgroup(CorrFreqFilterWBase, 'High filter:', set_value=Settings.TickCorrFilter(0), /nonexclusive)
CorrFilterAWField=cw_field(CorrFreqFilterWBase, value=Settings.CorrFilter(0), title=' ',xsize=6,/return_events)
widget_control, CorrFilterAWField, sensitive=Settings.TickCorrFilter(0)
CorrFilterBWTick=cw_bgroup(CorrFreqFilterWBase, 'Low filter:', set_value=Settings.TickCorrFilter(1), /nonexclusive)
CorrFilterBWField=cw_field(CorrFreqFilterWBase,value=Settings.CorrFilter(1), title=' ',xsize=6,/return_events) 
widget_control, CorrFilterBWField, sensitive=Settings.TickCorrFilter(1)
CorrFilterOrderWTick=cw_bgroup(CorrFreqFilterWBase, 'Filter order:', set_value=Settings.TickCorrFilterOrder, /nonexclusive)
CorrFilterOrderWField=cw_field(CorrFreqFilterWBase,value=Settings.CorrFilterOrder, title=' ',xsize=6,/return_events)
widget_control, CorrFilterOrderWField, sensitive=Settings.TickCorrFilterOrder
CorrWindowWBase=widget_base(CorrelationWTab, /row)
CorrWindowWPick=cw_bgroup(CorrWindowWBase, ['None','Hamming','Hanning'], /exclusive, set_value=Settings.PickWindow, /row)
CorrPlotButton=widget_button(CorrelationWTab, value='plot')



SpectraWTab=widget_base(SignalWTabs, title='Coherence and spectral density', /column)
SpectraCohWBase=widget_base(SpectraWTab, /row)
SpectraCohWPick=cw_bgroup(SpectraCohWBase, ['Spectra','Coherence'], /exclusive, set_value=Settings.PickSpectraCoh, column=2)

FreqResWBase=widget_base(SpectraWTab, /row)
FreqResWTick=cw_bgroup(FreqResWBase, 'Frequency resolution', set_value=Settings.TickFreqRes, /nonexclusive)
FreqResWField=cw_field(FreqResWBase, title=' ', value=Settings.FreqRes, xsize=8, /return_events)
widget_control, FreqResWField, sensitive=Settings.TickFreqRes
FreqTypeWPick=cw_bgroup(FreqResWBase, ['linear','logarithmic'], /exclusive, set_value=Settings.PickFreqType, column=2)

FreqRange1WBase=widget_base(SpectraWTab, /row)
FreqRange2WBase=widget_base(SpectraWTab, /row)
FreqRangeWTick=cw_bgroup(FreqRange1WBase, 'Frequency range:', set_value=Settings.TickFreqRange, /nonexclusive)
FreqRangeAWField=cw_field(FreqRange1WBase,value=Settings.FreqRange(0), title=' ',xsize=8,/return_events)
FreqRangeBWField=cw_field(FreqRange1WBase, value=Settings.FreqRange(1), title=' to ', xsize=8, /return_events)
widget_control, FreqRangeAWField, sensitive=Settings.TickFreqRange
widget_control, FreqRangeBWField, sensitive=Settings.TickFreqRange
FreqRangeCursorWButton=widget_button (FreqRange1WBase, value='click!', scr_xsize=50, tooltip='To set frequency ranges using cursor, click on the points which you would like to set frequency range to.')
FreqXTypeWPick=cw_bgroup(FreqRange2WBase, ['linear','logarithmic'], /exclusive, set_value=Settings.PickFreqXType, column=2)

SpectraYRange1WBase=widget_base(SpectraWTab, /row)
SpectraYRange2WBase=widget_base(SpectraWTab, /row)
SpectraYRangeWTick=cw_bgroup(SpectraYRange1WBase, 'Y range', set_value=Settings.TickSpectraYRange, /nonexclusive)
SpectraYRangeAWField=cw_field(SpectraYRange1WBase, value=Settings.SpectraYRange(0), title=' ', xsize=8, /return_events)
SpectraYRangeBWField=cw_field(SpectraYRange1WBase, value=Settings.SpectraYRange(1), title=' to ', xsize=8, /return_events)
widget_control, SpectraYRangeAWField, sensitive=Settings.TickSpectraYRange
widget_control, SpectraYRangeBWField, sensitive=Settings.TickSpectraYRange
SpectraYRangeCursorWButton=widget_button(SpectraYRange1WBase, value='click!', scr_xsize=50, tooltip='To set Y ranges using cursor, click on the points which you would like to set Y range to.')
SpectraYTypeWPick=cw_bgroup(SpectraYRange2WBase, ['linear','logarithmic'], /exclusive, set_value=Settings.PickSpectraYType, column=2)
SpectraWindowWBase=widget_base(SpectraWTab, /row)
SpectraWindowWPick=cw_bgroup(SpectraWindowWBase, ['None','Hamming','Hanning'], /exclusive, set_value=Settings.PickWindow, /row)

SpectraIntTimeWBase=widget_base(SpectraWTab, /row)
SpectraIntTimeWTick=cw_bgroup(SpectraIntTimeWBase, 'Integration time', set_value=Settings.TickSpectraIntTime, /nonexclusive)
SpectraIntTimeWField=cw_field(SpectraIntTimeWBase, value=Settings.SpectraIntTime, title=' ', xsize=4, /return_events)
widget_control, SpectraIntTimeWField, sensitive=Settings.TickSpectraIntTime
SpectraNoiseLevelWTick=cw_bgroup(SpectraIntTimeWBase, 'Noise level', set_value=Settings.TickSpectraNoiseLevel, /nonexclusive)

;TickSpectraNoiseLevel

SpectraFreqFilterWBase=widget_base(SpectraWTab, /row)
SpectraFilterAWTick=cw_bgroup(SpectraFreqFilterWBase, 'High filter:', set_value=Settings.TickSpectraFilter(0), /nonexclusive)
SpectraFilterAWField=cw_field(SpectraFreqFilterWBase, value=Settings.SpectraFilter(0), title=' ',xsize=6,/return_events)
widget_control, SpectraFilterAWField, sensitive=Settings.TickSpectraFilter(0)
SpectraFilterBWTick=cw_bgroup(SpectraFreqFilterWBase, 'Low filter:', set_value=Settings.TickSpectraFilter(1), /nonexclusive)
SpectraFilterBWField=cw_field(SpectraFreqFilterWBase,value=Settings.SpectraFilter(1), title=' ',xsize=6,/return_events) 
widget_control, SpectraFilterBWField, sensitive=Settings.TickSpectraFilter(1)
SpectraFilterOrderWTick=cw_bgroup(SpectraFreqFilterWBase, 'Filter order:', set_value=Settings.TickSpectraFilterOrder, /nonexclusive)
SpectraFilterOrderWField=cw_field(SpectraFreqFilterWBase,value=Settings.SpectraFilterOrder, title=' ',xsize=6,/return_events)
widget_control, SpectraFilterOrderWField, sensitive=Settings.TickSpectraFilterOrder
SpectraPlotButton=widget_button(SpectraWTab, value='plot')

SpectraCrossPhasePlotButton=widget_button(SpectraWTab, value='plot with cross phase')

NTIWTab=widget_base(SignalWTabs, title='NTI Wavelet Tools', /column)


LowerWBase=widget_base(MainWBase, frame=1, column=1)
LogWBase=widget_base(LowerWBase, frame=1)
LogString=[['']]
LogWText=widget_text(LogWBase, value=LogString, frame=1, xsize=165, ysize=10, /scroll)

ControlPanelWBase=widget_base(UpperWBase, frame=1, /column)
ConfigWBase=widget_base(ControlPanelWBase, frame=1, column=1)
ConfigWLabel=widget_label(ConfigWBase, value='Configuration')
SaveConfigWButton=widget_button(ConfigWBase, value='Save to .cfg binary file')
LoadConfigWButton=widget_button(ConfigWBase, value='Load .cfg binary file')
LoadDATConfigWButton=widget_button(ConfigWBase, value='Load .dat ASCII file')

;SAVE OUTPUT
Settings.SaveOutputString='' 
SaveOutputWBase=widget_base(ControlPanelWBase, frame=1, row=1)
SaveOutPutWLabel=widget_label(SaveOutputWBase, value='OUT')
SaveOutputWField=cw_field(SaveOutputWBase, value=Settings.SaveOutputString, title='',xsize=8, /string, /return_events)
SaveOutputBrowseWButton=widget_button(SaveOutputWBase, value='Browse')
SaveOutputWButton=widget_button(SaveOutputWBase, value='Save')

;Settings.SaveJPGString=i2str(Settings.ShotNumber)+'.jpg'
Settings.SaveJPGString='' 
SaveJPGWBase=widget_base(ControlPanelWBase, frame=1, row=1)
SaveJPGWLabel=widget_label(SaveJPGWBase, value='JPG')
SaveJPGWField=cw_field(SaveJPGWBase, value=Settings.SaveJPGString, title='',xsize=8, /string, /return_events)
SaveJPGBrowseWButton=widget_button(SaveJPGWBase, value='Browse')
SaveJPGWButton=widget_button(SaveJPGWBase, value='Save')

;Settings.SaveEPSString=i2str(Settings.ShotNumber)+'.eps'
Settings.SaveEPSString=''
SaveEPSWBase=widget_base(ControlPanelWBase, frame=1, row=1)
SaveEPSWLabel=widget_label(SaveEPSWBase, value='EPS')
SaveEPSWField=cw_field(SaveEPSWBase, value=Settings.SaveEPSString, title='',xsize=8, /string, /return_events)
SaveEPSBrowseWButton=widget_button(SaveEPSWBase, value='Browse')
SaveEPSWButton=widget_button(SaveEPSWBase, value='Save')

FeaturesWButton=widget_button(ControlPanelWBase, value='Features', tooltip='Introduces the most important features of FLIPP GUI')
CommandLineWButton=widget_button(ControlPanelWBase, value='Command line', tooltip='Lets you write to the command line.')
ExitWButton=widget_button(ControlPanelWBase, value='Exit', tooltip='Closes FLIPP graphical user interface.')
widget_control, MainWBase, /realize
xmanager, 'gui', MainWBase, /no_block

wait, 0.5

end
