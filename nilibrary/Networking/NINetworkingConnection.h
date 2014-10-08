///
///  NINetworkingConnection.h
///
///  NIFramework
///
///  Created by Ondrej Rafaj on 22.3.10.
///
///  Copyright 2010 Home. All rights reserved.
///

#import <Foundation/Foundation.h>


@interface NINetworkingConnection : NSObject {

}

+ (BOOL)isWiFiConnectionAvailable;

+ (BOOL)isCellularConnectionAvailable;

+ (BOOL)isAnyConnectionAvailable;

+ (BOOL)isConnectionAvailable: (NSString*) hostName;

@end
