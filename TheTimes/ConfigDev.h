//
//  ConfigDev.h
//  TheSun
//
//
// ***********************************************************************
// **** A.Szymanski 1-Oct-2010
// ****     availablePapersURL, alternativePapersURL & kUseAlternativeJSON
// **** replaced by only one define: availablePapersURL, which will be 
// **** defined in hudson, and therefore this constant has been moved 
// **** to ConfigHudson.h file
// ****
// ****
// ****
// ****      
// ****
// ***********************************************************************


// system
#define kSecondsIgnoreNewEditionCheck				5		// number of seconds before a fresh edition check would be made

#define kSecondsIgnoreNewSubsCheck					60		// number of seconds before a fresh subscription check would be made

#define kFlurryKey @"3219WDXU7696JRMV7MQD"

#define kCachedGlobalJSON @"globalJson"

#define kDebugMode									NO		// turn on debug mode to get NSLog for important parts

#define kIsDevelopmentVersion						YES		// disable for the release version to get rid of dev messages !!!!!!!!!!!!!!!!!!

#define kDeleteCacheFilesAfter						1		// set 3 to delete files older than three days (will delete only if internernet is available)

// feeds

#define kTestNoData									NO		// test no data for live feed

#define kUseTestData								NO		// use test articles, use if there broken feed, etc ..

#define kLoadLiveData								YES		// allow loading articles and app info during the start

#define kUseCaching									YES		// enables caching for images and feeds

#define kMaxArticlesInHeadImageView					5		// maximal number of articles in head image news section

#define kMaxArticlesInBreakingNewsView				10		// maximal number of articles in breaking news section

#define kMaxArticlesInAllNewsView					15		// maximal number of articles in all news section

#define kMaxCategoryIndexInAllNewsView				6		// maximal number of feed categories in the all news section

#define kHeadNewsId									8		// use id to find head news in feed
#define kBreakingNewsId								1		// use id to find breaking news in feed

#define kTickerNewsId								12		// use id to find ticker news in feed
#define kTickerHeight								25
#define kTickerAdditonalTouchHeight					20
#define kTickerViewWidth							560


#define kTickerNewsId								12		// use id to find ticker news in feed
#define kTickerHeight								25
#define kTickerAdditonalTouchHeight					20
#define kTickerViewWidth							560


#define kMaxNumberOfImagesToDownload				5		// maximum number of images per object you can download at the same time

#define kCoreDataDatabase							@"kCoreDataDatabase.sqlite"

//#define FEEDCHECKURL							@"dev.nidigitalsolutions.co.uk"
#define INAPPCHECKURL							@"http://inapp.uat.nidigitalsolutions.co.uk/tt/admin/device_subscription_verify_2.0.php"
#define PDFCHECKURL							    @"nipdf.central-sq.com"
#define SLOWFETCHTHRESHOLD	3
#define REACHABILITYCHECKURL					@"http://www.thetimes.co.uk/robots.txt"

//#define kDataUrl									@"http://thesun.nidigitalsolutions.co.uk/thesunfeed/"
#define kDataUrl									@"http://nidigitalsolutions:d3v3l0pm3Nt@dev.nidigitalsolutions.co.uk/thesunfeed123/"

// images

#define kUseImageDownloadDelay						YES		// enable for 0.3 sec slow down for every image download

#define kRemoveBordersFromImages					YES		// remove 1px frame from images

#define kUseKImageForHead							YES		// use HD images for the head news image article section

// Sun Paper variables

//#define availablePapersURL							@"http://nipdf.central-sq.com/sunfeed/global.json"
//#define availablePapersURL								@"http://dev.nidigitalsolutions.co.uk/thesun/page3/global-v122.json"
//#define availablePapersURL								@"http://192.168.241.190:8002/global-v122.json"

//#define availablePapersKey							@"availablePapers"

#define kDisableBilling								YES 		// disable billing on the home screen

//#define kEnableKeyChain								NO


#define kContactUrl									@"http://downloads.timesonline.co.uk/ipad/legal/contact.html"
#define kCreditsUrl									@"http://downloads.timesonline.co.uk/ipad/legal/credits.html"
#define kPrivacyUrl									@"http://downloads.timesonline.co.uk/ipad/legal/privacy.html"
#define kTsandcsUrl									@"http://downloads.timesonline.co.uk/ipad/legal/tsandcs.html"
#define kHowToUrl									@"http://downloads.timesonline.co.uk/ipad/legal/about.html"