function default_mse_2013_settings, blk_shot = blk_shot
default, blk_shot, -1

  return, {  $
            tree: 'mse_2013', $
            kstar_tree: 'kstar', $
            raw_im_node: '.pco_camera:images', $
            im_node: '.pco_camera:images', $
            filter: 'circle', $
            comment: '',$
            raw_bin: 4,$
            reg_shot: 8986, $
            cal_shot: 172, $
            blk_shot: blk_shot, $
            blk0: 1,  $; first black frame
            blk1: 1,  $; final black frame
            post_bin: 1, $  ; be careful of this - it can introduce mismatch between array sizes
            period: 26., $
            demod_offset: 0, $  ;usually zero - a correction for some of the earlier shots
            Ref_blank: [0.,0.], $  ; timebounds within which Doppler phase reference FLC steps are ignored.  These are the "off states".  Allows to bypass noisy Doppler regions
            Ref_mode: 0, $  ; Ref phase demod mode -1: frame to left, 0 left&right, +1 right
            bw: 0.5, $      ; as a fraction of the carrier
            taper: 80, $
            threshold: 250., $
            dt: 40., $  ; external frame trigger period
            t0: -80., $ ;start time for sequence in ms
            frame_offset: 0., $
            xr: [1.5, 2.35], $  ; plot xrange bounds
            yr: [-.4,.4], $  ;plot yrange bounds
            zr: [-10., 10], $ ; Thet theta bounds
            nstddev: 3., $
            td_median: 1, $
            nmedian: 11 $
 }

 end