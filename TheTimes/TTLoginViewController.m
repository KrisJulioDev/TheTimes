//
//  TTLoginViewController.m
//  TheTimes
//
//  Created by KrisMraz on 9/1/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import "TTLoginViewController.h" 
#import "BookShelfViewController.h"

@interface TTLoginViewController ()

@end

@implementation TTLoginViewController

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
    
    UIView *emailPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    UIView *passPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    
    self.tf_emailAddress.leftView = emailPaddingView;
    self.tf_password.leftView = passPaddingView;
    
    self.tf_emailAddress.leftViewMode = UITextFieldViewModeAlways;
    self.tf_password.leftViewMode = UITextFieldViewModeAlways;
    
}

- (IBAction) memberTrySignIn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    
}

@end
