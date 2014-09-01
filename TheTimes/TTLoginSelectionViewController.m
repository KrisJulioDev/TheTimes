//
//  TTLoginSelectionViewController.m
//  TheTimes
//
//  Created by KrisMraz on 9/1/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import "TTLoginSelectionViewController.h"
#import "TTLoginViewController.h"

@interface TTLoginSelectionViewController ()

@end

@implementation TTLoginSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)loginByMember:(id)sender {
    
    UIViewController *loginViewController = [[TTLoginViewController alloc] init];
    [self.navigationController pushViewController:loginViewController animated:YES]; 
}

@end
