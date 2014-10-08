/// \mainpage IGFramework (Static library) Documentation project
///  
///  <b>Main configuration for the project</b>
///  
///  IGConfiguration.h
///
///  IGFramework
///
///  Created by Ondrej Rafaj on 22.3.10.
///
///  Copyright 2010 Home. All rights reserved.
///

#pragma mark Google API

// Google maps API key
#ifdef kIGGoogleAPIMapsKey
#else

#define kIGGoogleAPIMapsKey											@""

#endif

#pragma mark Filesystem & paths

// Root folder name for IGFilesystemPaths
#ifdef kIGFilesystemPathsFolder
#else

#define kIGFilesystemPathsFolder									@"~"

#endif

#pragma mark UITableView & UIView template

// Root folder name for IGFilesystemPaths
#ifdef kIGTableViewGroupedBackground
#else

#define kIGTableViewGroupedBackground								@"bcg.png"

#endif
