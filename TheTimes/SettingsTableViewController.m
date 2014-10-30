//
//  SettingsTableViewController.m
//  TheTimes
//
//  Created by KrisMraz on 10/15/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "TheTimesAppDelegate.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    settingsItem = [NSMutableArray new];
    [settingsItem addObject:@"HELP"];
    [settingsItem addObject:@"FAQ"];
    [settingsItem addObject:@"LEGALS"];
    [settingsItem addObject:@"CONTACT"];
    [settingsItem addObject:@"CREDITS"];
    
    settingsURL = [NSMutableArray new];
    [settingsURL addObject:@"http://help.thetimes.co.uk/"];
    [settingsURL addObject:@"https://login.thetimes.co.uk/links/faq"];
    [settingsURL addObject:@"https://login.thetimes.co.uk/links/terms"];
    [settingsURL addObject:@"https://login.thetimes.co.uk/links/contact"];
    [settingsURL addObject:@"https://login.thetimes.co.uk/links/contact"];
    
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
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TheTimesAppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    [appdelegate.bookShelfVC closeSettingPopUP];
    [appdelegate.bookShelfVC closeSettingWebView];
    
    [appdelegate.bookShelfVC openSettingsWebView:[settingsURL objectAtIndex:indexPath.row ]];
}

@end
