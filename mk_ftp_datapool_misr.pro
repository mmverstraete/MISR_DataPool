FUNCTION mk_ftp_datapool_misr, $
   misr_path, $
   START_TIME = start_time, $
   END_TIME = end_time, $
   DATA_TYPES = data_types, $
   FTPSCRIPT_PATH = ftpscript_path, $
   LOG_PATH = log_path, $
   DATA_PATH = data_path, $
   VERBOSE = verbose, $
   DEBUG = debug, $
   EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function creates the plain text file containing the
   ;  collection of ftp commands required by the Perl script
   ;  get_misr_datapool.pl to download MISR data files for the specified
   ;  PATH from the NASA Langley Atmospheric Sciences Data Center (ASDC).
   ;
   ;  ALGORITHM: This function generates a file containing a set of ftp
   ;  commands to retrieve MISR data product files on the basis of the
   ;  values of input positional and keyword parameters.
   ;
   ;  SYNTAX: rc = mk_ftp_datapool_misr(misr_path, $
   ;  START_TIME = start_time, END_TIME = end_time, $
   ;  DATA_TYPES = data_types, FTPSCRIPT_PATH = ftpscript_path, $
   ;  LOG_PATH = log_path, DATA_PATH = data_path, $
   ;  VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   misr_path {INTEGER} [I]: The selected MISR PATH number.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   START_TIME = start_time {STRING} [I] (Default value:
   ;      ’2000-02-24T00:00:00Z’): The starting date and time of the
   ;      period during which to acquire MISR data files.
   ;
   ;  *   END_TIME = end_time {STRING} [I] (Default value: Today): The
   ;      ending date and time of the period during which to acquire MISR
   ;      data files.
   ;
   ;  *   DATA_TYPES = data_types {STRING array} [I] (Default value: [”]):
   ;      The array containing the list of MISR data types to retrieve.
   ;      Possibilities include:
   ;
   ;      -   BR: L1B2 Browse Product.
   ;
   ;      -   GRP_GM: L1B2 Georectified Radiance Product (GRP) Terrain
   ;          projected Global Mode (GM)
   ;
   ;      -   GRP_LM: L1B2 Georectified Radiance Product (GRP) Terrain
   ;          projected Local Mode (LM)
   ;
   ;      -   GPP: L1B2 Geometric Parameters Product (GPP).
   ;
   ;      -   RCCM: L1B2 Georectified Radiance Product (GRP) Radiometric
   ;          Camera-by-camera Cloud Mask (RCCM)
   ;
   ;      -   AERO: L2 Aerosol/Surface (AS) Aerosol Product (AP).
   ;
   ;      -   LAND: L2 Aerosol/Surface (AS) Land Surface Product (LSP).
   ;
   ;      -   ONLY: Only those files strictly needed by MISR-HR: GRP_GM,
   ;          GPP, RCCM, LAND.
   ;
   ;      -   ALL: All of the above.
   ;
   ;  *   FTPSCRIPT_PATH = ftpscript_path {STRING} [I] (Default value: ’\sim/MISR_HR/Input/Datapool/’):
   ;      The optional name of the output folder containing the ftp
   ;      script.
   ;
   ;  *   LOG_PATH = log_path {STRING} [I] (Default value: ’\sim/MISR_HR/Input/Datapool/’):
   ;      The name of the folder containing the Log file.
   ;
   ;  *   DATA_PATH = data_path {STRING} [I] (Default value: ’\sim/MISR_HR/Input/MISR/’ + misr_path_str’):
   ;      The name of the folder where the MISR files should be saved.
   ;
   ;  *   VERBOSE = verbose {INT} [I] (Default value: 0): Flag to enable
   ;      (> 0) or skip (0) outputting messages on the console:
   ;
   ;      -   If verbose > 0, messages inform the user about progress in
   ;          the execution of time-consuming routines, or the location of
   ;          output files (e.g., log, map, plot, etc.);
   ;
   ;      -   If verbose > 1, messages record entering and exiting the
   ;          routine; and
   ;
   ;      -   If verbose > 2, messages provide additional information
   ;          about intermediary results.
   ;
   ;  *   DEBUG = debug {INT} [I] (Default value: 0): Flag to activate (1)
   ;      or skip (0) debugging tests.
   ;
   ;  *   EXCPT_COND = excpt_cond {STRING} [O] (Default value: ”):
   ;      Description of the exception condition if one has been
   ;      encountered, or a null string otherwise.
   ;
   ;  RETURNED VALUE TYPE: INT.
   ;
   ;  OUTCOME:
   ;
   ;  *   If no exception condition has been detected, this function
   ;      returns 0, and the output keyword parameter excpt_cond is set to
   ;      a null string, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided in the call. The ftp script file and the optional Log
   ;      files are saved in the designated or default folders.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code, and the output keyword parameter
   ;      excpt_cond contains a message about the exception condition
   ;      encountered, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided. The ftp script file and the optional Log files may be
   ;      inexistent, incomplete or incorrect.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Error 98: An exception condition occurred in get_host_info.pro.
   ;
   ;  *   Error 99: An exception condition occurred in set_roots_vers.pro.
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: Input positional parameter misr_path is invalid.
   ;
   ;  *   Error 120: The initial date of the period of interest, provided
   ;      with the input keyword parameter START_TIME = start_time is
   ;      invalid.
   ;
   ;  *   Error 130: The final date of the period of interest, provided
   ;      with the input keyword parameter END_TIME = end_time is invalid.
   ;
   ;  *   Error 140: The list data_types of MISR product types to be
   ;      acquired must be of type STRING.
   ;
   ;  *   Error 150: The list data_types of MISR product types to be
   ;      acquired must be an array.
   ;
   ;  *   Error 160: The list data_types of MISR product types to be
   ;      acquired contains one or more unrecognized products.
   ;
   ;  *   Error 200: An exception condition occurred in path2str.pro.
   ;
   ;  *   Error 210: An exception condition occurred in orbit2str.pro
   ;      while generating the first ORBIT to get.
   ;
   ;  *   Error 220: An exception condition occurred in orbit2str.pro
   ;      while generating the last ORBIT to get.
   ;
   ;  *   Error 400: The output folder ftpscript_path is unwritable.
   ;
   ;  *   Error 410: The output folder log_path is unwritable.
   ;
   ;  *   Error 420: The output folder data_path is unwritable.
   ;
   ;  *   Error 600: An exception condition occurred in the MISR TOOLKIT
   ;      routine
   ;      MTK_PATH_TIMERANGE_TO_ORBITLIST.
   ;
   ;  *   Error 610: the MISR TOOLKIT routine
   ;      MTK_PATH_TIMERANGE_TO_ORBITLIST returned an empty ORBIT list.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   MISR Toolkit
   ;
   ;  *   chk_isodate.pro
   ;
   ;  *   chk_misr_path.pro
   ;
   ;  *   get_host_info.pro
   ;
   ;  *   is_array.pro
   ;
   ;  *   is_numeric.pro
   ;
   ;  *   is_string.pro
   ;
   ;  *   is_writable_dir.pro
   ;
   ;  *   orbit2str.pro
   ;
   ;  *   path2str.pro
   ;
   ;  *   set_misr_specs.pro
   ;
   ;  *   set_roots_vers.pro
   ;
   ;  *   strstr.pro
   ;
   ;  *   today.pro
   ;
   ;  REMARKS:
   ;
   ;  *   NOTE 1: The directories and file names to access MISR data
   ;      products at Langley are set by NASA and are therefore hardcoded
   ;      in this function to match the organization of the datapool at
   ;      the time of writing.
   ;
   ;  *   NOTE 2: The data product version identifiers and directory
   ;      addresses on the NASA ASDC Data Pool ftp site are hardwired near
   ;      the start of this routine: they should be updated manually
   ;      whenever new versions become available.
   ;
   ;  *   NOTE 3:The default directory address of the local folder to
   ;      store the ftp script and the Log file is
   ;      home + ’MISR_HR/Input/Datapool/’, where home is the user’s home
   ;      directory on the current computer.
   ;
   ;  *   NOTE 4: These default directories can be overridden by setting
   ;      the optional input keyword parameters FTPSCRIPT_PATH and
   ;      LOG_PATH to alternate addresses, respectively.
   ;
   ;  *   NOTE 5: The ftp script file is named
   ;      ’FTPscript_datapool_MISR_’ + $
   ;      misr_path_str + ’_’ + $
   ;      frst_orbit_str + ’-’ + $
   ;      last_orbit_str + ’_’ + $
   ;      date + ’.txt’.
   ;
   ;  *   NOTE 6: The optional Log file is named
   ;      ’Log_datapool_MISR_’ + $
   ;      misr_path_str + ’_’ + $
   ;      frst_orbit_str + ’-’ + $
   ;      last_orbit_str + ’_’ + $
   ;      date + ’.txt’.
   ;
   ;  *   NOTE 7: The default directory address of the local folder to
   ;      store the MISR data product files is
   ;      home + ’MISR_HR/Input/MISR/’ + misr_path_str + PATH_SEP(), where
   ;      home is the user’s home directory on the current computer.
   ;
   ;  *   NOTE 8: This default directory address can be overridden by
   ;      setting the optional input keyword parameter DATA_PATH to an
   ;      alternate address.
   ;
   ;  *   NOTE 9: All MISR data files are initially saved in the same
   ;      folder to let the ftp process proceed uninterrupted. They may
   ;      need to be moved to their final destination at a later stage.
   ;
   ;  *   NOTE 10: The MISR data product files are saved locally with the
   ;      same original name they hold at NASA Langley.
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> misr_path = 168
   ;      IDL> rc = mk_ftp_datapool_misr(misr_path, /VERBOSE, $
   ;         /DEBUG, EXCPT_COND = excpt_cond)
   ;
   ;      [This setup will result in the saving of an FTP script and a Log
   ;      file in the default directories mentioned above. WARNING: This
   ;      particular FTP script will acquire some 86,000 files from ASDC,
   ;      which might take a long time as well as take up a large disk
   ;      space locally.]
   ;
   ;  REFERENCES: None.
   ;
   ;  VERSIONING:
   ;
   ;  *   2016–03–13: Version 0.9 — Initial release by Linda Hunt, as
   ;      ftp_pool.pro.
   ;
   ;  *   2017–11–22: Version 1.0 — Updat the function, renamed
   ;      get_misr_datapool.pro and made available only at GCI/Wits.
   ;
   ;  *   2018–12–12: Version 1.1 — Revamp the function to include a full
   ;      set of input positional and keyword parameters, renamed
   ;      mk_ftp_datapool_misr.pro.
   ;
   ;  *   2019–01–06: Version 1.2 — Simplify the calling sequence and
   ;      hardcode version identifiers to retrieve the most current
   ;      version at the time of writing.
   ;
   ;  *   2019–01–28: Version 2.00 — Systematic update of all routines to
   ;      implement stricter coding standards and improve documentation.
   ;
   ;  *   2019–08–20: Version 2.1.0 — Adopt revised coding and
   ;      documentation standards (in particular regarding the use of
   ;      verbose and the assignment of numeric return codes), and switch
   ;      to 3-parts version identifiers.
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

   ;  Get the name of this routine:
   info = SCOPE_TRACEBACK(/STRUCTURE)
   rout_name = info[N_ELEMENTS(info) - 1].ROUTINE

   ;  Initialize the default return code:
   return_code = 0

   ;  Set the default values of flags and essential output keyword parameters:
   IF (KEYWORD_SET(verbose)) THEN BEGIN
      IF (is_numeric(verbose)) THEN verbose = FIX(verbose) ELSE verbose = 0
      IF (verbose LT 0) THEN verbose = 0
      IF (verbose GT 3) THEN verbose = 3
   ENDIF ELSE verbose = 0
   IF (KEYWORD_SET(debug)) THEN debug = 1 ELSE debug = 0
   excpt_cond = ''

   IF (verbose GT 1) THEN PRINT, 'Entering ' + rout_name + '.'

   ;  Set the data product names, version identifiers and directory addresses
   ;  of the folders on the NASA ASDC Data Pool for the time-dependent MISR
   ;  files potentially needed in the context of the MISR-HR processing system.
   ;  Additional entries may be needed to acquire other files.
   ;  These settings may need to be updated whenever new versions become
   ;  available or if the structure of the Data Pool changes.
   ;  Programming note: Ensure that the settings implemented here are
   ;  consistent with those implemented in the function 'set_roots_vers.pro'.

   ;  MISR Browse product files:
   br_product = 'GRP_ELLIPSOID_BR_GM'
   br_version = 'F03_0024'
   br_esdt = 'MISBR.005/'

   ;  MISR L1B2 Georectified Radiance Product (GRP) Terrain projected
   ;  Global Mode (GM) files:
   grp_gm_product = 'GRP_TERRAIN_GM'
   grp_gm_version = 'F03_0024'
   grp_gm_esdt = 'MI1B2T.003/'

   ;  MISR L1B2 Georectified Radiance Product (GRP) Terrain projected
   ;  Local Mode (LM) files:
   grp_lm_product = 'GRP_TERRAIN_LM'
   grp_lm_version = 'F03_0024'
   grp_lm_esdt = 'MB2LMT.002/'

   ;  MISR Geometric Parameters Product (GPP) files:
   gpp_product = 'GP_GMP'
   gpp_version = 'F03_0013'
   gpp_esdt = 'MIB2GEOP.002/'

   ;  MISR L1B2 Georectified Radiance Product (GRP) Radiometric
   ;  Camera-by-camera Cloud Mask (RCCM) files:
   rccm_product = 'GRP_RCCM_GM'
   rccm_version = 'F04_0025'
   rccm_esdt = 'MIRCCM.004/'

   ;  MISR L2 Aerosol/Surface (AS) Aerosol Product (AP) files:
   aero_product = 'AS_AEROSOL'
   aero_version = 'F13_0023'
   aero_esdt = 'MIL2ASAE.003/'

   ;  MISR L2 Aerosol/Surface (AS) Land Surface Product (LSP) files:
   land_product = 'AS_LAND'
   land_version = 'F08_0023'
   land_esdt = 'MIL2ASLS.003/'

   IF (debug) THEN BEGIN

   ;  Return to the calling routine with an error message if one or more
   ;  positional parameters are missing:
      n_reqs = 1
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter(s): misr_path.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'misr_path' is invalid:
      rc = chk_misr_path(misr_path, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 110
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Set the initial and final dates to consider:
   IF (KEYWORD_SET(start_time)) THEN BEGIN
      IF (debug) THEN BEGIN
         rc = chk_isodate(start_time, DEBUG = debug, EXCPT_COND = excpt_cond)
         IF (rc NE 0) THEN BEGIN
            error_code = 120
            excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
               rout_name + ': ' + excpt_cond
            RETURN, error_code
         ENDIF
      ENDIF
   ENDIF ELSE BEGIN
      start_time = '2000-02-24T00:00:00Z'
   ENDELSE

   IF (KEYWORD_SET(end_time)) THEN BEGIN
      IF (debug) THEN BEGIN
         rc = chk_isodate(end_time, DEBUG = debug, EXCPT_COND = excpt_cond)
         IF (rc NE 0) THEN BEGIN
            error_code = 130
            excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
               rout_name + ': ' + excpt_cond
            RETURN, error_code
         ENDIF
      ENDIF
   ENDIF ELSE BEGIN
      end_time = today(FMT = 'iso')
   ENDELSE

   ;  Set the data types to get:
   misr_data_types = ['BR', 'GRP_GM', 'GRP_LM', 'RCCM', 'GPP', 'LAND', 'AERO']

   IF (KEYWORD_SET(data_types)) THEN BEGIN
      n_mdt = N_ELEMENTS(data_types)
      IF (debug) THEN BEGIN
         IF (is_string(data_types) NE 1) THEN BEGIN
            error_code = 140
            excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
               ': Optional keyword parameter data_types must be a STRING.'
            RETURN, error_code
         ENDIF
         IF (is_array(data_types) NE 1) THEN BEGIN
            error_code = 150
            excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
               ': Optional keyword parameter data_types must be an array.'
            RETURN, error_code
         ENDIF
         FOR i = 0, n_mdt - 1 DO BEGIN
            idx = WHERE(data_types[i] EQ misr_data_types, count)
            IF (count LT 1) THEN BEGIN
               error_code = 160
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': At least one of the elements of the ' + $
                  'optional keyword parameter data_types array is invalid.'
               RETURN, error_code
            ENDIF
         ENDFOR
      ENDIF
   ENDIF ELSE BEGIN
      data_types = misr_data_types
      n_mdt = N_ELEMENTS(data_types)
   ENDELSE

   ;  Set the MISR specifications:
   misr_specs = set_misr_specs()
   n_cams = misr_specs.NCameras
   cams = misr_specs.CameraNames

   ;  Identify the current operating system and computer name:
   rc = get_host_info(os_name, comp_name, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (rc NE 0) THEN BEGIN
      error_code = 98
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
   ENDIF

   ;  Set the default folders and version identifiers of the MISR and
   ;  MISR-HR files on this computer, and return to the calling routine if
   ;  there is an internal error, but not if the computer is unrecognized:
   rc = set_roots_vers(root_dirs, versions, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (rc NE 0) THEN BEGIN
      error_code = 99
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Get today's date:
   date = today(FMT = 'ymd')

   ;  Get today's date and time:
   date_time = today(FMT = 'nice')

   ;  Generate the string version of the MISR Path number:
   rc = path2str(misr_path, misr_path_str, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 200
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Set the values of the output paths optionally set by keyword
   ;  parameters.

   ;  Set the root directory where files will be found at NASA Langley:
   pool_prefix = '/pub/MISR/'

   ;  Set the home directory address of this computer:
   homes = FILE_SEARCH('~')
   home = homes[0] + PATH_SEP()

   ;  Set the directory address of the local folder to contain the output
   ;  script file, if it has not been specified explicitly:
   IF (~KEYWORD_SET(ftpscript_path)) THEN BEGIN
      ftpscript_path = home + 'MISR_HR/Input/Datapool/'
   ENDIF

   ;  Create the output directory 'ftpscript_path' if it does not exist:
   res = is_writable_dir(ftpscript_path, /CREATE)
   IF (debug AND (res NE 1)) THEN BEGIN
      error_code = 400
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
         rout_name + ': The directory ftpscript_path is unwritable.'
      RETURN, error_code
   ENDIF

   ;  Set the directory address of the local folder to contain the output
   ;  log file, if it has not been specified explicitly:
   IF (~KEYWORD_SET(log_path)) THEN BEGIN
      log_path = home + 'MISR_HR/Input/Datapool/'
   ENDIF

   ;  Create the output directory 'log_path' if it does not exist:
   res = is_writable_dir(log_path, /CREATE)
   IF (debug AND (res NE 1)) THEN BEGIN
      error_code = 410
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
         rout_name + ': The directory log_path is unwritable.'
      RETURN, error_code
   ENDIF

   ;  Set the directory address of the local folder to contain the MISR files
   ;  to be downloaded from NASA:
   IF (~KEYWORD_SET(data_path)) THEN BEGIN
      data_path = home + 'MISR_HR/Input/MISR/' + misr_path_str + PATH_SEP()
   ENDIF

   ;  Create the output directory 'data_path' if it does not exist:
   res = is_writable_dir(data_path, /CREATE)
   IF (debug AND (res NE 1)) THEN BEGIN
      error_code = 420
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
         rout_name + ': The directory data_path is unwritable.'
      RETURN, error_code
   ENDIF

   ;  Set the list of the MISR Orbits that need to be retrieved:
   status = MTK_PATH_TIMERANGE_TO_ORBITLIST(misr_path, start_time, $
      end_time, orbit_cnt, orbit_list)
   IF (debug) THEN BEGIN
      IF (status NE 0) THEN BEGIN
         error_code = 600
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Status from MTK_PATH_TIMERANGE_TO_ORBITLIST = ' + strstr(status)
         RETURN, error_code
      ENDIF
      IF (orbit_cnt EQ 0) THEN BEGIN
         error_code = 610
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': MTK_PATH_TIMERANGE_TO_ORBITLIST returned an empty Orbit list.'
         RETURN, error_code
      ENDIF
   ENDIF
   frst_orbit = orbit_list[0]
   last_orbit = orbit_list[orbit_cnt - 1]

   ;  Generate the string version of the MISR frst_orbit:
   rc = orbit2str(frst_orbit, frst_orbit_str, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 210
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Generate the string version of the MISR last_orbit:
   rc = orbit2str(last_orbit, last_orbit_str, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 220
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Set the names and specifications of the script and log files:
   ftpscript_name = 'FTPscript_datapool_MISR_' + misr_path_str + $
      '_' + frst_orbit_str + '-' + last_orbit_str + '_' + date + '.txt'
   ftpscript_spec = ftpscript_path + ftpscript_name
   log_name = 'Log_datapool_MISR_' + misr_path_str + $
      '_' + frst_orbit_str + '-' + last_orbit_str + '_' + date + '.txt'
   log_spec = log_path + log_name

   ;  Initialize the log file:
   fmt1 = '(A30, A)'

   OPENW, log_unit, log_spec, /GET_LUN
   PRINTF, log_unit, 'File name: ', FILE_BASENAME(log_spec), $
      FORMAT = fmt1
   PRINTF, log_unit, 'Folder name: ', FILE_DIRNAME(log_spec, $
      /MARK_DIRECTORY), FORMAT = fmt1
   PRINTF, log_unit, 'Generated by: ', rout_name, FORMAT = fmt1
   PRINTF, log_unit, 'Generated on: ', comp_name, FORMAT = fmt1
   PRINTF, log_unit, 'Saved on: ', date_time, FORMAT = fmt1
   PRINTF, log_unit

   PRINTF, log_unit, 'Content: ', 'Log of ftp script creation.', FORMAT = fmt1
   PRINTF, log_unit
   PRINTF, log_unit, 'MISR Path: ', misr_path_str, FORMAT = fmt1
   PRINTF, log_unit, 'Start time: ', start_time, FORMAT = fmt1
   PRINTF, log_unit, 'End time: ', end_time, FORMAT = fmt1
   PRINTF, log_unit, 'First MISR Orbit: ', frst_orbit_str, FORMAT = fmt1
   PRINTF, log_unit, 'Last MISR Orbit: ', last_orbit_str, FORMAT = fmt1
   PRINTF, log_unit, 'MISR data requested: ', strcat(data_types, ', '), $
      FORMAT = fmt1

   idx = WHERE(data_types EQ 'BR', count)
   IF (count EQ 1) THEN BEGIN
      PRINTF, log_unit, 'MISR Browse version: ', br_version, FORMAT = fmt1
   ENDIF

   idx = WHERE(data_types EQ 'GRP_GM', count)
   IF (count EQ 1) THEN BEGIN
      PRINTF, log_unit, 'MISR GRP_GM version: ', grp_gm_version, FORMAT = fmt1
   ENDIF

   idx = WHERE(data_types EQ 'GRP_LM', count)
   IF (count EQ 1) THEN BEGIN
      PRINTF, log_unit, 'MISR GRP_LM version: ', grp_lm_version, FORMAT = fmt1
   ENDIF

   idx = WHERE(data_types EQ 'GPP', count)
   IF (count EQ 1) THEN BEGIN
      PRINTF, log_unit, 'MISR GPP version: ', gpp_version, FORMAT = fmt1
   ENDIF

   idx = WHERE(data_types EQ 'RCCM', count)
   IF (count EQ 1) THEN BEGIN
      PRINTF, log_unit, 'MISR RCCM version: ', rccm_version, FORMAT = fmt1
   ENDIF

   idx = WHERE(data_types EQ 'AERO', count)
   IF (count EQ 1) THEN BEGIN
      PRINTF, log_unit, 'MISR L2 Aero version: ', aero_version, FORMAT = fmt1
   ENDIF

   idx = WHERE(data_types EQ 'LAND', count)
   IF (count EQ 1) THEN BEGIN
      PRINTF, log_unit, 'MISR L2 Land version: ', land_version, FORMAT = fmt1
   ENDIF

   PRINTF, log_unit
   PRINTF, log_unit, 'FTP script file name: ', FILE_BASENAME(ftpscript_spec), $
      FORMAT = fmt1
   PRINTF, log_unit, 'FTP script folder name: ', FILE_DIRNAME(ftpscript_spec), $
      FORMAT = fmt1
   PRINTF, log_unit, 'Data initially stored in: ', data_path, FORMAT = fmt1

   ;  Initialize the script file:
   OPENW, ftpscript_unit, ftpscript_spec, /GET_LUN
   PRINTF, ftpscript_unit, data_path

   ;  Set the STRING version of the MISR Path without the header:
   rc = path2str(misr_path, misr_path_s, /NOHEADER)

   ;  Loop over the MISR Orbits to download:
   n_files_download = 0L
   FOR orbit = frst_orbit, last_orbit, 233 DO BEGIN

   ;  Set the STRING version of the current MISR Orbit without the header:
      rc = orbit2str(orbit, orbit_s, /NOHEADER)

   ;  Retrieve the date of acquisition of the current Orbit:
      data_date = orbit2date(orbit, /DATAPOOL)

   ;  Programming note: The MISR Toolkit routine MTK_MAKE_FILENAME available
   ;  in version 1.4.5 systematically adds the extension '.hdf' to the
   ;  filenames. When other extensions are required (e.g., '.jpg' for the
   ;  Browse Product or '.nc' for the more recent L2 products), the filenames
   ;  are first generated with the '.hdf' extension and subsequently updated
   ;  as needed. Also, when requesting Local Mode files, the filenames must
   ;  be modified to insert '_SITE_*_' between the camera name and the version
   ;  identifier to match the (unspecified) local mode site name.

   ;  Loop over the MISR data files to download:
      FOR j = 0, n_mdt - 1 DO BEGIN
         CASE data_types[j] OF
            'BR': BEGIN

   ;  Set the NASA Langley path to the Browse files:
               br_dir = pool_prefix + br_esdt + data_date
               PRINTF, ftpscript_unit, 'cd ' + br_dir

   ;  Set the ftp commands to retrieve the 9 JPEG image files:
               FOR cam = 0, n_cams - 1 DO BEGIN
                  status = MTK_MAKE_FILENAME('', br_product, $
                     cams[cam], misr_path_s, orbit_s, br_version, br_name)
                  br_name = FILE_BASENAME(br_name, '.hdf') + '.jpg'
                  PRINTF, ftpscript_unit, 'get ', br_name
               ENDFOR
               n_files_download = n_files_download + 9
            END

            'GRP_GM': BEGIN

   ;  Set the NASA Langley path to the GRP_GM files:
               grp_gm_dir = pool_prefix + grp_gm_esdt + data_date
               PRINTF, ftpscript_unit, 'cd ' + grp_gm_dir

   ;  Set the ftp commands to retrieve the 9 GRP_GM files:
               FOR cam = 0, n_cams - 1 DO BEGIN
                  status = MTK_MAKE_FILENAME('', grp_gm_product, $
                     cams[cam], misr_path_s, orbit_s, grp_gm_version, $
                     grp_gm_name)
                  PRINTF, ftpscript_unit, 'get ', grp_gm_name
               ENDFOR
               n_files_download = n_files_download + 9
            END

            'GRP_LM': BEGIN

   ;  Set the NASA Langley path to the GRP_LM files:
               grp_lm_dir = pool_prefix + grp_lm_esdt + data_date
               PRINTF, ftpscript_unit, 'cd ' + grp_lm_dir

   ;  Set the ftp commands to retrieve the 9 GRP_LM files:
               FOR cam = 0, n_cams - 1 DO BEGIN
                  status = MTK_MAKE_FILENAME('', grp_lm_product, $
                     cams[cam], misr_path_s, orbit_s, grp_lm_version, $
                     grp_lm_name)
                  parts = STRSPLIT(grp_lm_name, '_', /EXTRACT)
                  head = strcat(parts[0:7], '_')
                  tail = strcat(parts[8:*], '_')
                  grp_lm_name = head + '_SITE_*_' + tail
                  PRINTF, ftpscript_unit, 'get ', grp_lm_name
               ENDFOR
               n_files_download = n_files_download + 9
            END

            'GPP' : BEGIN

   ;  Set the NASA Langley path to the Geometric Parameters files:
               gpp_dir = pool_prefix + gpp_esdt + data_date
               PRINTF, ftpscript_unit, 'cd ', gpp_dir

   ;  Set the ftp command to retrieve the Geometric Parameter file:
               status = MTK_MAKE_FILENAME('', gpp_product, '', misr_path_s, $
                  orbit_s, gpp_version, gp_name)
               PRINTF, ftpscript_unit, 'get ', gp_name
               n_files_download = n_files_download + 1
            END

            'RCCM': BEGIN

   ;  Set the NASA Langley path to the RCCM files:
               rccm_dir = pool_prefix + rccm_esdt + data_date
               PRINTF, ftpscript_unit, 'cd ' + rccm_dir

   ;  Set the ftp commands to retrieve the 9 RCCM files:
               FOR cam = 0, n_cams - 1 DO BEGIN
                  status = MTK_MAKE_FILENAME('', rccm_product, $
                     cams[cam], misr_path_s, orbit_s, rccm_version, rccm_name)
                  PRINTF, ftpscript_unit, 'get ', rccm_name
               ENDFOR
               n_files_download = n_files_download + 9
            END

            'AERO': BEGIN

   ;  Set the NASA Langley path to the L2 Aerosol file:
               aero_dir = pool_prefix + aero_esdt + data_date
               PRINTF, ftpscript_unit, 'cd ', aero_dir

   ;  Set the ftp command to retrieve the aerosol file:
               status = MTK_MAKE_FILENAME('', aero_product, '', misr_path_s, $
                  orbit_s, aero_version, aero_name)
               aero_name = FILE_BASENAME(aero_name, '.hdf') + '.nc'
               PRINTF, ftpscript_unit, 'get ', aero_name
               n_files_download = n_files_download + 1
            END

            'LAND': BEGIN

   ;  Set the NASA Langley path to the L2 Land file:
               land_dir = pool_prefix + land_esdt + data_date
               PRINTF, ftpscript_unit, 'cd ', land_dir

   ;  Set the ftp command to retrieve the L2 Land file:
               status = MTK_MAKE_FILENAME('', land_product, '', misr_path_s, $
                  orbit_s, land_version, land_name)
               land_name = FILE_BASENAME(land_name, '.hdf') + '.nc'
               PRINTF, ftpscript_unit, 'get ', land_name
               n_files_download = n_files_download + 1
            END

            ELSE: BREAK
         ENDCASE
      ENDFOR
   ENDFOR

   PRINTF, log_unit, 'Number of files to download: ', $
      strstr(n_files_download), FORMAT = fmt1

   CLOSE, ftpscript_unit
   FREE_LUN, ftpscript_unit
   CLOSE, log_unit
   FREE_LUN, log_unit

   IF (verbose GT 0) THEN BEGIN
      PRINT, 'The script file has been saved in ' + ftpscript_spec
      PRINT, 'The log file has been saved in ' + log_spec
   ENDIF
   IF (verbose GT 1) THEN PRINT, 'Exiting ' + rout_name + '.'

   RETURN, return_code

END
