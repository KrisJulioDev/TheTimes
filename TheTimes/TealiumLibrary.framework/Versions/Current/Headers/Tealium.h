//
//  Tealium.h
//
//  ------------
//  *** INFO ***
//  ------------
//  Version: 3.1
//  Minimum OS Version supported: iOS 5.0+
//  Brief: The is the primary TealiumiOS library class object for tracking analytics data on iOS devices.  It includes both the autotracking and Mobile Companion features. The below methods in this header file are the only public methods needed to initialize and run the library. Configuration should be done from Tealium's IQ dashboard at https://www.tealium.com
//  Authors: Originally Created by Charles Glommen and Gautam Day, rewritten and maintained by Jason Koo
//  Copyright: (c) 2014 Tealium, Inc. All rights reserved.
//
//  ----------------------------------
//  *** QUICK INSTALL INSTRUCTIONS ***
//  ----------------------------------
//  1. Copy the entire TealiumiOSLibrary.framework folder (including this header file) into your XCode project
//
//  2. Link the following 6 frameworks to your project:
//
//    * AVFoundation.framework
//    * CoreGraphics.framework
//    * CoreMedia.framework
//    * CoreTelephony.framework
//    * MediaPlayer.framework
//    * SystemConfiguration.framework
// 
//  3. Add "-all_load -ObjC" as a flag option to your project's Build Settings: Other Linker Flags
// 
//  4. Add the class level init method (initSharedInstance:profile:target:options:) to your app delegate or wherever your primary root controller is initialized
// 
//  5. Add "#import <TealiumTealiumiOSLibrary/TealiumiOSTagger.h>" to your -Prefix.pch file, within the #ifdef __OBJC__ statement for app wide access. Otherwise, add this import statment in the header file of every object that will make use of the library.
//
//  -----------------------
//  *** ADDITIONAL INFO ***
//  -----------------------
//  See the github Readme.md file at: https://github.com/Tealium/ios-library for the full developer instruction set and for a partical list of automatically tracked default data source keys and expected values. You will require a Github account and permissions approval by your Tealium Account Manager to access.
// 
//  Checkout our mobile related articles at http://community.tealiumiq.com for the most recent information, including an up-to-date list of all automatically tracked default data source keys and expected values. See your Tealium Account Manager for access.

#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>

@interface Tealium : NSObject

#pragma mark - INITIALIZATION
/*
 Available init option values - these must be set at init time and can not be changed remotely. NOTE: Setting your target environment to "prod" will force enable TLSuppressLogs option and ignore the TLDisableHTTPS option */
enum {
    TLNone                      = 0,
    TLSuppressLogs              = 1 << 0, /** Suppresses all non-error logs*/
    TLDisableExceptionHandling  = 1 << 1, /** Turns off crash tracking*/
    TLDisableLifecycleTracking  = 1 << 2, /** Turns off launch, wake, sleep & terminate reporting */
    TLDisableHTTPS              = 1 << 3, /** Switches from HTTPS to HTTP - NOT recommended for production release*/
    TLDisplayVerboseLogs        = 1 << 4, /** Print verbose logs to the console*/
    TLPauseInit                 = 1 << 5  /** Delays startup until resumeInit method called*/
};
typedef NSUInteger TealiumOptions;

// Support for pre 3.1 release namespace - Will be deprecated in next version
typedef Tealium TealiumiOSTagger;

/**
 Recommended Class-level init method. Available version 3.0+
 
 @warning Class-level messages are convenience messages for when a single account/profile/environment context exists. However, if more than one tealium context is needed (unlikely), or a dependency injection framework is already employed, it is recommended to directly utilize the instance init message init:profile:target:rootController:.
 @param accountName NSString of your Tealium account name
 @param profileName NSString of your account-profile name
 @param environmentName NSString Target environment (dev/qa/prod)
 @param options Tealium Options to configure the library. Multiple options may be used using a pipe (|) operator between options. Enter "0" or TLNone for no options.
 */
+ (Tealium*) initSharedInstance: (NSString*) accountName
                                 profile: (NSString*) profileName
                                  target: (NSString*) environmentName
                                 options: (TealiumOptions) options ;

/**
 Legacy version 1.0 Class-level init method.
 
 This method now calls the new recommended Class-level init method above, with no options.
 @param accountName Name of Tealium account
 @param profileName Target Account profile
 @param environmentName Target profile environment (dev, qa, etc.)
 */
+ (Tealium*) initSharedInstance: (NSString*) accountName
                                 profile: (NSString*) profileName
                                  target: (NSString*) environmentName;

/**
 Legacy version 2.0 Class-level init method. Use initSharedInstance:profile:target:options: instead. The root controller argument is now ignored and will be determined by the library - Will be deprecated next update.
 
 @param accountName NSString of your Tealium account name
 @param profileName NSString of your Tealium account-profile
 @param enviornmentName NSString of the target environment (dev/qa/prod)
 @param rootController UIViewController object that is root controlling object - library now auto finds this
 */
+ (Tealium*) initSharedInstance: (NSString*) accountName
                                 profile: (NSString*) profileName
                                  target: (NSString*) environmentName
                          rootController: (id) rootController;

/**
 For accessing the Tealium Library Singleton
 */
+ (Tealium*) sharedInstance;

/**
 Optional initialization method for creating multiple instances of the Tealium Tagger. This is NOT a recommended best practice, as additional mapping and tag configuration should occur within Tealium IQ.  This method is provided in the event you need to map data to 2 or more Tealium accounts.  Note, if autotracking is enabled (on by default), duplicate calls will result.
 
 @warning Class-level messages are convenience messages for when a single account/profile/environment context exists. However, if more than one tealium context is needed (unlikely), or a dependency injection framework is already employed, it is recommended to directly utilize the instance init message init:profile:target:navigationController:
 @param accountName Name of Tealium account
 @param profileName Target Account profile
 @param environmentName Target profile environment (dev, qa, etc.)
 @param rootController Root view controller. May be a UINavigationController, UITabeBarController or UISplitViewController. If parameter passed is nil then autoTracking will be disabled.
 */
- (Tealium*) init: (NSString*) accountName
                   profile: (NSString*) profileName
                    target: (NSString*) environmentName
                   options: (TealiumOptions) options;

/**
 Call this method if the TLPauseInit option was used in the library's init method to finalize the startup sequence. This option is required if you wish to add global custom data BEFORE the initial wake calls.
 */
- (void) resumeInit;

#pragma mark - MANUAL TRACKING METHODS
/*
 *  --------------------------------------------------------------------------
 *  !!! WARNING !!! Use these methods directly only if the autotracking feature is DISABLED or unable to track the target object. Double call dispatches may result otherwise.
 *  --------------------------------------------------------------------------
 */

// Call type options for manual track methods
extern NSString * const TealiumEventCall;
extern NSString * const TealiumViewCall;

/**
 New universal method for firing all manual tracking calls. Takes advantage of the auto-detected default data sources and additional Custom Data methods below (ie addCustomData:to: and addGlobalCustomData:).
 @param object The NSObject associated with the call.  Use UIViewControllers instead of UIView's for view tracking
 @param eventData NSDictionary with custom data. Keys become Tealium IQ Data Sources. Values will be the value passed into the analytic variable mapped to the Data Source.
 @param callType NSString of call type - use either provided constants "TealiumViewCall" for views or "TealiumEventCall" for events - other string values reserved for future use.
 */
- (void) track:(id) object
    customData:(NSDictionary*) customData
            as:(NSString*)callType;

#pragma mark - ADDITIONAL CUSTOM DATA
/*
 *  --------------------------------------------------------------------------
 *  *** NOTE *** The library's initial wake and view calls may occur before the below methods have had a chance to complete.  To ensure any custom global data is added to the library before these first calls, be sure to use the TLPauseInit option in the init method.  After all your custom data has been added, use the resumeInit call to complete the init process.
 *  --------------------------------------------------------------------------
 */

/**
 Add data source-value pairs to future calls related to the target object.
 
 @param dict NSDictionary of any additional data to pass to Tealium. Can not be nil
 @param object The object to attach the dict data to. Can not be nil
 */
- (void) addCustomData:(NSDictionary*)customData to:(NSObject*)object;

/**
 Adds multiple data source-value pairs to ALL objects for all future tracking calls
 
 @param customData NSDictionary of key-value pairs to become data source-value pairs in Tealium IQ. Nil will result in a NO return
 */
- (void) addGlobalCustomData:(NSDictionary*)customData;


#pragma mark - INFORMATION
/*
 *  --------------------------------------------------------------------------
 *  *** NOTE *** Mobile Companion is the recommended means of reading and confirming
 *  data tracked by the library outside of the dev console logs
 *  --------------------------------------------------------------------------
 */

/**
 Retrieves a Tealium generated Universally Unique Identifier that distinguishes the current device and app from other devices with your application.  If this UUID is not already available, it will generate a new UUID before returning. Use this method if you want to make use of the same id. NOTE: Do not confuse this with the deprecated UDID, which is no longer permitted by Apple
 
 @return An NSString object
 */
- (NSString*) retrieveUUID;

#pragma mark - OVERRIDE COMMANDS

/**
 Puts Tealium tagger to permenant sleep. This is an optional method if your app has a manual option for users to disable analytic tracking. Enable must be called to reactivate. Supercedes any remote configuration settings.
 */
- (void) disable;

/**
 To re-enable the library from a disable call.
 */
- (void) enable;

/**
 Method for overriding the default Tealium mobile html url destination for retrieving configuration and mapping data. Use a FULL url address (ie: HTTPS://www.mywebsite.com) NOTE: It is recommended you use the TLPauseInit option when using this method. Also note this method overrides the TLDisableHTTPS init option.
 @param override NSString of the full URL to override default with
 */
- (void) setMobileHtmlUrlOverride:(NSString*)override;

/**
 Overwrites Tealium's UUID created string. NOTE: Do not confuse UUID with the deprecated UDID, the identifier no longer supported by Apple
 
 @param uuid NSString to set Tealium UUID with
 @return BOOL answer if new UUID successfully overwrote Tealium's default
 */
- (BOOL) setUUID:(NSString*)uuid;

#pragma mark - AUTOTRACKING METHODS

#ifndef COMPACT
/**
 Use this method to temporarily delay a call associated with the target object (View calls for views and UIViewController, events calls for buttons, sliders, etc.). Calls will be staged into a delay queue and will remain there until the resumeAutoTrackingOf: message is called. This method only works on autotracked objects and will not affect manual track calls.
 @param object Target object to pause tracking of
 */
- (void) pauseAutoTrackingOf:(id)object;

/**
 Use this method to continue autotracking calls associated with the target object. All calls in the delay queue will be dispatched in the order they were saved.
 @param object Target object to continue tracking
 */
- (void) resumeAutoTrackingOf:(id)object;

/*
 Overwrite any prior Tealium Id string assigned to an object.
 @param tealiumId Tealium Reference ID of object to track.  Use 6 or more alphanumberic characters to avoid namespace collisions with automatically assigned library ids.
 @param object Object to track - Must be a subclass of NSObject
 */
- (void) setTealiumId:(NSString*)tealiumId to:(id)object;

/**
 Track video player milestones
 @param milestones NSArray of percent video completed as NSNumber floats (0.5 = halfway, 1.0 = finished). Does not need to be ordered.
 @param object The AVPlayerItem, AVPlayer, MPMoviePlayerViewController or MPMoviePlayerController to add milestone tracking to.
 */
- (void) autoTrackVideoDurationPercentMilestones:(NSArray*)milestones of:(id)object;


#pragma mark - DEPRECATED (NO LONGER SUPPORTED) METHODS
/**
 Deprecated method. Use addCustomData:to: instead. Add a custom data source-value pair to an object for all it's event tracking calls.
 
 @param variable NSString variable key name that will be the Data Source key name. This is what will be entered in Tealium's IQ Data Sources tab.
 @param value The value of the variable. Must be an NSObject type (ie. NSString, NSDate, etc.). NSString types are recommended, otherwise the library will use an object's description property to determine the value to send.
 @param object The NSObject to assign the variable-value pair to
 @return Boolean indicating whether or not the data pair was successfully assigned to the object
 */
- (BOOL) addVariable:(NSString*)variable value:(NSObject*)value to:(id)object __attribute__((deprecated));

/**
 Deprecated method. Use addCustomData:to: instead. Add multiple variable-value pairs of data to an object.
 
 @param dict NSDictionary of any additional data to pass to Tealium
 @param object The object to attach the dict data to
 */
- (BOOL) addEventData:(NSDictionary*)dict to:(NSObject*)object __attribute__((deprecated));

/**
 Deprecated method. Use addGlobalCustomData: instead. Adds a variable-value for ALL objects for all event tracking calls
 
 @param variable The NSString key to set as the variable name of data pair
 @param value The value of the variable as an NSObject subclass
 @return Boolean indicating whether or not the variable and value were successfully saved.
 */
- (BOOL) addGlobalVariable:(NSString*)variable value:(NSObject*)value __attribute__((deprecated));

/**
 Deprecated method. Use addGlobalCustomData: insteadl. Adds multiple variable-value pairs to ALL objects for all event tracking calls
 
 @param variable Key
 @param key
 @return Boolean indicating whether or not the data dictionary was successfully added to the global utagVariables.
 */
- (BOOL) addGlobalEventData:(NSDictionary*)dictionary __attribute__((deprecated));

/*
 Exclude an object from the autotracking system. Note: If targeting a viewcontroller for exclusion, it's view and objects within it's view may also be excluded as well. Overrides any remote Library Manager settings for target object. Recommend using only for security reasons or if a particular object is causing problems with your build.
 
 @param object The NSObject subclass to exclude.
 */
- (void) excludeObjectFromAutotracking:(id)object __attribute__((deprecated));

/*
 Exclude multiple classes and their subclasses from the autotracking system. Ignores case.
 @param classNamesAsStrings Array of string values representing class types, as retrieved by NSStringFromClass() method.
 */
- (void) excludeClassesFromAutotracking:(NSArray*)classNamesAsStrings __attribute__((deprecated));

/**
 Deprecated method. Library will scan as needed.
 Force the library to rescan the root controller for autotrackable objects.  This call is recommended after any custom delegate reassignments so that the library can update it's delegate tracking.
 */
- (void) rescan __attribute__((deprecated));

/**
 Deprecated universal tracking method. Use track:customData:as: instead.
 @param object NSObject target of call
 @param title NSString title value for call
 @param eventData NSDictionary of additional custom data keys and values
 */
- (void) trackObject:(id) object
               title:(NSString*)title
           eventData:(NSDictionary*) eventData __attribute__((deprecated));

/**
 Deprecated method for tracking view appearances. Use track:customData:as: instead.  NOTE: Using this method will not retrieve information attached to an object via the Additional Custom Data methods.
 
 @warning If auto tracking navigation controller(s) is on (default is on), there is no
 need to use any trackScreenViewed_* messages, unless a view is being displayed
 which is not controlled by a navigation controller.
 @param title Custom title of view to track
 @param eventData Required format for utag data
 */
- (void) trackScreenViewedWithTitle:(NSString*) title
                      withEventData:(NSDictionary*) eventData __attribute__((deprecated));

/**
 Deprecated method for tracking view appearances. Use track:customData:as: method instead.
 
 @warning If the autotracking system is running and the viewController passed in is already being tracked, then duplicate calls will fire. Use only if the auto tracking methods are unable to hook onto a particular viewController.
 @param viewController UIViewController to track
 @param eventData Required format for utag data
 */
- (void) trackScreenViewedWithViewController:(UIViewController*) viewController
                               WithEventData:(NSDictionary*) eventData __attribute__((deprecated));

/**
 Deprecated method. Use track:customData:as: method instead. Analytic vendors will track this as a 'link' event. NOTE: Using this method will not retrieve information attached to an object via the Additional Custom Data methods.
 
 @param clickableItemId Uniquely assigned item identification string - becomes the "link_id" data source
 @param eventData NSDicitionary with any additional data to track. Nil acceptable.
 */
- (void) trackItemClicked:(NSString*) clickableItemId
            withEventData:(NSDictionary*) eventData __attribute__((deprecated));

/**
 Deprecated optional method. Use track:customData:as: call instead.
 */
- (void) trackCustomEvent:(NSString*) eventType
            withEventData:(NSDictionary*) eventData __attribute__((deprecated));

/**
 Deprecated manual caught exception call. Use track:customData:as method instead (using the NSException as the object). NOTE: Uncaught exceptions are recorded by the library and automatically sent upon next successful launch.
 */
- (void) trackCaughtException:(NSException*)exception __attribute__((deprecated));

/**
 Deprecated optional function.  See initWithSharedInstance:profile:target:options: for available code enabled options.  Mobile Companion is now exclusively controlled by your Library Manager extension settings in your Tealium IQ Dashboard.
 */
- (void) unlockMobileCompanion __attribute__((deprecated));


#endif

@end
