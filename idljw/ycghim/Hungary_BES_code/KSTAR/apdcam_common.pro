common apdcam_common,ADC_board,PC_board,apd_find_widg,stop_widg,apd_widg,apd_id_widg,$
                 apd_hv_widg,apd_control_hv_widg,apd_hv1val_widg,apd_hv2val_widg,$
                 apd_hv1max_widg,apd_hv2max_widg,apd_hvread_widg,apd_hv1mon_widg,apd_hv2mon_widg,$
                 apd_hvenable_widg,apd_hvdisable_widg,apd_hvmess_widg,apd_hv1on_widg,apd_hv1off_widg,apd_hv2on_widg,$
                 apd_hv2off_widg,apd_hvedstat_widg,apd_shopen_widg,apd_shclose_widg,apd_getoffs_widg,apd_setdac_widg,apd_offs_act_widg,$
                 apd_offset_mess_widg,apd_offs_widg,measdata,apd_dac_widg,apd_getdac_widg,apd_dataplot_widg,apd_meas_widg,$
                 apd_meas_mess_widg,apd_data_widg,plot_window,apd_temp_widg,apd_temps_widg,apd_weights_widg,apd_readtemp_widg,$
                 apd_readweights_widg,apd_stoptemp_widg,read_temp_flag,apd_fanspeed_widg,apd_fanlimit_widg,$
                 apd_fancontrol_widg,apd_pelt_out_widg,apd_pelt_ref_widg,apd_pelt_control_widg,apd_fan1_diff_widg,$
                 apd_temp_weights,apd_temps,apd_fanmode_widg,fanmode,apd_pelt_pfact_widg,apd_pelt_ifact_widg,apd_pelt_dfact_widg,$
                 apd_timing_widg,apd_pllmult_widg,apd_plldiv_widg,apd_streammult_widg,apd_streamdiv_widg,apd_control_widg,$
                 apd_readtiming_widg,apd_samplenum_widg,apd_trigger_widg,apd_triglevel_widg,apd_inttrig_opt_widg,$
                 apd_meas_count_widg,meas_samplenum,apd_ovdlevel_widg,apd_ovdtime_widg,apd_ovdstat_widg,apd_reset_widg,$
                 apd_samplediv_widg,apd_setalldac_same_widg,apd_pc_reset_widg,apd_rmsHF_act_widg,apd_rmsLF_act_widg,apd_pp_act_widg,$
                 apd_extclkmult_widg, apd_extclkdiv_widg,apd_trigdelay_widg,apd_filtercoeff_widg,apd_filtercoeff_int_widg,$
                 apd_filterfreq_widg,apd_filterfreq_int_widg,apd_ch1_widg,apd_ch2_widg,apd_ch3_widg,apd_ch4_widg,apd_resolution_widg,$
                 apd_challon_widg,apd_challoff_widg,apd_channels_widg,apd_testpattern_widg,apd_filterdiv_widg,apd_filtergain_widg,$
                 apd_power_widg,meas_timerange,apd_clksatus_widg,apd_pc_error_widg,apd_adc_error_widg,apd_ringbufsize_widg,$
                 apd_shmode_widg,apd_intcount_widg,apd_intcount,apd_callight_widg,apd_gain_v1_widg,apd_gain_v2_widg,apd_gaintest_widg,apd_gain_light_widg,$
                 apd_meas_load_widg,offline,apd_ftype_log_widg,apd_frange1_widg,apd_frange2_widg,apd_fres_widg,apd_prange1_widg,apd_prange2_widg,$
                 apd_spareio2_widg,apd_spareio1_widg,kstar_widg,kstar_shot_widg,kstar_start_widg,kstar_stop_widg,$
                 kstar_dataplot_widg,kstar_plot_window,kstar_stop_flag,meas_running,kstar_status_widg, program_running, apd_spareio3_widg,apd_spareio4_widg



common apd_registers,ADC_REG_MC_VERSION,ADC_REG_SERIAL,ADC_REG_FPGA_VERSION,ADC_REG_STATUS1,ADC_REG_STATUS2,$
  ADC_REG_CONTROL,ADC_REG_ADSAMPLEDIV,ADC_REG_ADCCLKMUL,ADC_REG_ADCCLKDIV,ADC_REG_STREAMCLKMUL,ADC_REG_STREAMCLKDIV,ADC_REG_STREAMCONTROL,$
  ADC_REG_SAMPLECNT,ADC_REG_CHENABLE1,ADC_REG_CHENABLE2,ADC_REG_CHENABLE3,ADC_REG_CHENABLE4,ADC_REG_RINGBUFSIZE,$
  ADC_REG_RESOLUTION,ADC_REG_AD1TESTMODE,ADC_REG_AD2TESTMODE,ADC_REG_AD3TESTMODE,ADC_REG_AD4TESTMODE,ADC_REG_MAXVAL11,$
  ADC_REG_ACTSAMPLECH1,ADC_REG_ACTSAMPLECH2,ADC_REG_ACTSAMPLECH3,ADC_REG_ACTSAMPLECH4,ADC_REG_TRIGGER,$
  ADC_BIT_CTRL_EXTCLOCK,ADC_BIT_CTRL_CLOCKOUT_ENABLE,ADC_BIT_CTRL_TRIGGER_LH,ADC_BIT_CTRL_TRIGGER_HL,ADC_BIT_CTRL_TRIGGER_MAX,ADC_BIT_CTRL_PREAMBLE,$
  PC_REG_HV1SET,PC_REG_HV2SET,PC_REG_HV1MON,PC_REG_HV2MON,PC_REG_HV1MAX,PC_REG_HV2MAX,PC_REG_HVENABLE,PC_REG_HVON,$
  PC_REG_SHSTATE,ADC_REG_DAC1,PC_REG_TEMP_SENSOR_1,PC_REG_TEMP_CONTROL_WEIGHTS_1,PC_REG_FAN1_CONTROL_WEIGHTS_1,$
  PC_REG_FAN2_CONTROL_WEIGHTS_1,PC_REG_FAN3_CONTROL_WEIGHTS_1,PC_REG_FAN1_SPEED,PC_REG_FAN1_TEMP_SET,PC_REG_FAN1_TEMP_DIFF,$
  PC_REG_FAN2_TEMP_LIMIT,PC_REG_FAN3_TEMP_LIMIT,PC_REG_PELT_CTRL,PC_REG_DETECTOR_TEMP_SET,PC_REG_P_GAIN,PC_REG_I_GAIN,PC_REG_D_GAIN,$
  ADC_REG_OVDLEVEL,ADC_REG_OVDSTATUS,ADC_REG_RESET,ADC_REG_OVDTIME,PC_REG_BOARD_SERIAL,PC_REG_RESET,$
  PC_REG_FACTORY_WRITE,ADC_REG_EXTCLKMUL,ADC_REG_EXTCLKDIV,ADC_REG_TRIGDELAY,ADC_REG_COEFF_01,ADC_REG_COEFF_INT,ADC_REG_BPSCH1,HV_CALFAC,$
  PC_REG_ERRORCODE,ADC_REG_ERRORCODE,PC_REG_SHMODE,PC_REG_CALLIGHT,ADC_REG_SPAREIO

common kstar_data,shotnumber,Mirror_Positions, Camera_Select_States



  forward_function read_apd_register

