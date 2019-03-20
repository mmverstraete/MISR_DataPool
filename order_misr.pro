PRO order_misr

   ;Sec-Doc
   ;  PURPOSE: This program collects user inputs to specify which MISR
   ;  data product files must be downloaded from the NASA ASDC Data Pool.
   ;  Default or common values are provided for all required inputs except
   ;  the MISR PATH, which must be entered explicitly.
   ;
   ;  ALGORITHM: This main program is a wrapper routine to assess which
   ;  MISR data product files should be downloaded from the NASA ASDC Data
   ;  Pool. Once the inputs have been obtained and verified, this program
   ;  relies on the function mk_ftp_datapool_misr.pro to generate the ftp
   ;  script itself. The Perl script get_datapool_misr.pl is subsequently
   ;  used to manage the ftp connection with the NASA ASDC Data Pool and
   ;  execute each ftp command in turn.
   ;
   ;  SYNTAX: order_misr
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]: None.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]: None.
   ;
   ;  RETURNED VALUE TYPE: N/A.
   ;
   ;  OUTCOME:
   ;
   ;  *   If no exception condition has been detected, an ftp script file
   ;      is saved in the designated or default folder ftpscript_path, an
   ;      optional log file is saved in the designated or default folder
   ;      log_path, and the MISR data product files retrieved by the Perl
   ;      script are expected to be saved in the designated or default
   ;      folder data_path.
   ;
   ;  *   If an exception condition has been detected, a message about the
   ;      exception condition encountered is printed on the console. The
   ;      ftp script file and the log files may be inexistent, incomplete
   ;      or incorrect.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Error 500: The output folder ftpscript_path is unwritable.
   ;
   ;  *   Error 510: An exception condition occurred in is_writable.pro.
   ;
   ;  *   Error 520: The output folder log_path is unwritable.
   ;
   ;  *   Error 530: An exception condition occurred in is_writable.pro.
   ;
   ;  *   Error 540: The output folder data_path is unwritable.
   ;
   ;  *   Error 550: An exception condition occurred in is_writable.pro.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   chk_misr_path.pro
   ;
   ;  *   chk_ymddate.pro
   ;
   ;  *   is_writable.pro
   ;
   ;  *   mk_ftp_datapool_misr.pro
   ;
   ;  *   path2str.pro
   ;
   ;  *   set_roots_vers.pro
   ;
   ;  *   set_white.pro
   ;
   ;  *   strstr.pro
   ;
   ;  *   today.pro
   ;
   ;  REMARKS: None.
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> order_misr
   ;
   ;      [Answer the various questions; when all inputs have been
   ;      provided and verified, the ftp script and the optional
   ;      log file are saved in the specified or default folders.]
   ;
   ;  REFERENCES: None.
   ;
   ;  VERSIONING:
   ;
   ;  *   2019–01–07: Version 0.9 — Initial release.
   ;
   ;  *   2019–01–10: Version 1.0 — Initial public release.
   ;
   ;  *   2019–01–28: Version 2.00 — Systematic update of all routines to
   ;      implement stricter coding standards and improve documentation.
   ;
   ;  *   2019–03–20: Version 2.01 — Bug fix: Correct the handling of
   ;      initial and final dates other than the defaults [Thanks to Hugo
   ;      De Lemos].
   ;Sec-Lic
   ;  INTELLECTUAL PROPERTY RIGHTS
   ;
   ;  *   Copyright (C) 2017-2019 Michel M. Verstraete.
   ;
   ;      Permission is hereby granted, free of charge, to any person
   ;      obtaining a copy of this software and associated documentation
   ;      files (the “Software”), to deal in the Software without
   ;      restriction, including without limitation the rights to use,
   ;      copy, modify, merge, publish, distribute, sublicense, and/or
   ;      sell copies of the Software, and to permit persons to whom the
   ;      Software is furnished to do so, subject to the following three
   ;      conditions:
   ;
   ;      1. The above copyright notice and this permission notice shall
   ;      be included in its entirety in all copies or substantial
   ;      portions of the Software.
   ;
   ;      2. THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY
   ;      KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
   ;      WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
   ;      AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
   ;      HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
   ;      WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
   ;      FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
   ;      OTHER DEALINGS IN THE SOFTWARE.
   ;
   ;      See: https://opensource.org/licenses/MIT.
   ;
   ;      3. The current version of this Software is freely available from
   ;
   ;      https://github.com/mmverstraete.
   ;
   ;  *   Feedback
   ;
   ;      Please send comments and suggestions to the author at
   ;      MMVerstraete@gmail.com
   ;Sec-Cod

   COMPILE_OPT idl2, HIDDEN
   debug = 1

   PRINT
   PRINT, 'Program to collect user requirements for MISR data:'
   PRINT

   ;  Get the MISR Path number:
   misr_path = 0
   answ = ''
   WHILE (misr_path EQ 0) DO BEGIN
      READ, answ, $
         PROMPT = 'Enter the desired MISR Path (0 < n < 234; default: None): '
      answ = FIX(strstr(answ))
      rc = chk_misr_path(answ, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc EQ 0) THEN BEGIN
         misr_path = answ
      ENDIF ELSE BEGIN
         PRINT, '   Invalid MISR Path number.'
         misr_path = 0
      ENDELSE
   ENDWHILE
   rc = path2str(misr_path, misr_path_str, $
      DEBUG = debug, EXCPT_COND = excpt_cond)

   ;  Get the initial date:
   start_time = ''
   answ = ''
   WHILE (start_time EQ '') DO BEGIN
      READ, answ, $
         PROMPT = 'Enter the starting date (YYYY-MM-DD; default: 2000-02-24): '
      answ = strstr(answ)
      IF (answ EQ '') THEN BEGIN
         strt = JULDAY(2, 24, 2000)
         start_time = '2000-02-24'
      ENDIF ELSE BEGIN
         rc = chk_ymddate(answ, year, month, day, $
            DEBUG = debug, EXCPT_COND = excpt_cond)
         IF (rc NE 0) THEN BEGIN
            PRINT, '   Invalid starting date format: Try again.'
            start_time = ''
         ENDIF ELSE BEGIN
            strt = MAX([JULDAY(2, 24, 2000), JULDAY(month, day, year)])
            tody = today(FMT = 'jul')
            strt = MIN(strt, tody)
            CALDAT, strt, mo, dy, yr
            start_time = strstr(yr) + '-' + $
               STRING(mo, FORMAT = '(I02)') + '-' + $
               STRING(dy, FORMAT = '(I02)')
         ENDELSE
      ENDELSE
   ENDWHILE
   PRINT, '   The starting date is set to ' + start_time + '.'
   start_time = start_time + 'T00:00:00Z'

   ;  Get the final date:
   end_time = ''
   answ = ''
   WHILE (end_time EQ '') DO BEGIN
      READ, answ, $
         PROMPT = 'Enter the ending date (YYYY-MM-DD; default: today): '
      answ = strstr(answ)
      IF (answ EQ '') THEN BEGIN
         endd = today(FMT = 'ymd')
         CALDAT, endd, mo, dy, yr
         end_time = strstr(yr) + '-' + strstr(mo) + '-' + strstr(dy)
      ENDIF ELSE BEGIN
         rc = chk_ymddate(answ, year, month, day, $
            DEBUG = debug, EXCPT_COND = excpt_cond)
         IF (rc NE 0) THEN BEGIN
            PRINT, '   Invalid ending date format: Try again.'
            end_time = ''
         ENDIF ELSE BEGIN
            tody = today(FMT = 'jul')
            endd = MIN([JULDAY(month, day, year), tody])
            IF (endd LT strt) THEN BEGIN
               PRINT, '   Ending date must be after starting date: Try again.'
               end_time = ''
            ENDIF
            CALDAT, endd, mo, dy, yr
            end_time = strstr(yr) + '-' + $
               STRING(mo, FORMAT = '(I02)') + '-' + $
               STRING(dy, FORMAT = '(I02)')
         ENDELSE
      ENDELSE
   ENDWHILE
   PRINT, '   The ending date is set to ' + end_time + '.'
   end_time = end_time + 'T23:59:59Z'

   ;  Get the list of MISR data products to download:
   answ = ''
   dt_all = ['BR', 'GRP_GM', 'GRP_LM', 'GPP', 'RCCM', 'AERO', 'LAND']
   dt_gmlm = ['GRP_GM', 'GRP_LM', 'GPP', 'RCCM', 'LAND']
   dt_only = ['GRP_GM', 'GPP', 'RCCM', 'LAND']
   n_prods = 0
   WHILE (n_prods EQ 0) DO BEGIN
      PRINT, 'List of individual MISR data product(s) that can be ' + $
         'downloaded with this program:'
      PRINT, '   BR: L1B2 Browse Product.'
      PRINT, '   GRP_GM: L1B2 Georectified Radiance (GRP) Terrain ' + $
         'projected Global Mode (GM) Product.'
      PRINT, '   GRP_LM: L1B2 Georectified Radiance (GRP) Terrain ' + $
        'projected Local Mode (LM) Product.'
      PRINT, '   GPP: L1B2 Geometric Parameters Product (GPP).'
      PRINT, '   RCCM: L1B2 Radiometric Camera-by-Camera Cloud Mask (RCCM).'
      PRINT, '   AERO: L2 Aerosol (atmospheric) Product.'
      PRINT, '   LAND: L2 Land (surface) Product.'
      PRINT
      PRINT, 'The following standard options supersede any individual choices:'
      PRINT, '   ONLY: Only those files strictly needed by MISR-HR in GM: ' + $
         'GRP_GM, GPP, RCCM, LAND.'
      PRINT, '   GMLM: Same as ONLY, but with GRP_LM.'
      PRINT, '   ALL: All 7 data products mentioned above.'
      PRINT
      PRINT, 'Enter one or more acronyms from the lists above,'
      READ, answ, PROMPT = 'separated by blank spaces, tabs or commas ' + $
         '(default: ONLY): '
      answ = STRUPCASE(answ)
      IF (answ EQ '') THEN answ = 'ONLY'
      IF (STRPOS(answ, 'ALL') GE 0) THEN BEGIN
         data_types = dt_all
         n_prods = N_ELEMENTS(data_types)
      ENDIF ELSE BEGIN
         IF (STRPOS(answ, 'GMLM') GE 0) THEN BEGIN
            data_types = dt_gmlm
            n_prods = N_ELEMENTS(data_types)
         ENDIF ELSE BEGIN
            IF (STRPOS(answ, 'ONLY') GE 0) THEN BEGIN
               data_types = dt_only
               n_prods = N_ELEMENTS(data_types)
            ENDIF ELSE BEGIN
               white = set_white()
               sep = white + ','
               parts = STRSPLIT(answ, sep, COUNT = n_parts, /EXTRACT)
               data_types = STRARR(n_parts)
               n_prods = 0
               FOR i = 0, n_parts - 1 DO BEGIN
                  prod = strstr(parts[i])
                  idx = WHERE(prod EQ dt_all, count)
                  IF (count GT 0) THEN BEGIN
                     data_types[n_prods] = prod
                     n_prods++
                  ENDIF
               ENDFOR
               IF (n_prods EQ 0) THEN BEGIN
                  data_types = ''
                  PRINT, '   No valid MISR data product(s) have been specified.'
               ENDIF
            ENDELSE
         ENDELSE
      ENDELSE
   ENDWHILE

   ;  Set the default folders and version identifiers of the MISR and
   ;  MISR-HR files on this computer, and return to the calling routine if
   ;  there is an internal error, but not if the computer is unrecognized, as
   ;  these settings can be overridden by input keyword parameters:
   rc = set_roots_vers(root_dirs, versions, $
      DEBUG = debug, EXCPT_COND = excpt_cond)

   idx = WHERE('BR' EQ data_types, count)
   IF (count GT 0) THEN BEGIN
      br_version = versions[1]
      PRINT, 'Browse product version: ', br_version, FORMAT = fmt1
   ENDIF
   idx = WHERE('GRP_GM' EQ data_types, count)
   IF (count GT 0) THEN BEGIN
      grp_gm_version = versions[2]
      PRINT, 'GRP_GM version: ', grp_gm_version, FORMAT = fmt1
   ENDIF
   idx = WHERE('GRP_LM' EQ data_types, count)
   IF (count GT 0) THEN BEGIN
      grp_lm_version = versions[3]
      PRINT, 'GRP_LM version: ', grp_lm_version, FORMAT = fmt1
   ENDIF
   idx = WHERE('GPP' EQ data_types, count)
   IF (count GT 0) THEN BEGIN
      gpp_version = versions[4]
      PRINT, 'GPP version: ', gpp_version, FORMAT = fmt1
   ENDIF
   idx = WHERE('RCCM' EQ data_types, count)
   IF (count GT 0) THEN BEGIN
      rccm_version = versions[5]
      PRINT, 'RCCM version: ', rccm_version, FORMAT = fmt1
   ENDIF
   idx = WHERE('AERO' EQ data_types, count)
   IF (count GT 0) THEN BEGIN
      aero_version = versions[6]
      PRINT, 'Aerosol version: ', aero_version, FORMAT = fmt1
   ENDIF
   idx = WHERE('LAND' EQ data_types, count)
   IF (count GT 0) THEN BEGIN
      land_version = versions[7]
      PRINT, 'LSP version: ', land_version, FORMAT = fmt1
   ENDIF

   ;  Get the directory address of the folder to contain the ftp script:
   ftpscript_path = ''
   WHILE (ftpscript_path EQ '') DO BEGIN
      PRINT, 'Enter the directory where the ftp script should be saved'
      READ, ftpscript_path, PROMPT = '(default: set by set_roots_vers.pro): '
      ftpscript_path = strstr(ftpscript_path, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (ftpscript_path EQ '') THEN BEGIN
         ftpscript_path = root_dirs[0] + 'Datapool' + PATH_SEP() + $
            misr_path_str + PATH_SEP()
      ENDIF

   ;  Return to the calling routine with an error message if the output
   ;  directory 'ftpscript_path' is not writable, and create it if it does not
   ;  exist:
      rc = is_writable(ftpscript_path, DEBUG = debug, EXCPT_COND = excpt_cond)
      CASE rc OF
         1: BREAK
         0: BEGIN
            error_code = 500
            excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
               rout_name + ': The output folder ' + ftpscript_path + $
               ' is unwritable.'
            PRINT, excpt_cond
            RETURN
         END
         -1: BEGIN
            IF (debug) THEN BEGIN
               error_code = 510
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': ' + excpt_cond
               PRINT, excpt_cond
               RETURN
            ENDIF
         END
         -2: BEGIN
            FILE_MKDIR, ftpscript_path
         END
         ELSE: BEGIN
            ftpscript_path = ''
         END
      ENDCASE
   ENDWHILE

   ;  Get the directory address of the folder to contain the log file:
   log_path = ''
   WHILE (log_path EQ '') DO BEGIN
      PRINT, 'Enter the directory where the log file should be saved'
      READ, log_path, PROMPT = '(default: set by set_roots_vers.pro): '
      log_path = strstr(log_path)
      IF (log_path EQ '') THEN BEGIN
         log_path = root_dirs[0] + 'Datapool' + PATH_SEP() + $
            misr_path_str + PATH_SEP()
      ENDIF

   ;  Return to the calling routine with an error message if the output
   ;  directory 'log_path' is not writable, and create it if it does not
   ;  exist:
      rc = is_writable(log_path, DEBUG = debug, EXCPT_COND = excpt_cond)
      CASE rc OF
         1: BREAK
         0: BEGIN
            error_code = 520
            excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
               rout_name + ': The output folder ' + log_path + $
               ' is unwritable.'
            PRINT, excpt_cond
            RETURN
         END
         -1: BEGIN
            IF (debug) THEN BEGIN
               error_code = 530
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': ' + excpt_cond
               PRINT, excpt_cond
               RETURN
            ENDIF
         END
         -2: BEGIN
            FILE_MKDIR, log_path
         END
         ELSE: BEGIN
            ftpscript_path = ''
         END
      ENDCASE
   ENDWHILE

   ;  Get the directory address where the MISR data products should be saved:
   data_path = ''
   WHILE (data_path EQ '') DO BEGIN
      PRINT, 'Enter the directory where the MISR data products should be saved'
      READ, data_path, PROMPT = '(default: set by set_roots_vers.pro): '
      data_path = strstr(data_path)
      IF (data_path EQ '') THEN BEGIN
         data_path = root_dirs[0] + 'Datapool' + PATH_SEP() + $
            misr_path_str + PATH_SEP()
      ENDIF

   ;  Return to the calling routine with an error message if the output
   ;  directory 'data_path' is not writable, and create it if it does not
   ;  exist:
      rc = is_writable(data_path, DEBUG = debug, EXCPT_COND = excpt_cond)
      CASE rc OF
         1: BREAK
         0: BEGIN
            error_code = 540
            excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
               rout_name + ': The output folder ' + data_path + $
               ' is unwritable.'
            PRINT, excpt_cond
            RETURN
         END
         -1: BEGIN
            IF (debug) THEN BEGIN
               error_code = 550
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': ' + excpt_cond
               PRINT, excpt_cond
               RETURN
            ENDIF
         END
         -2: BEGIN
            FILE_MKDIR, data_path
         END
         ELSE: BEGIN
            ftpscript_path = ''
         END
      ENDCASE
   ENDWHILE

   verbose = 1

   ;  Summarize the user request:
   fmt1 = '(A30, A)'
   fmt2 = '(A30, 10(A6, 2X))'
   PRINT
   PRINT, 'Summary of MISR data request: ', '', FORMAT = fmt1
   PRINT, 'misr_path: ', strstr(misr_path), FORMAT = fmt1
   PRINT, 'starting from: ', start_time, FORMAT = fmt1
   PRINT, 'ending on: ', end_time, FORMAT = fmt1
   PRINT, 'products: ', data_types, FORMAT = fmt2
   idx = WHERE('BR' EQ data_types, count)
   IF (count GT 0) THEN BEGIN
      PRINT, 'Browse product version: ', br_version, FORMAT = fmt1
   ENDIF
   idx = WHERE('GRP_GM' EQ data_types, count)
   IF (count GT 0) THEN BEGIN
      PRINT, 'GRP_GM version: ', grp_gm_version, FORMAT = fmt1
   ENDIF
   idx = WHERE('GRP_LM' EQ data_types, count)
   IF (count GT 0) THEN BEGIN
      PRINT, 'GRP_LM version: ', grp_lm_version, FORMAT = fmt1
   ENDIF
   idx = WHERE('GPP' EQ data_types, count)
   IF (count GT 0) THEN BEGIN
      PRINT, 'GPP version: ', gpp_version, FORMAT = fmt1
   ENDIF
   idx = WHERE('RCCM' EQ data_types, count)
   IF (count GT 0) THEN BEGIN
      PRINT, 'RCCM version: ', rccm_version, FORMAT = fmt1
   ENDIF
   idx = WHERE('AERO' EQ data_types, count)
   IF (count GT 0) THEN BEGIN
      PRINT, 'Aerosol version: ', aero_version, FORMAT = fmt1
   ENDIF
   idx = WHERE('LAND' EQ data_types, count)
   IF (count GT 0) THEN BEGIN
      PRINT, 'LSP version: ', land_version, FORMAT = fmt1
   ENDIF
   PRINT, 'FTP script saved in: ', ftpscript_path, FORMAT = fmt1
   PRINT, 'Log file saved in: ', log_path, FORMAT = fmt1
   PRINT, 'MISR files to be saved in: ', data_path, FORMAT = fmt1

   rc = mk_ftp_datapool_misr(misr_path, $
      START_TIME = start_time, END_TIME = end_time, $
      DATA_TYPES = data_types, FTPSCRIPT_PATH = ftpscript_path, $
      LOG_PATH = log_path, DATA_PATH = data_path, VERBOSE = verbose, $
      DEBUG = debug, EXCPT_COND = excpt_cond)

   PRINT, 'Processing completed.'

END
