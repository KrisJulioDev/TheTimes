//
//  SPUnzipper.h
//  Jigsaw
//
//  Created by SAMI EDDAIKRA on 5/5/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

//#import <Cocoa/Cocoa.h>

@interface SPUnzipper : NSObject {
	
	
}


+ (SPUnzipper*) mySPUnzipper;

- (id) init;
- (BOOL) unzipFile:(NSString*)fileFullath inDirectory:(NSString*)directoryPath;


@end
