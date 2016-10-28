pro write_shot_config_kstar,shot,ADC_mult=ADC_mult,ADC_div=ADC_div,samplediv=samplediv,samplenumber=samplenumber,$
    bits=bits,trigger=trigger,channel_masks=channel_masks,mirror_pos=mirror_pos,filter_pos=filter_pos,$
        filter_temp=filter_temp, apd_pos=apd_pos,datapath=datapath,hv=hv,detector_temp=detector_temp

default,datapath,local_default('datapath')
default,detector_temp,0
default,hv,0
default,channel_masks,[255,255,255,255]
default,ADC_mult,20
default,ADC_div,40
default,bits,12

;mirror_pos: 'Close', 'Remote'
;camera_select: 'APDCAM' 'EDICAM'

oConfig = OBJ_NEW('IDLffXMLDOMDocument')
oShotSettings = oConfig->CreateElement('ShotSettings')
oShotSettings->SetAttribute,'ShotNumber',i2str(shot)
oShotSettings->SetAttribute,'Experiment','KSTAR BES'
oShotSettings->SetAttribute,'Version','1.0'
oVoid = oConfig->AppendChild(oShotSettings)

oOptics = oConfig->CreateElement('Optics')
oChild = oConfig->CreateElement('MirrorPosition')
oChild->SetAttribute,'Value',mirror_pos
oChild->SetAttribute,'Type','integer'
oChild->SetAttribute,'Unit','None'
oChild->SetAttribute,'Comment','Rotatable mirror setting'
oVoid = oOptics->AppendChild(oChild)

oChild = oConfig->CreateElement('FilterPosition')
oChild->SetAttribute,'Value',filter_pos
oChild->SetAttribute,'Type','integer'
oChild->SetAttribute,'Unit','None'
oChild->SetAttribute,'Comment','The position of the filter rotation stepmotor.'
oVoid = oOptics->AppendChild(oChild)

oChild = oConfig->CreateElement('Filter temperature')
oChild->SetAttribute,'Value',filter_temp
oChild->SetAttribute,'Type','integer'
oChild->SetAttribute,'Unit','None'
oChild->SetAttribute,'Comment','The temperature of the filter'
oVoid = oOptics->AppendChild(oChild)

oChild = oConfig->CreateElement('APDCAM position')
oChild->SetAttribute,'Value',apd_pos
oChild->SetAttribute,'Type','integer'
oChild->SetAttribute,'Unit','None'
oChild->SetAttribute,'Comment','The position of the APDCAM stepmotor'
oVoid = oOptics->AppendChild(oChild)

oVoid = oShotSettings->AppendChild(oOptics)

oAPDCAM = oConfig->CreateElement('APDCAM')
oChild = oConfig->CreateElement('DetectorBias')
oChild->SetAttribute,'Value',i2str(hv)
oChild->SetAttribute,'Type','int'
oChild->SetAttribute,'Unit','V'
oChild->SetAttribute,'Comment','Detector bias voltage.'
oVoid = oAPDCAM->AppendChild(oChild)

oChild = oConfig->CreateElement('DetectorTemp')
oChild->SetAttribute,'Value',string(detector_temp,format='(F4.1)')
oChild->SetAttribute,'Type','float'
oChild->SetAttribute,'Unit','C'
oChild->SetAttribute,'Comment','Detector measured temperature.'
oVoid = oAPDCAM->AppendChild(oChild)

oVoid = oShotSettings->AppendChild(oAPDCAM)

oADC = oConfig->CreateElement('ADCSettings')

oChild = oConfig->CreateElement('Trigger')
oChild->SetAttribute,'Value',string(trigger)
oChild->SetAttribute,'Type','float'
oChild->SetAttribute,'Unit','s'
oChild->SetAttribute,'Comment','Trigger:  <0: manual,otherwise external with this delay'
oVoid = oADC->AppendChild(oChild)

oChild = oConfig->CreateElement('ADCMult')
oChild->SetAttribute,'Value',i2str(ADC_Mult)
oChild->SetAttribute,'Type','int'
oChild->SetAttribute,'Unit','None'
oVoid = oADC->AppendChild(oChild)

oChild = oConfig->CreateElement('ADCDiv')
oChild->SetAttribute,'Value',i2str(ADC_Div)
oChild->SetAttribute,'Type','int'
oChild->SetAttribute,'Unit','None'
oVoid = oADC->AppendChild(oChild)

oChild = oConfig->CreateElement('Samplediv')
oChild->SetAttribute,'Value',i2str(samplediv)
oChild->SetAttribute,'Type','int'
oChild->SetAttribute,'Unit','None'
oVoid = oADC->AppendChild(oChild)

oChild = oConfig->CreateElement('SampleNumber')
oChild->SetAttribute,'Value',i2str(samplenumber)
oChild->SetAttribute,'Type','long'
oChild->SetAttribute,'Unit','None'
oVoid = oADC->AppendChild(oChild)

for i=0,3 do begin
  oChild = oConfig->CreateElement('ChannelMask'+i2str(i+1))
  oChild->SetAttribute,'Value',i2str(channel_masks[i])
  oChild->SetAttribute,'Type','int'
  oChild->SetAttribute,'Unit','none'
  oChild->SetAttribute,'Comment','The channel mask for ADC block '+i2str(i+1)+'. Each bit isone channel.'
  oVoid = oADC->AppendChild(oChild)
endfor

oChild = oConfig->CreateElement('Bits')
oChild->SetAttribute,'Value',i2str(bits)
oChild->SetAttribute,'Type','int'
oChild->SetAttribute,'Unit','None'
oChild->SetAttribute,'Comment','The bit resolution of the ADC.'
oVoid = oADC->AppendChild(oChild)

oVoid = oShotSettings->AppendChild(oADC)


oConfig->Save, FILENAME=dir_f_name(datapath,i2str(shot)+'_config.xml')
OBJ_DESTROY, oConfig

end