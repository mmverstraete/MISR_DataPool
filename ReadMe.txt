File: ReadMe.txt
Version: 2.1.x, 26 Oct 2019

Important notice: Most IDL routines previously distributed through this GitHub set of repositories have been updated and upgraded in sometimes significant ways between late 2018 and October 2019, e.g., by modifying positional or keyword parameters, by changing the order of positional parameters, by adding functionality, by changing routine names (for better internal coherency), by transferring routines between repositories, or by updating the documentation. A few routines that duplicated basic IDL functionality have been deleted and not replaced in more recent releases.

Older routines bear a 2-parts version number of 1.x or 2.x: they are internally consistent and can still be used, but are now deprecated and will not be maintained. Starting in mid-2019, all routines have been assigned a 3-parts version number 2.y.z (starting at 2.1.0); they are also internally consistent, but may not be compatible with the older sets. Hence, do not mix and match routines with 2-parts and 3-parts version numbers. It is highly recommended to download and install the latest versions, and delete older versions, though this may require some updates in your codes.

This repository contains a series of IDL routines (.pro files) which are documented in an HTML file named "doc_[rep_name].html" where [rep_name] is the repository name.

Installation recommendation: copy all routines contained in this repository
- in a folder accessible by IDL, or
- in a new folder and edit your IDL PATH to include the directory address to this new folder in its list of places to search for routines.

To update the IDL PATH, within the IDLDE (workbench) environment,
- select the 'Preferences' item in 'IDL' main menu,
- click on the 'IDL' item to show the submenu,
- select 'Path' to show the current IDL Path and verify that it includes the folder or add the directory address to that new folder, and
- select 'Apply' and then 'End' to complete the IDL Path update.

These IDL routines will then automatically be available for use in your own programs.

Please remember that
- older versions of routines will not be maintained,
- routines in one repository may depend on routines available in other repositories of the same GitHub site; to ensure consistency, update all repositories simultaneously,
- in principle, dependencies between repositories follow the sequence

Macros < Utilities < MISR_Tools < MISR_Datapool < MISR_AGP < MISR_RCCM < MISR_L1B2 < MISR_HR_Tools < MISR_HR_L1B3 < MISR_HR_BRF < MISR_HR_RPV < MISR_HR_TIP

where each repository may depend on subsets of routines contained in lower level repositories. Repositories that are not yet available are in preparation.

[IDL is a TradeMark of Harris Geospatial Solutions]
