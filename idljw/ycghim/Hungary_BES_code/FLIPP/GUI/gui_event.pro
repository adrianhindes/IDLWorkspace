pro gui_event, event
@gui_common

  case event.ID of
    DataPathWField: begin
        widget_control, DataPathWField, get_value=tmp
        Settings.DataPath=tmp        
        AddMessage2LogString, "Data path: " + i2str(Settings.DataPath)
    end  
    DataSourceWDroplist: begin
        tmp=event.index
        Settings.DataSource=tmp
        AddMessage2LogString, "Data source: " + DataSources(Settings.DataSource)
    end
    ShotNumberWField: begin
        widget_control, ShotNumberWField, get_value=tmp
        Settings.ShotNumber=tmp        
        AddMessage2LogString, "Shot number: #" + i2str(Settings.ShotNumber)
        Settings.TimeFileNameONString=i2str(Settings.ShotNumber)+'on.time'
        widget_control, TimeFileNameONWField, set_value=Settings.TimeFileNameONString
        Settings.TimeFileNameOFFString=i2str(Settings.ShotNumber)+'off.time'
        widget_control, TimeFileNameOFFWField, set_value=Settings.TimeFileNameOFFString
    end
    AutoOrCrossWPick: begin
        widget_control, AutoOrCrossWPick, get_value=tmp
        Settings.AutoOrCross=tmp
        if (tmp eq 0) then begin ;Auto
          AddMessage2LogString, "Auto"
          AddMessage2LogString, "Channel 2 disabled."
        end
        if (tmp eq 1) then begin ;Cross
          AddMessage2LogString, "Cross"
          AddMessage2LogString, "Channel 2 enabled."
        end
        widget_control, Channel2WField, sensitive=Settings.AutoOrCross
    end
    Channel1WField: begin
        widget_control, Channel1WField, get_value=tmp
        Settings.Channel1=tmp
        AddMessage2LogString, 'Channel 1: ' + Settings.Channel1
    end
    Channel2WField: begin
        widget_control, Channel2WField, get_value=tmp
        Settings.Channel2=tmp
        AddMessage2LogString, 'Channel 2: ' + Settings.Channel2
    end
    TimeFileNeededWTick: begin
	widget_control, TimeFileNeededWTick, get_value=tmp
	Settings.TickTimeFile=tmp
	widget_control, TimeFileOffOnWPick, sensitive=Settings.TickTimeFile
	widget_control, TimeFileNameONWField, sensitive=Settings.TickTimeFile
	widget_control, TimeFileNameOFFWField, sensitive=Settings.TickTimeFile
	widget_control, TimeSelectProWButton, sensitive=Settings.TickTimeFile
	widget_control, TimeAutoChopperWTick, sensitive=Settings.TickTimeFile
    end
    TimeFileOffOnWPick: begin
	widget_control, TimeFileOffOnWPick, get_value=tmp
	Settings.PickTimeFileOffOn=tmp
	if (Settings.PickTimeFileOffOn eq 1) then begin
	AddMessage2LogString, "Using ON time file "
	endif else begin
	AddMessage2LogString, "Using OFF time file "
	endelse
    end
    TimeFileNameONWField: begin
	widget_control,TimeFileNameONWField, get_value=tmp
	Settings.TimeFileNameONString=tmp
	AddMessage2LogString, "Beam-on time file: " + Settings.TimeFileNameONString
    end
    TimeFileNameOFFWField: begin
	widget_control,TimeFileNameOFFWField, get_value=tmp
	Settings.TimeFileNameOFFString=tmp
	AddMessage2LogString, "Beam-off time file: " + Settings.TimeFileNameOFFString
    end
    TimeAutoChopperWTick: begin
	widget_control, TimeAutoChopperWTick, get_value=tmp
	Settings.TickTimeAutoChopper=tmp
	if (tmp eq 0) then begin
	  AddMessage2LogString, "Do not find automatically beam-on/off time intervals."
	end
	if (tmp eq 1) then begin
	  AddMessage2LogString, "Automatically find beam-on/off time intervals."
	end
    end
    TimeSelectProWButton: begin
	TimeSelectPro
    end
    SignalWTabs:
    TimeRangeWTick: begin
	widget_control, TimeRangeWTick, get_value=tmp
	Settings.TickTimeRange=tmp
	widget_control, TimeRangeAWField , sensitive=Settings.TickTimeRange
	widget_control, TimeRangeBWField , sensitive=Settings.TickTimeRange
	; widget_control, TimeRangeCursorWButton , sensitive=Settings.TickTimeRange
    end
    TimeRangeAWField: begin
	widget_control, TimeRangeAWField, get_value=tmp
	Settings.TimeRange(0)=tmp        
	AddMessage2LogString, 'X (time) range: ['+strtrim(string(Settings.TimeRange(0)), 2)+','+strtrim(string(Settings.TimeRange(1)), 2)+']'
    end
    TimeRangeBWField: begin
	widget_control, TimeRangeBWField, get_value=tmp
	Settings.TimeRange(1)=tmp        
	AddMessage2LogString, 'X (time) range: ['+strtrim(string(Settings.TimeRange(0)), 2)+','+strtrim(string(Settings.TimeRange(1)), 2)+']'
    end
    TimeRangeCursorWButton: begin
        PlotRawSignalPro
        AddMessage2LogString, 'Click twice on the plot screen to set X (time) range.'
        AddMessage2LogString, "The selected X (time) range will be the range between the two points you click on."
	wait, 0.5
        cursor, tmp1, TempY, 4, /data
        cursor, tmp2, TempY, 4, /data
        if (tmp1 lt tmp2) then begin
          Settings.TimeRange(0)=tmp1
          Settings.TimeRange(1)=tmp2
        endif else begin
          Settings.TimeRange(0)=tmp2
          Settings.TimeRange(1)=tmp1
        endelse
        widget_control, TimeRangeAWField, set_value=Settings.TimeRange(0)
        widget_control, TimeRangeBWField, set_value=Settings.TimeRange(1)
        AddMessage2LogString, 'X (time) range: ['+strtrim(string(Settings.TimeRange(0)), 2)+','+strtrim(string(Settings.TimeRange(1)), 2)+']'
        Settings.TickTimeRange=1
        widget_control, TimeRangeWTick, set_value=Settings.TickTimeRange
        widget_control, TimeRangeAWField, sensitive=Settings.TickTimeRange
        widget_control, TimeRangeBWField, sensitive=Settings.TickTimeRange
	PlotRawSignalPro
    end
    YRangeWTick: begin
	widget_control, YRangeWTick, get_value=tmp
	Settings.TickYRange=tmp
	widget_control, YRangeAWField, sensitive=Settings.TickYRange
	widget_control, YRangeBWField, sensitive=Settings.TickYRange
	; widget_control, YRangeCursorWButton, sensitive=Settings.TickYRange
    end
    YRangeAWField: begin
	widget_control, YRangeAWField, get_value=tmp
	Settings.YRange(0)=tmp
	AddMessage2LogString, 'Y range: ['+strtrim(string(Settings.YRange(0)), 2)+','+strtrim(string(Settings.YRange(1)), 2)+']'
    end
    YRangeBWField: begin
	widget_control, YRangeBWField, get_value=tmp
	Settings.YRange(1)=tmp
	AddMessage2LogString, 'Y range: ['+strtrim(string(Settings.YRange(0)), 2)+','+strtrim(string(Settings.YRange(1)), 2)+']'
    end
    YRangeCursorWButton: begin
        PlotRawSignalPro
        AddMessage2LogString, 'Click twice on the plot screen to set Y range.'
        AddMessage2LogString, "The selected Y range will be the range between the two points you click on."
        wait, 0.5
        cursor, TempX, tmp1, 4, /data
        cursor, TempX, tmp2, 4, /data
        if (tmp1 lt tmp2) then begin
          Settings.YRange(0)=tmp1
          Settings.YRange(1)=tmp2
        endif else begin
          Settings.YRange(0)=tmp2
          Settings.YRange(1)=tmp1
        endelse
        widget_control, YRangeAWField, set_value=Settings.YRange(0)
        widget_control, YRangeBWField, set_value=Settings.YRange(1)
        AddMessage2LogString, 'Y range: ['+strtrim(string(Settings.YRange(0)), 2)+','+strtrim(string(Settings.YRange(1)), 2)+']'
        Settings.TickYRange=1
        widget_control, YRangeWTick, set_value=Settings.TickYRange
        widget_control, YRangeAWField, sensitive=Settings.TickYRange
        widget_control, YRangeBWField, sensitive=Settings.TickYRange
        PlotRawSignalPro
    end
    TitleWTick: begin
	widget_control, TitleWTick, get_value=tmp
	Settings.TickTitle=tmp
	widget_control, TitleWField, sensitive=Settings.TickTitle
    end       
    TitleWField: begin
	widget_control, TitleWField, get_value=tmp
	Settings.TitleString=tmp
	AddMessage2LogString, 'Title: ' + Settings.TitleString
    end
    YLabelWTick: begin
        widget_control, YLabelWTick, get_value=tmp
        Settings.TickYLabel=tmp
        widget_control, YLabelWField, sensitive=Settings.TickYLabel
    end
    YLabelWField: begin
	widget_control, YLabelWField, get_value=tmp
	Settings.YLabelString=tmp
	AddMessage2LogString, 'Y label: ' + Settings.YLabelString
    end
    XLabelWTick: begin
	AddMessage2LogString, 'Not implemented yet... LATER.'
	Settings.TickXLabel=0
	widget_control, XLabelWTick, set_value=0
        ;widget_control, XLabelWTick, get_value=tmp
        ;Settings.TickXLabel=tmp
        ;widget_control, XLabelWField, sensitive=Settings.TickXLabel
    end
    XLabelWField: begin
	widget_control, XLabelWField, get_value=tmp
	Settings.XLabelString=tmp
	AddMessage2LogString, 'X label: ' + Settings.XLabelString
    end 
    CharSizeWField: begin
	widget_control, CharSizeWField, get_value=tmp
	Settings.CharSize=tmp
	AddMessage2LogString, 'Character size: ' + i2str(Settings.CharSize)
    end 
    LineThicknessWField: begin
	widget_control, LineThicknessWField, get_value=tmp
	Settings.LineThickness=tmp
	AddMessage2LogString, 'Line thickness: ' + i2str(Settings.LineThickness)
    end
    LineStyleWDroplist: begin
        tmp=event.index
        Settings.LineStyle=tmp
        AddMessage2LogString, "Line style: " + LineStyles(Settings.LineStyle)
    end
    DontEraseWTick: begin
	widget_control, DontEraseWTick, get_value=tmp
	Settings.TickDontErase=tmp
	if (tmp eq 0) then begin
	  AddMessage2LogString, "Erase previous plots."
	end
	if (tmp eq 1) then begin
	  AddMessage2LogString, "Do not erase previous plots."
	end
    end
    PlotRawSignalWButton: begin
	PlotRawSignalPro
    end
    CovCorrWPick: begin ; 
        widget_control, CovCorrWPick, get_value=tmp
        Settings.CovCorr=tmp
        if (tmp eq 0) then begin ;Cov
          AddMessage2LogString, "Covariance"
        end
        if (tmp eq 1) then begin ;Corr
          AddMessage2LogString, "Correlation"
        end
    end
    TauRangeWTick: begin
	widget_control, TauRangeWTick, get_value=tmp
	Settings.TickTauRange=tmp
	widget_control, TauRangeAWField, sensitive=Settings.TickTauRange
	widget_control, TauRangeBWField, sensitive=Settings.TickTauRange
    end 
    TauRangeAWField: begin
    	widget_control, TauRangeAWField, get_value=tmp
	Settings.TauRange(0)=tmp
	AddMessage2LogString, 'Tau range: ['+strtrim(string(Settings.TauRange(0)), 2)+','+strtrim(string(Settings.TauRange(1)), 2)+']'
    end
    TauRangeBWField: begin
    	widget_control, TauRangeBWField, get_value=tmp
	Settings.TauRange(1)=tmp
	AddMessage2LogString, 'Tau range: ['+strtrim(string(Settings.TauRange(0)), 2)+','+strtrim(string(Settings.TauRange(1)), 2)+']'
    end
    
    TauRangeCursorWButton: begin
        PlotCorrPro
        AddMessage2LogString, 'Click twice on the plot screen to set X (tau) range.'
        AddMessage2LogString, "The selected X (tau) range will be the range between the two points you click on."
	wait, 0.5
        cursor, tmp1, TempY, 4, /data
        cursor, tmp2, TempY, 4, /data
        if (tmp1 lt tmp2) then begin
          Settings.TauRange(0)=tmp1
          Settings.TauRange(1)=tmp2
        endif else begin
          Settings.TauRange(0)=tmp2
          Settings.TauRange(1)=tmp1
        endelse
        widget_control, TauRangeAWField, set_value=Settings.TauRange(0)
        widget_control, TauRangeBWField, set_value=Settings.TauRange(1)
        AddMessage2LogString, 'X (tau) range: ['+strtrim(string(Settings.TauRange(0)), 2)+','+strtrim(string(Settings.TauRange(1)), 2)+']'
        Settings.TickTauRange=1
        widget_control, TauRangeWTick, set_value=Settings.TickTauRange
        widget_control, TauRangeAWField, sensitive=Settings.TickTauRange
        widget_control, TauRangeBWField, sensitive=Settings.TickTauRange
	PlotCorrPro
    end
    TauResWTick: begin
	widget_control, TauResWTick, get_value=tmp
	Settings.TickTauRes=tmp
	widget_control, TauResWField, sensitive=Settings.TickTauRes

    end
    TauResWField: begin
    	widget_control, TauResWField, get_value=tmp
	Settings.TauRes=tmp
	AddMessage2LogString, 'Tau resolution: '+strtrim(string(Settings.TauRes), 2)
    end
    CorrYRangeWTick: begin
	widget_control, CorrYRangeWTick, get_value=tmp
	Settings.TickCorrYRange=tmp
	widget_control, CorrYRangeAWField, sensitive=Settings.TickCorrYRange
	widget_control, CorrYRangeBWField, sensitive=Settings.TickCorrYRange
    end 
    CorrYRangeAWField: begin
    	widget_control, CorrYRangeAWField, get_value=tmp
	Settings.CorrYRange(0)=tmp
	AddMessage2LogString, 'Y range: ['+strtrim(string(Settings.CorrYRange(0)), 2)+','+strtrim(string(Settings.CorrYRange(1)), 2)+']'    
    end 
    CorrYRangeBWField: begin
    	widget_control, CorrYRangeBWField, get_value=tmp
	Settings.CorrYRange(1)=tmp
	AddMessage2LogString, 'Y range: ['+strtrim(string(Settings.CorrYRange(0)), 2)+','+strtrim(string(Settings.CorrYRange(1)), 2)+']'    
    end 
    CorrYRangeCursorWButton: begin
        PlotCorrPro
        AddMessage2LogString, 'Click twice on the plot screen to set Y range.'
        AddMessage2LogString, "The selected Y range will be the range between the two points you click on."
        wait, 0.5
        cursor, TempX, tmp1, 4, /data
        cursor, TempX, tmp2, 4, /data
        if (tmp1 lt tmp2) then begin
          Settings.CorrYRange(0)=tmp1
          Settings.CorrYRange(1)=tmp2
        endif else begin
          Settings.CorrYRange(0)=tmp2
          Settings.CorrYRange(1)=tmp1
        endelse
        widget_control, CorrYRangeAWField, set_value=Settings.CorrYRange(0)
        widget_control, CorrYRangeBWField, set_value=Settings.CorrYRange(1)
        AddMessage2LogString, 'Y range: ['+strtrim(string(Settings.CorrYRange(0)), 2)+','+strtrim(string(Settings.CorrYRange(1)), 2)+']'
        Settings.TickCorrYRange=1
        widget_control, CorrYRangeWTick, set_value=Settings.TickCorrYRange
        widget_control, CorrYRangeAWField, sensitive=Settings.TickCorrYRange
        widget_control, CorrYRangeBWField, sensitive=Settings.TickCorrYRange
        PlotCorrPro
    end    
    CorrIntTimeWTick: begin
	widget_control, CorrIntTimeWTick, get_value=tmp
	Settings.TickCorrIntTime=tmp
	widget_control, CorrIntTimeWField, sensitive=Settings.TickCorrIntTime
    end
    ; SpectraNoiseLevelWTick
    SpectraNoiseLevelWTick: begin
	widget_control, SpectraNoiseLevelWTick, get_value=tmp
	Settings.TickSpectraNoiseLevel=tmp
    end
    CorrIntTimeWField: begin
	widget_control, CorrIntTimeWField, get_value=tmp
	Settings.CorrIntTime=tmp
	AddMessage2LogString, 'Integration time: '+ strtrim(string(Settings.CorrIntTime), 2)
    end
    CorrCutLengthWTick: begin
	widget_control, CorrCutLengthWTick, get_value=tmp
	Settings.TickCorrCutLength=tmp
	widget_control, CorrCutLengthWField, sensitive=Settings.TickCorrCutLength
    end
    CorrCutLengthWField: begin
	widget_control, CorrCutLengthWField, get_value=tmp
	Settings.CorrCutLength=tmp
	AddMessage2LogString, 'Cut length: '+ strtrim(string(Settings.CorrCutLength), 2)
    end
    CorrFilterAWTick: begin
	widget_control, CorrFilterAWTick, get_value=tmp
	Settings.TickCorrFilter(0)=tmp
	widget_control, CorrFilterAWField, sensitive=Settings.TickCorrFilter(0)
    end
    CorrFilterAWField: begin
	widget_control, CorrFilterAWField, get_value=tmp
	Settings.CorrFilter(0)=tmp
	AddMessage2LogString, 'High filter: '+ strtrim(string(Settings.CorrFilter(0)), 2)
    end   
    CorrFilterBWTick: begin
	widget_control, CorrFilterBWTick, get_value=tmp
	Settings.TickCorrFilter(1)=tmp
	widget_control, CorrFilterBWField, sensitive=Settings.TickCorrFilter(1)
    end
    CorrFilterBWField: begin
	widget_control, CorrFilterBWField, get_value=tmp
	Settings.CorrFilter(1)=tmp
	AddMessage2LogString, 'Low filter: '+ strtrim(string(Settings.CorrFilter(1)), 2)
    end
    CorrFilterOrderWTick: begin
    	widget_control, CorrFilterOrderWTick, get_value=tmp
	Settings.TickCorrFilterOrder=tmp
	widget_control, CorrFilterOrderWField, sensitive=Settings.TickCorrFilterOrder
    end
    CorrFilterOrderWField: begin
	widget_control, CorrFilterOrderWField, get_value=tmp
	Settings.CorrFilterOrder=tmp
	AddMessage2LogString, 'Filter order: '+ strtrim(string(Settings.CorrFilterOrder), 2)
    end
    CorrWindowWPick: begin
        widget_control, CorrWindowWPick, get_value=tmp
        Settings.PickWindow=tmp
        widget_control, SpectraWindowWPick, set_value=tmp
        if (tmp eq 0) then begin 
          AddMessage2LogString, "No windowing function is used"
        end
        if (tmp eq 1) then begin 
          AddMessage2LogString, "Use Hamming window for FFT"
        end
        if (tmp eq 2) then begin 
          AddMessage2LogString, "Use Hanning window for FFT"
        end
    end
    CorrPlotButton: begin
	PlotCorrPro
    end
    SpectraCohWPick: begin ; 
        widget_control, SpectraCohWPick, get_value=tmp
        Settings.PickSpectraCoh=tmp
        if (tmp eq 0) then begin ;Cov
          AddMessage2LogString, "Spectra"
        end
        if (tmp eq 1) then begin ;Corr
          AddMessage2LogString, "Coherence"
        end
        widget_control, SpectraNoiseLevelWTick, sensitive=Settings.PickSpectraCoh
    end
    FreqResWTick: begin
	widget_control, FreqResWTick, get_value=tmp
	Settings.TickFreqRes=tmp
	widget_control, FreqResWField, sensitive=Settings.TickFreqRes

    end
    FreqResWField: begin
    	widget_control, FreqResWField, get_value=tmp
	Settings.FreqRes=tmp
	AddMessage2LogString, 'Freq resolution: '+strtrim(string(Settings.FreqRes), 2)
    end
    FreqTypeWPick: begin
        widget_control, FreqTypeWPick, get_value=tmp
        Settings.PickFreqType=tmp
        if (tmp eq 0) then begin ;Cov
          AddMessage2LogString, "Linear"
        end
        if (tmp eq 1) then begin ;Corr
          AddMessage2LogString, "Logarithmic"
        end
    end
    FreqRangeWTick: begin
	widget_control, FreqRangeWTick, get_value=tmp
	Settings.TickFreqRange=tmp
	widget_control, FreqRangeAWField, sensitive=Settings.TickFreqRange
	widget_control, FreqRangeBWField, sensitive=Settings.TickFreqRange
    end 
    FreqRangeAWField: begin
    	widget_control, FreqRangeAWField, get_value=tmp
	Settings.FreqRange(0)=tmp
	AddMessage2LogString, 'Freq range: ['+strtrim(string(Settings.FreqRange(0)), 2)+','+strtrim(string(Settings.FreqRange(1)), 2)+']'
    end
    FreqRangeBWField: begin
    	widget_control, FreqRangeBWField, get_value=tmp
	Settings.FreqRange(1)=tmp
	AddMessage2LogString, 'Freq range: ['+strtrim(string(Settings.FreqRange(0)), 2)+','+strtrim(string(Settings.FreqRange(1)), 2)+']'
    end
    FreqRangeCursorWButton: begin
        PlotSpectraPro
        AddMessage2LogString, 'Click twice on the plot screen to set X (Freq) range.'
        AddMessage2LogString, "The selected X (Freq) range will be the range between the two points you click on."
	wait, 0.5
        cursor, tmp1, TempY, 4, /data
        cursor, tmp2, TempY, 4, /data
        if (tmp1 lt tmp2) then begin
          Settings.FreqRange(0)=tmp1
          Settings.FreqRange(1)=tmp2
        endif else begin
          Settings.FreqRange(0)=tmp2
          Settings.FreqRange(1)=tmp1
        endelse
        widget_control, FreqRangeAWField, set_value=Settings.FreqRange(0)
        widget_control, FreqRangeBWField, set_value=Settings.FreqRange(1)
        AddMessage2LogString, 'X (Freq) range: ['+strtrim(string(Settings.FreqRange(0)), 2)+','+strtrim(string(Settings.FreqRange(1)), 2)+']'
        Settings.TickFreqRange=1
        widget_control, FreqRangeWTick, set_value=Settings.TickFreqRange
        widget_control, FreqRangeAWField, sensitive=Settings.TickFreqRange
        widget_control, FreqRangeBWField, sensitive=Settings.TickFreqRange
	PlotSpectraPro
    end
    FreqXTypeWPick: begin
        widget_control, FreqXTypeWPick, get_value=tmp
        Settings.PickFreqXType=tmp
        if (tmp eq 0) then begin ;Cov
          AddMessage2LogString, "Linear"
        end
        if (tmp eq 1) then begin ;Corr
          AddMessage2LogString, "Logarithmic"
        end    
    end
    SpectraYRangeWTick: begin
	widget_control, SpectraYRangeWTick, get_value=tmp
	Settings.TickSpectraYRange=tmp
	widget_control, SpectraYRangeAWField, sensitive=Settings.TickSpectraYRange
	widget_control, SpectraYRangeBWField, sensitive=Settings.TickSpectraYRange
    end 
    SpectraYRangeAWField: begin
    	widget_control, SpectraYRangeAWField, get_value=tmp
	Settings.SpectraYRange(0)=tmp
	AddMessage2LogString, 'Y range: ['+strtrim(string(Settings.SpectraYRange(0)), 2)+','+strtrim(string(Settings.SpectraYRange(1)), 2)+']'    
    end 
    SpectraYRangeBWField: begin
    	widget_control, SpectraYRangeBWField, get_value=tmp
	Settings.SpectraYRange(1)=tmp
	AddMessage2LogString, 'Y range: ['+strtrim(string(Settings.SpectraYRange(0)), 2)+','+strtrim(string(Settings.SpectraYRange(1)), 2)+']'    
    end 
    SpectraYRangeCursorWButton: begin
        PlotSpectraPro
        AddMessage2LogString, 'Click twice on the plot screen to set Y range.'
        AddMessage2LogString, "The selected Y range will be the range between the two points you click on."
        wait, 0.5
        cursor, TempX, tmp1, 4, /data
        cursor, TempX, tmp2, 4, /data
        if (tmp1 lt tmp2) then begin
          Settings.SpectraYRange(0)=tmp1
          Settings.SpectraYRange(1)=tmp2
        endif else begin
          Settings.SpectraYRange(0)=tmp2
          Settings.SpectraYRange(1)=tmp1
        endelse
        widget_control, SpectraYRangeAWField, set_value=Settings.SpectraYRange(0)
        widget_control, SpectraYRangeBWField, set_value=Settings.SpectraYRange(1)
        AddMessage2LogString, 'Y range: ['+strtrim(string(Settings.SpectraYRange(0)), 2)+','+strtrim(string(Settings.SpectraYRange(1)), 2)+']'
        Settings.TickSpectraYRange=1
        widget_control, SpectraYRangeWTick, set_value=Settings.TickSpectraYRange
        widget_control, SpectraYRangeAWField, sensitive=Settings.TickSpectraYRange
        widget_control, SpectraYRangeBWField, sensitive=Settings.TickSpectraYRange
        PlotSpectraPro
    end
    SpectraYTypeWPick: begin
        widget_control, SpectraYTypeWPick, get_value=tmp
        Settings.PickSpectraYType=tmp
        if (tmp eq 0) then begin
          AddMessage2LogString, "Linear"
        end
        if (tmp eq 1) then begin
          AddMessage2LogString, "Logarithmic"
        end 
    end
    SpectraWindowWPick: begin
        widget_control, SpectraWindowWPick, get_value=tmp
        Settings.PickWindow=tmp
        widget_control, CorrWindowWPick, set_value=tmp
        if (tmp eq 0) then begin 
          AddMessage2LogString, "No windowing function is used"
        end
        if (tmp eq 1) then begin 
          AddMessage2LogString, "Use Hamming window for FFT"
        end
        if (tmp eq 2) then begin 
          AddMessage2LogString, "Use Hanning window for FFT"
        end
    end
    SpectraFilterAWTick: begin
	widget_control, SpectraFilterAWTick, get_value=tmp
	Settings.TickSpectraFilter(0)=tmp
	widget_control, SpectraFilterAWField, sensitive=Settings.TickSpectraFilter(0)
    end
    SpectraFilterAWField: begin
	widget_control, SpectraFilterAWField, get_value=tmp
	Settings.SpectraFilter(0)=tmp
	AddMessage2LogString, 'High filter: '+ strtrim(string(Settings.SpectraFilter(0)), 2)
    end   
    SpectraFilterBWTick: begin
	widget_control, SpectraFilterBWTick, get_value=tmp
	Settings.TickSpectraFilter(1)=tmp
	widget_control, SpectraFilterBWField, sensitive=Settings.TickSpectraFilter(1)
    end
    SpectraFilterBWField: begin
	widget_control, SpectraFilterBWField, get_value=tmp
	Settings.SpectraFilter(1)=tmp
	AddMessage2LogString, 'Low filter: '+ strtrim(string(Settings.SpectraFilter(1)), 2)
    end
    SpectraFilterOrderWTick: begin
    	widget_control, SpectraFilterOrderWTick, get_value=tmp
	Settings.TickSpectraFilterOrder=tmp
	widget_control, SpectraFilterOrderWField, sensitive=Settings.TickSpectraFilterOrder
    end
    SpectraFilterOrderWField: begin
	widget_control, SpectraFilterOrderWField, get_value=tmp
	Settings.SpectraFilterOrder=tmp
	AddMessage2LogString, 'Filter order: '+ strtrim(string(Settings.SpectraFilterOrder), 2)
    end
    SpectraIntTimeWTick: begin
	widget_control, SpectraIntTimeWTick, get_value=tmp
	Settings.TickSpectraIntTime=tmp
	widget_control, SpectraIntTimeWField, sensitive=Settings.TickSpectraIntTime
    end
    SpectraIntTimeWField: begin
    	widget_control, SpectraIntTimeWField, get_value=tmp
	Settings.SpectraIntTime=tmp
	AddMessage2LogString, 'Integration time (on this tab only!): '+ strtrim(string(Settings.SpectraIntTime), 2)
    end
    SpectraPlotButton: begin 
	PlotSpectraPro
    end
    SpectraCrossPhasePlotButton: begin
	PlotSpectraCrossPhasePro
    end
    SaveConfigWButton: begin
        tmp = dialog_pickfile(dialog_parent=event.top, /fix_filter, filter=['*.cfg'], /overwrite_prompt, /write, file='myConfigSettings.cfg')
        save, Settings, filename=tmp
        AddMessage2LogString, 'Configuration settings saved to: '+tmp
    end
    LoadConfigWButton: begin
	AddMessage2LogString, 'Please choose file from window.'
        tmp=dialog_pickfile(dialog_parent=event.top, /fix_filter, filter=['*.cfg'], /must_exist)
        AddMessage2LogString, 'Loading configuration...'
        restore, tmp
        widget_control, DataPathWField, set_value=Settings.DataPath
	widget_control, DataSourceWDroplist, set_droplist_select=Settings.DataSource
	widget_control, ShotNumberWField, set_value=Settings.ShotNumber
	widget_control, AutoOrCrossWPick, set_value=Settings.AutoOrCross
	widget_control, Channel1WField, set_value=Settings.Channel1
	widget_control, Channel2WField, set_value=Settings.Channel2
	widget_control, Channel2WField, sensitive=Settings.AutoOrCross
	widget_control, TimeFileNeededWTick, set_value=Settings.TickTimeFile
	widget_control, TimeFileNameONWField , set_value=Settings.TimeFileNameONString
	widget_control, TimeFileNameONWField, sensitive=Settings.TickTimeFile
	widget_control, TimeFileNameOFFWField , set_value=Settings.TimeFileNameOFFString
	widget_control, TimeFileNameOFFWField, sensitive=Settings.TickTimeFile
	widget_control, TimeAutoChopperWTick , set_value=Settings.TickTimeAutoChopper
	widget_control, TimeAutoChopperWTick, sensitive=Settings.TickTimeFile
	widget_control, TimeSelectProWButton, sensitive=Settings.TickTimeFile
	widget_control, TimeRangeWTick , set_value=Settings.TickTimeRange
	widget_control, TimeRangeAWField , set_value=Settings.TimeRange(0)
	widget_control, TimeRangeAWField, sensitive=Settings.TickTimeRange
	widget_control, TimeRangeBWField , set_value=Settings.TimeRange(1)
	widget_control, TimeRangeBWField, sensitive=Settings.TickTimeRange
	widget_control, YRangeWTick , set_value=Settings.TickYRange
	widget_control, YRangeAWField , set_value=Settings.YRange(0)
	widget_control, YRangeAWField, sensitive=Settings.TickYRange
	widget_control, YRangeBWField , set_value=Settings.YRange(1)
	widget_control, YRangeBWField, sensitive=Settings.TickYRange
	widget_control, TitleWTick, set_value=Settings.TickTitle
	widget_control, TitleWField , set_value=Settings.TitleString
	widget_control, TitleWField , sensitive=Settings.TickTitle
	widget_control, YLabelWTick, set_value=Settings.TickYLabel
	widget_control, YlabelWField , set_value=Settings.YLabelString
	widget_control, YLabelWField , sensitive=Settings.TickYLabel
	widget_control, CharSizeWField, set_value=Settings.CharSize
	widget_control, LineThicknessWField, set_value=Settings.LineThickness
	widget_control, LineStyleWDroplist, set_droplist_select=Settings.LineStyle
	widget_control, DontEraseWTick, set_value=Settings.TickDontErase
	widget_control, CovCorrWPick, set_value=Settings.CovCorr
	widget_control, TauRangeWTick, set_value=Settings.TickTauRange
	widget_control, TauRangeAWField, set_value=Settings.TauRange(0)
	widget_control, TauRangeAWField, sensitive=Settings.TickTauRange
	widget_control, TauRangeBWField, set_value=Settings.TauRange(1)
	widget_control, TauRangeBWField, sensitive=Settings.TickTauRange
	widget_control, TauResWTick, set_value=Settings.TickTauRes
	widget_control, TauResWField, set_value=Settings.TauRes
	widget_control, TauResWField, sensitive=Settings.TickTauRes
	widget_control, CorrYRangeWTick , set_value=Settings.TickCorrYRange
	widget_control, CorrYRangeAWField , set_value=Settings.CorrYRange(0)
	widget_control, CorrYRangeAWField, sensitive=Settings.TickCorrYRange
	widget_control, CorrYRangeBWField , set_value=Settings.CorrYRange(1)
	widget_control, CorrYRangeBWField, sensitive=Settings.TickCorrYRange
	widget_control, SpectraYRangeWTick , set_value=Settings.TickSpectraYRange
	widget_control, SpectraYRangeAWField , set_value=Settings.SpectraYRange(0)
	widget_control, SpectraYRangeAWField, sensitive=Settings.TickSpectraYRange
	widget_control, SpectraYRangeBWField , set_value=Settings.SpectraYRange(1)
	widget_control, SpectraYRangeBWField, sensitive=Settings.TickSpectraYRange	
	widget_control, SpectraYTypeWPick, set_value=Settings.PickSpectraYType
	widget_control, CorrIntTimeWTick, set_value=Settings.TickCorrIntTime
	widget_control, CorrIntTimeWField, set_value=Settings.CorrIntTime
	widget_control, CorrIntTimeWField, sensitive=Settings.TickCorrIntTime
	widget_control, CorrCutLengthWTick, set_value=Settings.TickCorrCutLength
	widget_control, CorrCutLengthWField, set_value=Settings.CorrCutLength
	widget_control, CorrCutLengthWField, sensitive=Settings.TickCorrCutLength
	widget_control, CorrFilterAWTick, set_value=Settings.TickCorrFilter(0)
	widget_control, CorrFilterAWField, set_value=Settings.CorrFilter(0)
	widget_control, CorrFilterAWField, sensitive=Settings.TickCorrFilter(0)
	widget_control, CorrFilterBWTick, set_value=Settings.TickCorrFilter(1)
	widget_control, CorrFilterBWField, set_value=Settings.CorrFilter(1)
	widget_control, CorrFilterBWField, sensitive=Settings.TickCorrFilter(1)
	widget_control, CorrFilterOrderWTick, set_value=Settings.TickCorrFilterOrder
	widget_control, CorrFilterOrderWField, set_value=Settings.CorrFilterOrder
	widget_control, CorrFilterOrderWField, sensitive=Settings.TickCorrFilterOrder
	widget_control, CorrWindowWPick, set_value=Settings.PickWindow
	widget_control, SpectraCohWPick, set_value=Settings.PickSpectraCoh
	widget_control, FreqResWTick, set_value=Settings.TickFreqRes
	widget_control, FreqResWField, set_value=Settings.FreqRes
	widget_control, FreqResWField, sensitive=Settings.TickFreqRes
	widget_control, FreqTypeWPick, set_value=Settings.PickFreqType
	widget_control, FreqRangeWTick, set_value=Settings.TickFreqRange
	widget_control, FreqRangeAWField, set_value=Settings.FreqRange(0)
	widget_control, FreqRangeAWField, sensitive=Settings.TickFreqRange
	widget_control, FreqRangeBWField, set_value=Settings.FreqRange(1)
	widget_control, FreqRangeBWField, sensitive=Settings.TickFreqRange
	widget_control, FreqXTypeWPick, set_value=Settings.PickFreqXType
	widget_control, SpectraIntTimeWTick, set_value=Settings.TickSpectraIntTime
	widget_control, SpectraIntTimeWField, set_value=Settings.SpectraIntTime
	widget_control, SpectraIntTimeWField, sensitive=Settings.TickSpectraIntTime
; 	widget_control, SpectraCutLengthWTick, set_value=Settings.TickSpectraCutLength
; 	widget_control, SpectraCutLengthWField, set_value=Settings.SpectraCutLength
; 	widget_control, SpectraCutLengthWField, sensitive=Settings.TickSpectraCutLength
	widget_control, SpectraFilterAWTick, set_value=Settings.TickSpectraFilter(0)
	widget_control, SpectraFilterAWField, set_value=Settings.SpectraFilter(0)
	widget_control, SpectraFilterAWField, sensitive=Settings.TickSpectraFilter(0)
	widget_control, SpectraFilterBWTick, set_value=Settings.TickSpectraFilter(1)
	widget_control, SpectraFilterBWField, set_value=Settings.SpectraFilter(1)
	widget_control, SpectraFilterBWField, sensitive=Settings.TickSpectraFilter(1)
	widget_control, SpectraFilterOrderWTick, set_value=Settings.TickSpectraFilterOrder
	widget_control, SpectraFilterOrderWField, set_value=Settings.SpectraFilterOrder
	widget_control, SpectraFilterOrderWField, sensitive=Settings.TickSpectraFilterOrder
	widget_control, SpectraWindowWPick, set_value=Settings.PickWindow
	widget_control, TimeFileOffOnWPick, set_value=Settings.PickTimeFileOffOn
	widget_control, SpectraNoiseLevelWTick, set_value=Settings.TickSpectraNoiseLevel 
	AddMessage2LogString, 'Configuration loaded.'
    end
    LoadDATConfigWButton: begin
        AddMessage2LogString, 'Please choose file from window.'
        tmp=dialog_pickfile(dialog_parent=event.top, /fix_filter, filter=['*.dat'], /must_exist)
        AddMessage2LogString, 'Loading configuration...'
        
        Settings.ConfigFileDAT = tmp
        
        if ((tmp = local_default('datapath', config_file=Settings.ConfigFileDAT, /silent)) ne '') then begin
          Settings.DataPath=tmp
          widget_control, DataPathWField, set_value=Settings.DataPath
        endif 
 
        if ((tmp = local_default('gui_shotnumber', config_file=Settings.ConfigFileDAT, /silent)) ne '') then begin
          Settings.ShotNumber=long(tmp)
          widget_control, ShotNumberWField, set_value=Settings.ShotNumber
        endif
       
        if ((tmp = local_default('data_source', config_file=Settings.ConfigFileDAT, /silent)) ne '') then begin
          Settings.DataSource=fix(tmp)
          widget_control, DataSourceWDroplist, set_droplist_select=Settings.DataSource
        endif
         
        if ((tmp = local_default('taurange_start', config_file=Settings.ConfigFileDAT, /silent)) ne '') then begin
          Settings.TauRange(0)=float(tmp)
          widget_control, TauRangeAWField, set_value=Settings.TauRange(0)
        endif
              
        if ((tmp = local_default('taurange_end', config_file=Settings.ConfigFileDAT, /silent)) ne '') then begin
          Settings.TauRange(1)=float(tmp)
          widget_control, TauRangeBWField, set_value=Settings.TauRange(1)
        endif

	AddMessage2LogString, 'Configuration loaded.'
    end
    
    
    SaveOutputWField: begin
	widget_control, SaveOutputWField, get_value=tmp
	Settings.SaveOutputString=tmp
    end
    SaveOutputBrowseWButton: begin
	filename=Settings.SaveOutputString
        tmp=dialog_pickfile(dialog_parent=event.top, /fix_filter, filter=['*.sav'], /overwrite_prompt, /write, file=filename)
        Settings.SaveOutputString=tmp
        widget_control, SaveOutputWField, set_value=Settings.SaveOutputString
    end
    SaveOutputWButton: begin
        widget_control, SaveOutputWField, get_value=tmp
        Settings.SaveOutputString=tmp
        if ((Settings.SaveOutputString eq '') and (Settings.AutoOrCross eq 0)) then begin
          Settings.SaveOutputString = dir_f_name('gui', (i2str(Settings.ShotNumber)+'_'+Settings.Channel1 +'_AUTO_out.sav'))
        endif
        if ((Settings.SaveOutputString eq '') and (Settings.AutoOrCross eq 1)) then begin
          Settings.SaveOutputString = dir_f_name('gui', (i2str(Settings.ShotNumber)+'_'+Settings.Channel1 + '-' + Settings.Channel2 +'_CROSS_out.sav'))
        endif
        AddMessage2LogString, "Saving output data (time, tau, corr, spectrum, phase, etc)... This may take a few seconds. Please wait a moment!"
        ShotNumber=Settings.ShotNumber
        OutRawTime=*Settings.OutRawTime
        outRawData=*Settings.outRawData
        outTau=*Settings.outTau
        outCorr=*Settings.outCorr
        outFreqScale=*Settings.outFreqScale
        outPower=*Settings.outPower
        outSpectrum=*Settings.outSpectrum
        outPhase=*Settings.outPhase
        file=Settings.SaveOutputString
        save, ShotNumber, OutRawTime, outRawData, outTau, outCorr, outFreqScale, outPower, outSpectrum, outPhase, file=file
        AddMessage2LogString, 'Output data is saved to ' + Settings.SaveOutputString + '.'
    end
    SaveJPGWField: begin
	widget_control, SaveJPGWField, get_value=tmp
	Settings.SaveJPGString=tmp
    end
    SaveJPGBrowseWButton: begin
	filename=Settings.SaveJPGString
        tmp=dialog_pickfile(dialog_parent=event.top, /fix_filter, filter=['*.jpg'], /overwrite_prompt, /write, file=filename)
        Settings.SaveJPGString=tmp
        widget_control, SaveJPGWField, set_value=Settings.SaveJPGString
    end
    SaveJPGWButton: begin
        widget_control, SaveJPGWField, get_value=tmp
        Settings.SaveJPGString=tmp
    	if (Settings.SaveJPGString eq '') then begin
	  Settings.SaveJPGString=i2str(Settings.ShotNumber)+'_'+Settings.Channel1
	  if ((Settings.AutoOrCross eq 1) and (Settings.FlagLastPlot ne 1)) then begin
	    Settings.SaveJPGString=Settings.SaveJPGString+'_'+Settings.Channel2
	  end
	  if (Settings.FlagLastPlot eq 1) then begin
		Settings.SaveJPGString=Settings.SaveJPGString+'_RawSignal'
	  end
	  if (Settings.FlagLastPlot eq 2) then begin ; PlotCorrPro
		if ((Settings.AutoOrCross eq 0) and (Settings.CovCorr eq 0)) then begin
		  Settings.SaveJPGString=Settings.SaveJPGString+'_AutoCov'
		end
		if ((Settings.AutoOrCross eq 0) and (Settings.CovCorr eq 1)) then begin
		  Settings.SaveJPGString=Settings.SaveJPGString+'_AutoCorr'
		end
		if ((Settings.AutoOrCross eq 1) and (Settings.CovCorr eq 0)) then begin
		  Settings.SaveJPGString=Settings.SaveJPGString+'_CrossCov'
		end
		if ((Settings.AutoOrCross eq 1) and (Settings.CovCorr eq 1)) then begin
		  Settings.SaveJPGString=Settings.SaveJPGString+'_CrossCorr'
		end
	  end
	  if (Settings.FlagLastPlot eq 3) then begin ; PlotCorrPro
		if ((Settings.AutoOrCross eq 0) and (Settings.PickSpectraCoh eq 0)) then begin
		  Settings.SaveJPGString=Settings.SaveJPGString+'_AutoSpectra'
		end
		if ((Settings.AutoOrCross eq 0) and (Settings.PickSpectraCoh eq 1)) then begin
		  Settings.SaveJPGString=Settings.SaveJPGString+'_AutoCoh'
		end
		if ((Settings.AutoOrCross eq 1) and (Settings.PickSpectraCoh eq 0)) then begin
		  Settings.SaveJPGString=Settings.SaveJPGString+'_CrossSpectra'
		end
		if ((Settings.AutoOrCross eq 1) and (Settings.PickSpectraCoh eq 1)) then begin
		  Settings.SaveJPGString=Settings.SaveJPGString+'_CrossCoh'
		end
	  end
	  if (Settings.FlagLastPlot eq 4) then begin ; PlotCorrPro
		if ((Settings.AutoOrCross eq 0) and (Settings.PickSpectraCoh eq 0)) then begin
		  Settings.SaveJPGString=Settings.SaveJPGString+'_AutoSpectraPhase'
		end
		if ((Settings.AutoOrCross eq 0) and (Settings.PickSpectraCoh eq 1)) then begin
		  Settings.SaveJPGString=Settings.SaveJPGString+'_AutoCohPhase'
		end
		if ((Settings.AutoOrCross eq 1) and (Settings.PickSpectraCoh eq 0)) then begin
		  Settings.SaveJPGString=Settings.SaveJPGString+'_CrossSpectraPhase'
		end
		if ((Settings.AutoOrCross eq 1) and (Settings.PickSpectraCoh eq 1)) then begin
		  Settings.SaveJPGString=Settings.SaveJPGString+'_CrossCohPhase'
		end
	  end
	  Settings.SaveJPGString=Settings.SaveJPGString+'.jpg'
	  Settings.SaveJPGString=dir_f_name('gui', Settings.SaveJPGString)
	end
    
        write_jpeg, Settings.SaveJPGString, TVRD(), Quality=100
        AddMessage2LogString, 'Plot saved to ' + Settings.SaveJPGString
    end
    SaveEPSWField: begin
	widget_control, SaveEPSWField, get_value=tmp
	Settings.SaveEPSString=tmp
    end
    SaveEPSBrowseWButton: begin
	filename=Settings.SaveEPSString
        tmp=dialog_pickfile(dialog_parent=event.top, /fix_filter, filter=['*.eps'], /overwrite_prompt, /write, file=filename)
        Settings.SaveEPSString=tmp
        widget_control, SaveEPSWField, set_value=Settings.SaveEPSString
    end
    SaveEPSWButton: begin
	; http://slugidl.pbworks.com/w/page/37657179/Writing%20to%20a%20PS%20File
	XS=9
	YS=6
	widget_control, SaveEPSWField, get_value=tmp
        Settings.SaveEPSString=tmp
	if (Settings.SaveEPSString eq '') then begin
	  Settings.SaveEPSString=i2str(Settings.ShotNumber)+'_'+Settings.Channel1
	  if ((Settings.AutoOrCross eq 1) and (Settings.FlagLastPlot ne 1)) then begin
	    Settings.SaveEPSString=Settings.SaveEPSString+'_'+Settings.Channel2
	  end
	  if (Settings.FlagLastPlot eq 1) then begin
		Settings.SaveEPSString=Settings.SaveEPSString+'_RawSignal'
	  end
	  if (Settings.FlagLastPlot eq 2) then begin ; PlotCorrPro
		if ((Settings.AutoOrCross eq 0) and (Settings.CovCorr eq 0)) then begin
		  Settings.SaveEPSString=Settings.SaveEPSString+'_AutoCov'
		end
		if ((Settings.AutoOrCross eq 0) and (Settings.CovCorr eq 1)) then begin
		  Settings.SaveEPSString=Settings.SaveEPSString+'_AutoCorr'
		end
		if ((Settings.AutoOrCross eq 1) and (Settings.CovCorr eq 0)) then begin
		  Settings.SaveEPSString=Settings.SaveEPSString+'_CrossCov'
		end
		if ((Settings.AutoOrCross eq 1) and (Settings.CovCorr eq 1)) then begin
		  Settings.SaveEPSString=Settings.SaveEPSString+'_CrossCorr'
		end
	  end
	  if (Settings.FlagLastPlot eq 3) then begin ; PlotCorrPro
		if ((Settings.AutoOrCross eq 0) and (Settings.PickSpectraCoh eq 0)) then begin
		  Settings.SaveEPSString=Settings.SaveEPSString+'_AutoSpectra'
		end
		if ((Settings.AutoOrCross eq 0) and (Settings.PickSpectraCoh eq 1)) then begin
		  Settings.SaveEPSString=Settings.SaveEPSString+'_AutoCoh'
		end
		if ((Settings.AutoOrCross eq 1) and (Settings.PickSpectraCoh eq 0)) then begin
		  Settings.SaveEPSString=Settings.SaveEPSString+'_CrossSpectra'
		end
		if ((Settings.AutoOrCross eq 1) and (Settings.PickSpectraCoh eq 1)) then begin
		  Settings.SaveEPSString=Settings.SaveEPSString+'_CrossCoh'
		end
	  end
	  if (Settings.FlagLastPlot eq 4) then begin ; PlotCorrPro
		if ((Settings.AutoOrCross eq 0) and (Settings.PickSpectraCoh eq 0)) then begin
		  Settings.SaveEPSString=Settings.SaveEPSString+'_AutoSpectraPhase'
		end
		if ((Settings.AutoOrCross eq 0) and (Settings.PickSpectraCoh eq 1)) then begin
		  Settings.SaveEPSString=Settings.SaveEPSString+'_AutoCohPhase'
		end
		if ((Settings.AutoOrCross eq 1) and (Settings.PickSpectraCoh eq 0)) then begin
		  Settings.SaveEPSString=Settings.SaveEPSString+'_CrossSpectraPhase'
		end
		if ((Settings.AutoOrCross eq 1) and (Settings.PickSpectraCoh eq 1)) then begin
		  Settings.SaveEPSString=Settings.SaveEPSString+'_CrossCohPhase'
		end
	  end
	  Settings.SaveEPSString=Settings.SaveEPSString+'.eps'
	  Settings.SaveEPSString=dir_f_name('gui', Settings.SaveEPSString)
	end
	
	if (Settings.FlagLastPlot eq 1) then begin
	  rpsopen, Settings.SaveEPSString, /encap, xs=XS, ys=YS, /inches
	  PlotRawSignalPro
	  rpsclose
	end
	if (Settings.FlagLastPlot eq 2) then begin
	  rpsopen, Settings.SaveEPSString, /encap, xs=XS, ys=YS, /inches
	  PlotCorrPro
	  rpsclose
	end
	if (Settings.FlagLastPlot eq 3) then begin
	  rpsopen, Settings.SaveEPSString, /encap, xs=XS, ys=YS, /inches
	  PlotSpectraPro
	  rpsclose
	end
	if (Settings.FlagLastPlot eq 4) then begin
	  rpsopen, Settings.SaveEPSString, /encap, xs=XS, ys=YS, /inches
	  PlotSpectraCrossPhasePro
	  rpsclose
	end
	  ErrorStr=''
	if (Settings.FlagLastPlot eq 0) then begin
	  ErrorStr='There is no plot to save.'
	end
	AddError2LogString, ErrorStr, ('Plot saved to ' + Settings.SaveEPSString) 
    end
    
    FeaturesWButton: begin
        AddMessage2LogString, 'Coming soon... '
    
    end
    
    
    CommandLineWButton: begin
	AddMessage2LogString, 'Now you can write to command line'
	AddMessage2LogString, "If you wish to return to graphical user interface, type '.c'!"
	AddMessage2LogString, "Don't use GUI until you typed '.c'."
	stop
	AddMessage2LogString, 'You can use graphical user interface again.'
	
    end
    ExitWButton: begin
	AddMessage2LogString, 'Thank you for using our software.'
	wait, 0.5
	widget_control, event.top, /destroy
    end
  end
end