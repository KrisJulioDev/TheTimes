//
//  SettingsTableViewController.m
//  TheTimes
//
//  Created by KrisMraz on 10/15/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "TheTimesAppDelegate.h"
#import "SubscriptionHandler.h"
#import "TrackingUtil.h"

@interface SettingsTableViewController () <UIAlertViewDelegate>
{
    TheTimesAppDelegate *appdelegate;
}
@end

@implementation SettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.layer.cornerRadius = 15;
    self.tableView.layer.borderWidth = 5;
    
    settingsItem = [NSMutableArray new];
    [settingsItem addObject:@"HELP"];
    [settingsItem addObject:@"FAQ"];
    [settingsItem addObject:@"LEGALS"];
    [settingsItem addObject:@"CONTACT"];
    //[settingsItem addObject:@"CREDITS"];
    
    appdelegate = [[UIApplication sharedApplication] delegate];
    
    settingsURL = [NSMutableArray new];
    [settingsURL addObject:appdelegate.config.helpURL];
    [settingsURL addObject:appdelegate.config.faqURL];
    [settingsURL addObject:appdelegate.config.termsURL];
    [settingsURL addObject:appdelegate.config.contactURL];
    //[settingsURL addObject:@"https://login.thetimes.co.uk/links/contact"];
    
    appdelegate = [UIApplication sharedApplication].delegate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [settingsItem count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusableID = @"SettingItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableID];
    }
    
    cell.textLabel.text = [settingsItem objectAtIndex:indexPath.row];
    
    [cell setBackgroundColor:[UIColor darkGrayColor]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:13]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [appdelegate.bookShelfVC closeSettingPopUP];
    [appdelegate.bookShelfVC closeSettingWebView];
    [appdelegate.bookShelfVC openSettingsWebView:[settingsURL objectAtIndex:indexPath.row ]];
    
    [self trackSettingActions:indexPath.row];
}

- (IBAction)logoutUser:(id)sender {
    
    UIAlertView *logoutAlert = [[UIAlertView alloc] initWithTitle:@"Logout" message:NSLocalizedString(@"LOGOUT_ALERT", nil) delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok"   , nil];
    
    [logoutAlert show];
}

/**
 *  Tealium tracking
 *
 *  @param actionID event_navigation_name depends on chosen action
 */
- (void) trackSettingActions:(int)actionID
{
    NSMutableDictionary *trackingDict = [[NSMutableDictionary alloc] init];
    [trackingDict setObject:@"navigation"                           forKey:@"event_navigation_action"];
    [trackingDict setObject:@"click"                                forKey:@"event_navigation_browsing_method"];
    [trackingDict setObject:[settingsItem objectAtIndex:actionID]   forKey:@"event_navigation_name"];
    
    [TrackingUtil trackEvent:@"access option:sign in" fromView:self.view eventName:@"access option:sign in" eventAction:@"navigation" eventMethod:@"click" eventRegistrationAction:nil customerId:nil customerType:@"guest"];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        [appdelegate.bookShelfVC closeSettingPopUP];
        [appdelegate.bookShelfVC closeSettingWebView];
        
        [SubscriptionHandler storeUserDetails:@"" password:@""];
        [appdelegate.bookShelfVC showLoginScreen];
        
        NSMutableDictionary *trackingDict = [[NSMutableDictionary alloc] init];
        [trackingDict setObject:@"navigation"                           forKey:@"event_navigation_action"];
        [trackingDict setObject:@"click"                                forKey:@"event_navigation_browsing_method"];
        [trackingDict setObject:@"logout"                               forKey:@"event_navigation_name"];
        
        
        [TrackingUtil trackEvent:@"access option:sign in" fromView:self.view eventName:@"access option:sign in" eventAction:@"navigation" eventMethod:@"click" eventRegistrationAction:nil customerId:nil customerType:@"guest"];
    }
    
}

@end
