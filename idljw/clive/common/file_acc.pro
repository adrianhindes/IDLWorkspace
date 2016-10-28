; SCCS info: Module @(#)file_acc.pro	1.15    Date 04/04/00
;+
; PROJECT:
;       ADAS IBM MVS to DEC UNIX conversion
;
; NAME:
;	FILE_ACC
;
; PURPOSE:
;	Determine whether a named file exists, what type it is and
;	what access the user has to that file on a UNIX system.
;
; EXPLANATION:
;	This routine is intended to supplement the IDL findfile function.
;	For a given unix path name, e.g '/disk2/bowen/adas/file', this
;	routine returns certain information.
;		1.	Whether the path exists.
;		2.	Whether the user has read permission.
;		3.	Whether the user has write permission.
;		4.	Whether the user has execute permission.
;		5.	What the file type is i.e file, directory etc.
;	The routine works by spawning various UNIX commands and
;	interpreting the information returned.  A directory listing
;	command is used to get basic file information; on UNIX 'ls -ld',
;	which establishes whether the file exists and also returns the
;	file type, access and ownership information.  The 'd' parameter
;	ensures that directory information is listed rather than the
;	contents of a directory.
;	
;	Before the access information can be interpreted the current user
;	is found by spawning the 'whoami' UNIX command.  If the user is not
;	the owner of the file the UNIX 'groups' command is used to determine
;	whether or not the owner and the user are in the same group.
;	Using all of this information the correct read, write and execute
;	permissions are derived from the owner, group or world access 
;	codes given in the directory listing information.
;
;	This processing is performed in a group of four routines which
;	are all incorporated in the file_acc.pro file.
;
;	Note: the syntax of the UNIX commands and the output which is
;	returned may vary from one operating system to another.  The
;	operating system is checked and specific code executed for that
;	system.  Currently the routine has specific code for;
;	
;	****	File listing command:    ****
;	UNIX:	Command 'ls -ld /.../file.dat'
;		Output  '-rw-r--r--  1 bowen        5688 May 27 17:15 file.dat'
;
;	OSF:	(Same command as UNIX but different output, difference
;		doesn't matter though, only first three fields used.)
;		Output  '-rw-r--r--  1 bowen  user  5688 May 27 17:15 file.dat'
;
;	SUNOS:	(Same command and output as UNIX)
;
;	All others: (same as UNIX code)
;
;
;	****	Groups identification:    ****
;	UNIX:	Command 'groups root'
;		Output	'system daemon tty'
;
;	OSF:	(Same command and output as UNIX)
;
;	SUNOS:	(Same command but, importantly, different output)
;		Command 'groups root'
;	       	Output Version 5.3 and lower:	'root: system daemon tty'
;	       	       Version 5.4 at Arcetri:	'system daemon tty'
;
;	All others: (Same as UNIX code)
;
;
;	****	User identification:	****
;	UNIX, OSF and SUNOS: Command 'whoami'
;			       Output  'name'
;
; USE:
;	Example of file_acc usage;
;
;		file = '/disk2/fred/data'
;		file_acc, file, exist, read, write, execute, filetype
;		if exist eq 1 then begin
;		  print,'Permissions for file ',file,' are;'
;		  if read eq 1 print,'read'
;		  if write eq 1 print,'write'
;		  if execute eq 1 print,'execute'
;		  print,'The file type is ',filetype
;		end else begin
;		  print,file,' does not exist'
;		end
;
; INPUTS:
;	FILE	- The UNIX system name of the file. For example
;		  'file.dat' refers to the current directory and
;		  '/disk2/fred/data' is a full path name.
;
; OPTIONAL INPUTS:
;	None
;
; OUTPUTS:
;	EXIST	- Integer, 1 if the file exists, 0 if it does not.
;
;	READ	- Integer, 1 if the user has read permission 0 if not.
;
;	WRITE	- Integer, 1 if the user has write permission 0 if not.
;
;	EXECUTE	- Integer, 1 if the user has execute permission 0 if not.
;
;	FILETYPE- String, the file description character from the
;		  directory listing output. e.g for UNIX '-' indicates
;		  a file and 'd' indicates a directory file.
;
; OPTIONAL OUTPUTS:
;	None
;
; KEYWORD PARAMETERS:
;	None
;
; CALLS:
;	All of thses routines are in the file_acc.pro file.
;
;	FILE_ACC_DET	Get basic file information through 'ls' command.
;	FILE_ACC_GRP	See if two users share a group.
;
;	Called from FILE_ACC_DET and FILE_ACC_GRP;
;	FILE_ACC_SPLIT	Split a space separated string of output into
;			an array of strings.
;
; SIDE EFFECTS:
;	A number of UNIX commands are spawned.
;
; CATEGORY:
;	UNIX system IDL utility.
;
; WRITTEN:
;       Andrew Bowen, Tessella Support Services plc, 29-Apr-1993
;
; MODIFIED:
;       1       Andrew Bowen    11-Jun-1993
;               - First release.
;	??	??
;	1.13	William Osborn
;		- Changed file_acc_grp to account for output from groups
;		  with SunOS 5.4 at Arcetri
;
;       1.14     Allan Whiteford
;               - Check with to see if the file exists.
;                 This avoids ls putting up a useless warning
;                 message on the screen.
;	1.15	Richard Martin
;		Corrected above edit to use /bin/sh rather than csh
;   
; VERSION:
;       1       11-Jun-1993
;	??	??
;       1.13    22-Apr-1996
;       1.14     10-09-99
;	 1.15		26-10-99
;
;-----------------------------------------------------------------------------

PRO file_acc_split, input, output

  instr = strcompress(strtrim(input(0),2))

		;**** split output into separate parts ****
  if instr ne '' then begin

    length = strlen(instr)
    start= 0
    j = 0
    output = ''
    while (start lt length) do begin

      strend = strpos(instr,' ',start)

      if strend ge 0 then begin
        output = [output,strmid(instr,start,strend-start)]
        j = j + 1
        start = strend + 1
      end else begin
        output = [output,strmid(instr,start,length-start+1)]
        start = length
      end

    end
    output = output(1:*)

  end else begin

    output = ''

  end


END

;-----------------------------------------------------------------------------

PRO file_acc_grp, user1, user2, group

  if !version.os eq 'ultrix' or !version.os eq 'OSF' or $
	!version.os eq 'sunos' then begin
    spawn,'groups '+user1,grp1, /sh
    spawn,'groups '+user2,grp2, /sh
  end else begin
    spawn,'groups '+user1,grp1, /sh
    spawn,'groups '+user2,grp2, /sh
  end

		;**** split output into separate parts ****
  file_acc_split,grp1,groups1
  file_acc_split,grp2,groups2

		;**** test to see if there's a colon separator ****
		;**** and if so, omit the first field(s)       ****

  sg1 = size(groups1)
  if sg1(0) gt 0 then begin
		;**** Test for 'adas: users' format ****
    g1=strtrim(groups1(0),2)
    if strmid(g1,strlen(g1)-1,1) eq ':' then begin
      if sg1(1) gt 1 then groups1 = groups1(1:*) else groups1 = ['']
    endif else begin
      if sg1(1) ge 2 then begin
		;**** Test for 'adas : users' format ****
        if strtrim(groups1(1),2) eq ':' then begin
          if sg1(1) gt 2 then groups1 = groups1(2:*) else groups1 = ['']
        endif
      endif
    endelse
  endif

  sg2 = size(groups2)
  if sg2(0) gt 0 then begin
		;**** Test for 'adas: users' format ****
    g2=strtrim(groups2(0),2)
    if strmid(g2,strlen(g2)-1,1) eq ':' then begin
      if sg2(1) gt 1 then groups2 = groups2(1:*) else groups2 = ['']
    endif else begin
      if sg2(1) ge 2 then begin
		;**** Test for 'adas : users' format ****
        if strtrim(groups2(1),2) eq ':' then begin
          if sg2(1) gt 2 then groups2 = groups2(2:*) else groups2 = ['']
        endif
      endif
    endelse
  endif


		;**** discard first item (user name) for SUNOS ****
		;**** This doesn't work because of different output ****
		;**** in different releases of SunOS ****

;  if !version.os eq 'sunos' then begin
;    if strtrim(groups1(0)) ne '' then groups1 = groups1(1:*)
;    if strtrim(groups2(0)) ne '' then groups2 = groups2(1:*)
;  end

		;**** test if the users share a group ****
  share = where(groups1 eq groups2)

		;**** set output flag is users share group ****
  if share(0) ge 0 then group = 1 else group = 0

END

;----------------------------------------------------------------------------

PRO file_acc_det, file, exist, owner, filetype, ownacc, grpacc, allacc

; Check if the file exists before spawning ls - avoids unecessary
; message to error stream from ls.

;  spawn,'csh -c ''if (-e '+file(0)+' ) echo Found'' ',found

  command= 'if [ -r ' + file(0) + ' ]; then  echo Found; fi'
  spawn, command, found, /sh

  if found(0) ne 'Found' then begin 	
     exist = 0			
  endif else begin		
     if !version.os eq 'ultrix' or !version.os eq 'OSF' or $
	   !version.os eq 'sunos' then begin
       spawn,'ls -ld '+file,output, /sh
     end else begin
       spawn,'ls -ld '+file,output, /sh
     end

		   ;**** Check to see if file found ****
     if strtrim(output(0),2) eq '' then begin

       exist = 0

     end else begin

       exist = 1

		   ;**** split output into separate parts ****
       file_acc_split,output,details

		   ;**** output file owner ****
       owner = details(2)

		   ;**** output file type ****
       filetype = strmid(details(0),0,1)

		   ;**** output owner's access ****
       ownacc = strmid(details(0),1,3)

		   ;**** output group access ****
       grpacc = strmid(details(0),4,3)

		   ;**** output world access ****
       allacc = strmid(details(0),7,3)

     end
     
  endelse

END

;----------------------------------------------------------------------------

PRO file_acc, file, exist, read, write, execute, filetype


		;**** initialize outputs ****
  read = 0
  write = 0
  execute = 0
  filetype = ''

		;**** Get file details ****
  file_acc_det, file, exist, owner, filetype, ownacc, grpacc, allacc

		;**** If the file exists test access ****
  if exist eq 1 then begin

		;**** Who is the current user ****
    if !version.os eq 'ultrix' or !version.os eq 'OSF' or $
	!version.os eq 'sunos' then begin
      spawn,'whoami',output, /sh
      user = strtrim(output(0),2)
    end else begin
      spawn,'whoami',output, /sh
      user = strtrim(output(0),2)
    end

                ;**********************************
		;**** determine access allowed ****
                ;**********************************
                ;**** Test for ownership access, group access ****
		;**** or world access.                        ****

    if user eq owner then begin

		;****  Determine owner access ****
      if strpos(ownacc,'r') ge 0 then read = 1
      if strpos(ownacc,'w') ge 0 then write = 1
      if strpos(ownacc,'x') ge 0 then execute = 1

    end else begin

		;**** Determine if the user is in the owner's group ****
      file_acc_grp, owner, user, group

      if group eq 1 then begin

		;**** Determine group access ****
        if strpos(grpacc,'r') ge 0 then read = 1
        if strpos(grpacc,'w') ge 0 then write = 1
        if strpos(grpacc,'x') ge 0 then execute = 1

      end else begin

		;**** Determine world access ****
        if strpos(allacc,'r') ge 0 then read = 1
        if strpos(allacc,'w') ge 0 then write = 1
        if strpos(allacc,'x') ge 0 then execute = 1

      end

    end

  end


END
