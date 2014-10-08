//
//  TTEditionManager.h
//  TheTimes
//
//  Created by KrisMraz on 9/1/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookShelfViewController.h"
#import "Edition.h"


@interface TTEditionManager : NSObject

@property (strong, nonatomic) NSMutableArray *LatestEditions;
@property (strong, nonatomic) BookShelfViewController *bookShelfVC;
@property (nonatomic, retain) NSMutableArray *downloadedEditions;

+(instancetype) sharedInstance;
- (void) updateEditions;


- (BOOL) downloadedEdition:(Edition *)edition;
- (Edition *) getDownloadedEdition:(Edition *)edition;
- (void) completeUpdateEditions:(NSMutableArray *)newEditions;
- (void) snapshot;

@end
