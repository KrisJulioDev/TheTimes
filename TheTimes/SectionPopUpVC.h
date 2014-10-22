//
//  SectionPopUpVC.h
//  TheTimes
//
//  Created by KrisMraz on 10/17/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Edition.h"
#import "RDPDFViewController.h"

@interface SectionPopUpVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UIView         *popUpView;
    IBOutlet UITableView    *popUpTable;
    
}
@property (strong, nonatomic) Edition* edition;
@property (strong, nonatomic) RDPDFViewController     *rdDelegate;

@end
