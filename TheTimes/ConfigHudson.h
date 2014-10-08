

// ******************************************************
// ***** defines managed by Hudson jobs:
// *****      http://digsolserver.local:8080/job/on-demand.thesun-ipad/build
// *****      http://digsolserver.local:8080/job/APPSTORE.thesun-ipad/build
// *****
// ***** This is hopefully only a temporary measure - there are plans to store
// ***** most of the config in a file on some server.
// ***** The defines in this file are 'managed' by Hudson - i.e. Hudson variables
// ***** overwrite their values.  You can edit this file, change the values and check it in,
// ***** but please do not move defines here somewhere else
// *****
// ******************************************************



// ******************************************************
// ***** Feed
// ******************************************************


//#define kWebServicePath									@"http://nipdf.central-sq.com/sunfeed/global-staging.json"  //THIS IS FOR RO PRE-PROD
//#define kWebServicePath									@"http://nipdf.central-sq.com/sunfeed/global.json" //THIS IS FOR LO NO PAY WALL



//#define kWebServicePath									@"http://10.194.193.175/timeslite/goodglobal.json"
//#define kWebServicePath									@"http://10.194.193.175/timeslite/global.json"

//#define kWebServicePath									@"http://thesun.nidigitalsolutions.co.uk/thesunfeed/"
//#define kWebServicePath									@"http://dev.nidigitalsolutions.co.uk/thesunfeed/"
//#define kWebServicePath									@"http://nistaging.central-sq.com/sunfeed/global-staging-v122.json"
//#define kWebServicePath									@"http://nistaging.central-sq.com/sunfeed/global-staging-v122.json"
//#define kWebServicePath									@"http://nipdf.central-sq.com/sunfeed/global-v122.json"
//#define kWebServicePath									@"http://nistaging.central-sq.com/sunfeed/global.json"
//#define kWebServicePath									@"http://nistaging.central-sq.com/sunfeed/global-staging.json"

// ******************************************************
// ***** InApp Purchasing
// ******************************************************
#define INAPP_BASE_URL							@"http://dev.nidigitalsolutions.co.uk/inapp/sun/dev/"    // Development

#if TARGET_IPHONE_SIMULATOR
   #define kInAppPurchaseNeverExpires 1		// WARNING: if 1 then subscription is considered 'active' regardless of anything else 
#else
   #define kInAppPurchaseNeverExpires 0		// WARNING: if 1 then subscription is considered 'active' regardless of anything else 
#endif


