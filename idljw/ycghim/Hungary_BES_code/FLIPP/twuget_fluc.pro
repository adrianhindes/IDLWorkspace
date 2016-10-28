;+
; NAME:
;   TWUget_fluc
;
; NOTE:
;   This routine has been derived from the original TWUget.
;   The changes are:
;   - Adaptation to call httpget always from the same directory as the TWUget_fluc program, so as httpget clients
;     are included in the same package
;   - Adaptation to hangle differernt operating systems
;
; PURPOSE:
;   The TWUget procedure provides an interface to the Textor Web
;   Umbrella (TWU) C client interface. It reads a signal (plus, optionally,
;   its abscissa signal) from a TWU webserver.
;
; CATEGORY:
;   Data Access.
;
; SYNTAX:
;   TWUGET_FLUC, [ [Abscissa,] Signal ]
;           [, PULSENUMBER=value , SIGNALNAME=string | URL=string]
;           [, SERVER=string] [, EXPERIMENT=string]
;           [, START=value] [, STEP=value] [, TOTAL=value]
;           [, UNIT=variable] [, ABSCISSAUNIT=variable]
;           [, PROPERTIES=variable] [, ABSCISSAPROPERTIES=variable]
;           [, IPROPERTIES=structure] [, IABSCISSAPROPERTIES=structure]
;           [, /VERBOSE]
;
; ARGUMENTS:
;   Abscissa:   Optional named variable to hold the abscissa (e.g., a time
;               base or radius vector). This will be a vector of type double.
;   Signal:     The named variable into which the signal data is read. This
;               will typically be a vector of type double.
;
;
; KEYWORDS:
;   PULSENUMBER:    The pulse number of the experiment to read the data from. If this
;               keyword is not of type string, it is converted to long integer format.
;
;   SIGNALNAME: The string containing the signalname to read, of the form 'star/curr'
;               or 'fom/ecrh/diag/ecrh/signals/signal3'
;
;   URL:        Instead of specifying PULSENUMBER and SIGNALNAME, this keyword can be
;               used to pass in the complete URL of (the property page of) the signal
;               to be read. Overrides also the EXPERIMENT and SERVER keywords.
;               E.g. 'http://ipptwu.ipp.kfa-juelich.de/textor/all/91082/star/curr'
;
;   SERVER:     The TWU server to read from. Defaults to 'ipptwu.ipp.kfa-juelich.de'.
;
;   EXPERIMENT: The experiment to which the signal belongs. Defaults to 'textor'.
;
;   START, STEP, TOTAL: Query options for selective reading of large signals.
;
;   UNIT, ABSCISSAUNIT: On output, will contain the value of the "Unit" properties.
;
;   PROPERTIES, ABSCISSAPROPERTIES: Output the TWU properties of the signal and the
;               (first) abscissa as an anonymous structure. Structure tag names are the
;               keyword values with dots (".") replaced by underscores ("_").
;
;   IPROPERTIES, IABSCISSAPROPERTIES: Can be used to input previously read TWU property
;               structures, thus saving a new HTTP call.
;
;   /VERBOSE    Print informational messages. Not fully implemented yet.
;
;
;
; RESTRICTIONS:
;   Currently only up to three-dimensional signals are handled.
;   No error checking is being done yet!!
;   This procedure makes use of the httpget
;   C routine by Jon Krom. The user must be able to run "httpget" from
;   the system command line, or set the full path for this executable in the
;   TWUget_httpget subroutine.
;   This routine has not yet been tested under any other OS than Unix and Windows. It will
;   certainly need adaptions for Mac, and probably for VMS as well.
;
; DEPENDENCIES:
;   Needs acces to an 'httpget' client executable.
;   See also the remark at the property parsing routine TWUget_parseProperties.
;
;
; EXAMPLE:
;   To read the plasma current for pulsenumber 90192, enter:
;
;       TWUGET, Time, Current, PULSENUMBER = 90192, SIGNALNAME = 'star/curr'
;
;
; AUTHOR CONTACT INFORMATION:
;   Comments, wishes, extensions, bug reports, etc. are all very welcome, although
;   I may not have time available to deal with them properly.
;   Email them to gorkom@rijnh.nl or to j.c.van.gorkom@fz-juelich.de .
;   Questions or comments regarding the TEC Web Umbrella are best put
;   to Jon Krom, j.krom@fz-juelich.de .
;
; MODIFICATION HISTORY:
;   Written by:         Jaco van Gorkom, 4 December 2000
;   March 25, 2002      Stripped off most fancy but unnecessary features.
;   JvG                 Fixed some minor bugs.
;   April 3, 2002       Adapted to use the httpget client. Integrated property parsing.
;   JvG                 Incorporated local calculation of equidistant signals.
;                       Added query support and i/Properties keywords.
;                       Updated documentation.
;   September 6, 2002   Added limited support for signals of up to three dimensions.
;   JvG                 This is a bit of a hack, and not documented yet.
;
;-

function TWUget_httpget, url, seed, count=count, direct=direct, verbose=verbose
; Sucks down the data at URL into a string array of COUNT elements, or of size and
; shape as the "seed" argument. /DIRECT may be specified if no http gadgets like
; redirection are expected, then the SOCKET procedure is used instead of spawning httpget.
; Note: /DIRECT is currently ignored, since it seems to be slower then httpget.
; This routine probably needs to be written OS-dependent.

    compile_opt idl2, hidden

;*********************************************************************************************
; This part is for fluc_proc, it automatically selects the httpget client, its path and arguments
; Can be used on various operating system: Linux and Windows
; First we determine the path of this TWUGET_FLUC.PRO
  info = routine_info('twuget_fluc',/source)
  twuget_path = info.path
  twuget_path = strmid(twuget_path,0,strlen(twuget_path)-strlen('twuget_fluc.pro')-1)


; Selecting the httpget client for the operating system
; For windows
  if (strupcase(!version.os) eq 'WIN32') then begin
    client = dir_f_name(twuget_path,'httpget.exe')
    wget_options = ' -q --output-document=-'
  endif

 ; Linux stuff (maybe needs to be adapted to other Unix systems
  if (strupcase(!version.os) eq 'LINUX') then begin
    client = dir_f_name(twuget_path,'httpget')
    wget_options = ' '
  endif

  if (not defined(client)) then begin
    print,'Unknown operating system.'
    return,0
  endif
;*********************************************************************************************

    ; ignore /DIRECT keyword
    ;if keyword_set(direct) and $
    ; ( (!version.os_family eq 'Windows') or (!version.os_family eq 'unix') ) then $
    ;  RETURN, TWUget_httpgetDirect(url, seed, verbose=verbose)


    ; Added options for fluc_proc
    verbose=1
    cmd = client+' "'+url+'"'+' '+wget_options
    if keyword_set(verbose) then $
      print, 'spawning command: '+cmd
    spawn, cmd, result, count=count
    if keyword_set(verbose) then $
      print, 'received '+strtrim(count, 2)+' lines. First line follows:  '+result[0]

    ; if a seed array was passed, then convert to that data type and dimensions.
    if n_elements(seed) ne 0 then begin
        result = fix(temporary(result), type=size(seed, /type), /print)
        result = reform(result, size(seed, /dimensions), /overwrite)
    endif

    return, result

end     ; TWUget_httpget


function TWUget_httpgetDirect, url, seed, verbose=verbose
; As TWUget_httpget: sucks down the data at URL into a string array of COUNT elements,
; or of size and shape as the "seed" argument.
; Uses the SOCKET procedure, available only on Unix and Windows OS.
; This does not follow up all kinds of http redirections, hence "Direct".

   compile_opt idl2, hidden

   if n_elements(seed) ne 0 then $
    result = temporary(seed)

   slashpos = strsplit(url, '/')
   proxyhost = strmid(url, slashpos[1], slashpos[2]-slashpos[1]-1)
   requestUrl = strmid(url, slashpos[2]-1)
   proxyport = 80
   connect_timeout = 10

   socket, lun, proxyhost, proxyport, /get_lun, $
    width=250, connect_timeout=connect_timeout
   if keyword_set(verbose) then $
    print, 'Connected to host ' + proxyhost + $
     ' on port ' + strtrim(proxyport, 2)

   get_cmd = 'GET ' + requestUrl
   printf, lun, get_cmd
   if keyword_set(verbose) then $
    print, 'Sending request: ' + get_cmd
   transferstart = systime(/seconds)

   txt = 'string'
   if n_elements(result) ne 0 then $    ; a seed array was passed
     readf, lun, result $
   else $                               ; read as string array
    while not EOF(lun) do begin
      readf, lun, txt
      if keyword_set(verbose) then $
       print, txt
      if n_elements(result) eq 0 then $
       result = txt $
      else $
       result = [result, txt]
    endwhile
   free_lun, lun
   transfertime = systime(/seconds) - transferstart
   if keyword_set(verbose) then $
    print, 'Received ' + strtrim(n_elements(result), 2) + $
     ' lines in ' + strtrim(transfertime,2) + ' seconds.'

   return, result

end   ; TWUget_httpgetDirect


function TWUget_tag_valid, structure, tag
; Check whether the string TAG is a valid tagname for STRUCTURE.

    compile_opt idl2, hidden

    validNames = tag_names(structure)
    ind = where(validNames eq strupcase(tag), count)

    return, count eq 1

end     ; TWUget_tag_valid


function TWUget_parseProperties, propertytext, castValues=castValues

    compile_opt idl2, hidden

    ; Parses the so-called properties of a Textor Web Umbrella (TWU) signal into an
    ; anonymous IDL-structure containing the keyword-value pairs. Dots (`.') in
    ; keyword names are replaced by underscore characters (`_'). Values are
    ; interpreted as FLOATs or LONGs if possible to do so, else retained as strings.
    ; Propertytext should be an array of strings as read from one of the TWU servers.
    ; Designed for TWU properties version `0.6.0.2' (which, by the way, would be
    ; returned as a string) and for version 0.7 (which would be returned as a
    ; float; note this caveat of the conversion strategy!).
    ; If an error is encountered, the scalar string `Not OK' is returned.

    ; Note: the typecasting to FLOATs or LONGs is only done if /CASTVALUES is set.
    ; Else (and by default) the values are retained as strings.

    ; Version 1.0 by Jaco van Gorkom (gorkom@rijnh.nl), 2 July 2001
    ; for TWU properties versions `0.6.0.2' and `0.7'
    ; April 2, 2002 JvG:    Separated out the procedure TWUproperties into its
    ;                       parsing (this function) and reading (TWUget) parts.

    ; Dependencies: If and only if the keyword /CASTVALUES is set, use is made of
    ; the JHU/APL/S1R library, in particular the delchr,
    ; (drop_comments), getwrd, isnumber, and nwrds routines. This library is
    ; included in the standard installation of IDL at Forschungszentrum Juelich,
    ; but its location (typically /usr/local/idl/JHUapl/ plus subdirectories) may
    ; need to be added to IDL's !PATH. Alternatively, the library is available at
    ; ftp://fermi.jhuapl.edu/pub/idl/ .
    ; Further information regarding the TWU scheme can be
    ; obtained at http://ipptwu.ipp.kfa-juelich.de.


    ; Drop the comment lines and any blank lines
    ; the following code supersedes: propertytext = drop_comments(propertytext, ignore='#')
    indNotBlank = where(propertytext ne '', count)
    if (indNotBlank[0] eq -1) then begin
        print, 'Error reading signal properties'
        return, 'Not OK'
    endif
    if count ne n_elements(propertytext) then $
     propertytext = propertytext[indNotBlank]
    firstCharacters = strmid(propertytext, 0, 1)
    indNoComments = where(firstCharacters ne '#', count)
    propertytext = propertytext[indNoComments]
    ; Parse into keyword-value pairs (separating at first colon)
    sep_pos = reform(strpos(propertytext, ':'), 1, n_elements(propertytext))
      ; reform is needed because the first dimension of sep_pos will be
      ; considered the `stride' by strmid
    keywords = strmid(propertytext, 0, sep_pos)
    values = strmid(propertytext, sep_pos+1)
    ; Drop leading and trailing whitespace
    keywords = strtrim(keywords, 2)
    values = strtrim(values, 2)

    ; Detect possible errors
    errorindices = where(keywords eq '', count)
    if count ne 0 then begin
        print, 'Encountered unexpected output. Bad lines follow:'
        print, propertytext[errorindices]
        return, 'Not OK'
    endif

    ; Create the anonymous keyword-value structure
    for i=0L, n_elements(keywords)-1L do begin
        ; Replace possible dots by underscores in keyword name
        ;   (dots are not allowed in IDL structure tag names).
        keyword = strjoin( strsplit(keywords[i], '.', /extract, /preserve_null) , '_')
        if keyword_set(castValues) then begin
            ; Convert value to LONG or FLOAT if possible to do so
            if isnumber(values[i], value) le 0 then value = values[i]
        endif else $
          value = values[i]
        if n_elements(properties) eq 0 then $
          properties = create_struct(keyword, value) $
        else $
          properties = create_struct(properties, keyword, value)
    endfor  ; i

    return, properties

end     ; TWUget_parseProperties


function TWUget_canCalculate, properties

    compile_opt idl2, hidden

    if ( twuget_tag_valid(properties, 'equidistant') $
     AND twuget_tag_valid(properties, 'dimensions') ) then begin
        canCalculate = $
         ( ( strlowcase(properties.equidistant) eq 'incrementing' ) $
         OR ( strlowcase(properties.equidistant) eq 'decrementing' ) ) AND $
         twuget_tag_valid(properties, 'signal_minimum') AND $
         twuget_tag_valid(properties, 'signal_maximum') AND $
         twuget_tag_valid(properties, 'length_dimension_0') AND $
         (long(properties.dimensions) eq 1)
     endif else $
      canCalculate = 0

    return, canCalculate

end     ; TWUget_canCalculate


function TWUget_calculate, properties, start=istart, step=istep, total=itotal

    compile_opt idl2, hidden

    ; Check keyword parameters
    if n_elements(istart) ne 0 then start = long(istart) $
     else start = 0
    if n_elements(istep) ne 0 then step = long(istep) $
     else step = 1
    if n_elements(itotal) ne 0 then total = long(itotal) $
     else total = long(properties.length_dimension_0)
    ; Make sure that no elements outside the array are calculated
    total = total < ( (long(properties.length_dimension_0) - start) / step )
    ; Note: in this place some error checking on (total le 0) could be introduced

    ; Calculate the signal
    case properties.equidistant of
        'incrementing': begin
                first = double(properties.signal_minimum)
                last = double(properties.signal_maximum)
            end
        'decrementing': begin
                first = double(properties.signal_maximum)
                last = double(properties.signal_minimum)
            end
    endcase
    nSegments = long(properties.length_dimension_0) - 1
    span = last - first

    seedArray = start + step * dindgen(total)
    data = first + (temporary(seedArray) * span) / nSegments

    return, data

end     ; TWUget_calculate


pro TWUget_fluc, W, X, Y, Z, pulsenumber=pulsenumber, signalname=isignalname, $
  start=start, step=step, total=total, $
  unit=unit, abscissaUnit=abscissa0Unit, $
  properties=signalProperties, abscissaProperties=abscissa0Properties, $
  server=server, experiment=experiment, url=url, $
  iProperties=iSignalProperties, iAbscissaProperties=iAbscissa0Properties, $
  verbose=verbose

    compile_opt idl2

    starttimer = systime(/seconds)

    ; Check arguments
    if n_elements(server) eq 0 then $
      server = 'ipptwu.ipp.kfa-juelich.de'
    if n_elements(experiment) eq 0 then $
      experiment = 'textor'
    if ((n_elements(pulsenumber) eq 0) or (n_elements(isignalname) eq 0)) $
     and (n_elements(url) eq 0) then $
      message, 'either pulsenumber and signalname, or url must be specified'
    ; Convert pulsenumber to type string if necessary
    if n_elements(pulsenumber) ne 0 then begin
        pulsenosize = size(pulsenumber)
        if pulsenosize[n_elements(pulsenosize)-2] ne 7 then $
          ipulseno = strtrim(long(pulsenumber), 2) $
        else $
          ipulseno = pulsenumber
    endif
    ; Remove leading slash from signalname, if present
    if n_elements(isignalname) ne 0 then begin
        if strmid(isignalname, 0, 1) eq '/' then $
         signalname = strmid(isignalname, 1) $
        else $
         signalname = isignalname
    endif

    ; Prepare query string
    startquery = n_elements(start) ne 0 ? 'start='+strtrim(start,2)+'&' : ''
    stepquery = n_elements(step) ne 0 ? 'step='+strtrim(step,2)+'&' : ''
    totalquery = n_elements(total) ne 0 ? 'total='+strtrim(total,2)+'&' : ''
    onlyquery = 'only'
    propertiesQuery = '?' + onlyquery
    dataQuery = '?' + startquery + stepquery + totalquery + onlyquery

    istart = n_elements(start) ne 0 ? start : 0
    istep = n_elements(istep) ne 0 ? step : 1

    ; Prepare URL string
    if n_elements(url) eq 0 then begin
        protocol = 'http://'
        group = 'all'
        signalPropertiesUrl = protocol $
         + strjoin([server, experiment, group, ipulseno, signalname], '/') $
         + propertiesQuery
    endif else $
      signalPropertiesUrl = url + propertiesQuery

    ; always at least load the signal properties (because it makes life so simple:)
    needSignalProperties = 1 ;needSignalData or $
     ;( needAbscissa0Properties and (n_elements(iAbscissa0Properties) eq 0) ) or $
     ;arg_present(signalProperties) or arg_present(unit)

    ; Get signal properties
    if needSignalProperties then begin
        if n_elements(iSignalProperties) ne 0 then $
          signalProperties = iSignalProperties $
        else begin
            datastrings = twuget_httpget(signalPropertiesUrl, verbose=verbose)
            signalProperties = twuget_parseProperties(datastrings)
            datastrings = 0b
        endelse
    endif

    ; What do we need to do?
    nDimensions = long(signalProperties.Dimensions)
    nAllParams = nDimensions + 1
    if not ( (n_params() eq 1 ) or (n_params() eq nAllParams) ) then $
      message, 'Number of arguments incorrect: must ask for all abscissae or for none at all'
    arg_present_arr = intarr(4)
    arg_present_arr[0] = arg_present(W)
    arg_present_arr[1] = arg_present(X)
    arg_present_arr[2] = arg_present(Y)
    arg_present_arr[3] = arg_present(Z)

    needSignalData = ((n_params() eq 1) and arg_present_arr[0]) or $
                 ((n_params() eq nAllParams) and arg_present_arr[nAllParams-1])
    needAbscissa0Data = (n_params() eq nAllParams) and arg_present_arr[0] $
     and (nDimensions ge 1)
    needAbscissa0Properties = needAbscissa0Data or $
     arg_present(abscissa0Properties) or arg_present(abscissa0Unit)
    needAbscissa1Data = (n_params() eq nAllParams) and arg_present_arr[1] $
     and (nDimensions ge 2)
    needAbscissa1Properties = needAbscissa1Data ; or $
     ; arg_present(abscissa1Properties) or arg_present(abscissa1Unit)
    needAbscissa2Data = (n_params() eq nAllParams) and arg_present_arr[2] $
     and (nDimensions ge 3)
    needAbscissa2Properties = needAbscissa2Data ; or $
     ; arg_present(abscissa2Properties) or arg_present(abscissa2Unit)

    ; Get abscissa properties, if needed
    if needAbscissa0Properties then begin
        if n_elements(iAbscissa0Properties) ne 0 then $
          abscissa0Properties = iAbscissa0Properties $
        else begin
            abscissa0PropertiesUrl = signalProperties.abscissa_url_0 + propertiesQuery
            datastrings = twuget_httpget(abscissa0PropertiesUrl, verbose=verbose)
            abscissa0Properties = twuget_parseProperties(datastrings)
            datastrings = 0b
        endelse
    endif
    if needAbscissa1Properties then begin
        if n_elements(iAbscissa1Properties) ne 0 then $
          abscissa1Properties = iAbscissa1Properties $
        else begin
            abscissa1PropertiesUrl = signalProperties.abscissa_url_1 + propertiesQuery
            datastrings = twuget_httpget(abscissa1PropertiesUrl, verbose=verbose)
            abscissa1Properties = twuget_parseProperties(datastrings)
            datastrings = 0b
        endelse
    endif
    if needAbscissa2Properties then begin
        if n_elements(iAbscissa2Properties) ne 0 then $
          abscissa2Properties = iAbscissa2Properties $
        else begin
            abscissa2PropertiesUrl = signalProperties.abscissa_url_2 + propertiesQuery
            datastrings = twuget_httpget(abscissa2PropertiesUrl, verbose=verbose)
            abscissa2Properties = twuget_parseProperties(datastrings)
            datastrings = 0b
        endelse
    endif

    ; Get signal data, if needed
    if needSignalData then begin
        if twuget_canCalculate(signalProperties) then $
          signalData = twuget_calculate(signalProperties, start=start, step=step, total=total) $
        else begin
            signalDataUrl = signalProperties.bulkfile_url + dataQuery
            nData = long(signalProperties.length_total) < (long(signalProperties.length_total)-istart)/istep
            if n_elements(total) ne 0 then $
             nData = nData < total
            seed = dblarr(nData)
            ; if all points are going to be read in, then make the array the correct dimensions:
            if (nData eq signalProperties.length_total) and (nDimensions gt 1) then begin
                case nDimensions of
                    2:  signalDims = [signalProperties.Length_dimension_0, $
                                      signalProperties.Length_dimension_1]
                    3:  signalDims = [signalProperties.Length_dimension_0, $
                                      signalProperties.Length_dimension_1, $
                                      signalProperties.Length_dimension_2]
                endcase
                seed = reform(seed, signalDims, /overwrite)
            endif
            signalData = twuget_httpget(signalDataUrl, seed, /direct, verbose=verbose )
            ;signalData = double(datastrings)
            ;datastrings = 0b
        endelse
    endif

    ; Get abscissa data, if needed
    if needAbscissa0Data then begin
        if twuget_canCalculate(abscissa0Properties) then $
          abscissa0Data = twuget_calculate(abscissa0Properties, start=start, step=step, total=total) $
        else begin
            abscissa0DataUrl = abscissa0Properties.bulkfile_url + dataQuery
            nData = long(abscissa0Properties.length_total) < (long(abscissa0Properties.length_total)-istart)/istep
            if n_elements(total) ne 0 then $
             nData = nData < total
            seed = dblarr(nData)
            abscissa0Data = twuget_httpget(abscissa0DataUrl, seed, /direct, verbose=verbose )
        endelse
    endif
    if needAbscissa1Data then begin
        if twuget_canCalculate(abscissa1Properties) then $
          abscissa1Data = twuget_calculate(abscissa1Properties, start=start, step=step, total=total) $
        else begin
            abscissa1DataUrl = abscissa1Properties.bulkfile_url + dataQuery
            nData = long(abscissa1Properties.length_total) < (long(abscissa1Properties.length_total)-istart)/istep
            if n_elements(total) ne 0 then $
             nData = nData < total
            seed = dblarr(nData)
            abscissa1Data = twuget_httpget(abscissa1DataUrl, seed, /direct, verbose=verbose )
        endelse
    endif
    if needAbscissa2Data then begin
        if twuget_canCalculate(abscissa2Properties) then $
          abscissa2Data = twuget_calculate(abscissa2Properties, start=start, step=step, total=total) $
        else begin
            abscissa2DataUrl = abscissa2Properties.bulkfile_url + dataQuery
            nData = long(abscissa2Properties.length_total) < (long(abscissa2Properties.length_total)-istart)/istep
            if n_elements(total) ne 0 then $
             nData = nData < total
            seed = dblarr(nData)
            abscissa2Data = twuget_httpget(abscissa2DataUrl, seed, /direct, verbose=verbose )
        endelse
    endif

    ; Return the units, if asked for
    if arg_present(unit) then $
     if twuget_tag_valid(signalProperties, 'unit') then $
      unit = signalProperties.unit

    if arg_present(abscissa0Unit) then $
     if twuget_tag_valid(abscissa0Properties, 'unit') then $
      abscissa0Unit = abscissa0Properties.unit

    ; Now do not forget to return the data:
    if needSignalData then $
     case n_params() of
        1:  W = temporary(signalData)
        2:  X = temporary(signalData)
        3:  Y = temporary(signalData)
        4:  Z = temporary(signalData)
    endcase

    if needAbscissa0Data then $
     W = temporary(abscissa0Data)
    if needAbscissa1Data then $
     X = temporary(abscissa1Data)
    if needAbscissa2Data then $
     Y = temporary(abscissa2Data)

    if keyword_set(verbose) then $
     print, 'Total time: '+strtrim(systime(/seconds)-starttimer, 2)+' seconds.'

end     ; pro TWUget
