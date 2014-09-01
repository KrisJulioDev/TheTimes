//
//  TTLoginViewController.h
//  TheTimes
//
//  Created by KrisMraz on 9/1/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTLoginViewController : UIViewController

#pragma mark XIB properties

@property (weak, nonatomic) IBOutlet UITextField *tf_emailAddress;
@property (weak, nonatomic) IBOutlet UITextField *tf_password;
@property (weak, nonatomic) IBOutlet UIButton *btn_forgotPass;
@property (weak, nonatomic) IBOutlet UIButton *btn_signIn;

@end
