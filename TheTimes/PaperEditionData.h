//
//  PaperEditionData.h
//  TheTimes
//
//  Created by KrisMraz on 10/8/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface PaperEditionData : NSManagedObject
@property (nonatomic, retain) NSNumber * shouldResumeDownload;
@property (nonatomic, retain) NSString * folderPath;
@property (nonatomic, retain) NSString * paperURL;
@property (nonatomic, retain) NSDate * paperDate;
@end
