File: ReadMe.txt
Version: 2.0, 28 Jan 2019

Important notice: Most IDL routines previously distributed through this GitHub set of repositories have been updated and upgraded in sometimes significant ways in late 2018 and early 2019, e.g., by adding positional or keyword parameters, by changing the order of positional parameters, by adding functionality, by changing routine names (for better internal coherency) or by updating the documentation. All older routines bear a version number 1.x; they are internally consistent and can still be used, but are now deprecated and will not be maintained. All new routines have a version number 2.yy and are also internally consistent, but may not be compatible with the older set. Hence, do not mix and match routines from both sets. It is highly recommended to download and install these new versions, and delete older versions.


This repository contains a series of IDL routines (.pro files) which are documented in an HTML file with the same name as the repository.

Installation recommendation: copy all routines contained in this repository
- in a folder accessible by IDL, or
- in a new folder and edit the IDL PATH to include the directory address to this new folder in its list of places to search for routines.

To update the IDL PATH, within the IDLDE (workbench) environment,
- select the 'Preferences' item in 'IDL' main menu,
- click on the 'IDL' item to show the submenu,
- select 'Path' to show the current IDL Path and verify that it includes the folder or add the directory address to that new folder, and
- select 'Apply' and then 'End' to complete the IDL Path update.

These IDL routines will then automatically be available for use in your own programs.

Please note that
- older versions of routines will not be maintained,
- routines in one repository of this IDL tool kit may depend on routines made available in other repositories; to ensure consistency, update all repositories simultaneously,
- in principle, dependencies between repositories follow the sequence

Macros < Utilities < MISR Tools < MISR Datapool < MISR AGP < MISR RCCM < MISR L1B2 < MISR-HR L1B3 < MISR-HR BRF < MISR-HR RPV < MISR-HR TIP

where each repository may depend on subsets of routines contained in lower level repositories.

[IDL is a TradeMark of Harris Geospatial Solutions]
