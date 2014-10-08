//
//  trackingClass.h
//  TheSun
//
//  Created by Alan Churley on 20/03/2013.
//
//

#import <Foundation/Foundation.h>
#import "GAI.h"
#import "AppMeasurement.h"

@interface trackingClass : NSObject

@property(nonatomic,assign)id<GAITracker> googleTracker;
@property(nonatomic,assign)AppMeasurement *omnatureTracker;

-(BOOL)initGoogleTracking:(NSString*)trackingID;
+(trackingClass *)getInstance;
-(AppMeasurement *)returnOmnature;
-(id<GAITracker>)returnInstance;
-(void)initOmnature;
-(void)firePageLoad;

@end


