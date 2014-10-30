//
//  SectionPopUpVC.m
//  TheTimes
//
//  Created by KrisMraz on 10/17/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import "SectionPopUpVC.h"

@interface SectionPopUpVC ()

@end

@implementation SectionPopUpVC

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
    
    popUpView.layer.cornerRadius = 10;
    popUpView.layer.borderWidth = 5;
    popUpView.layer.borderColor = [UIColor whiteColor].CGColor;
}

#pragma mark TABLEVIEW DELEGATE METHOD
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _edition.sections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"sectionCell";
    
    UITableViewCell *cell = nil;
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setBackgroundColor:[UIColor blackColor]];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
    }
    
    UIImageView *stLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"st"]];
    [stLogo setFrame:CGRectMake(5, 50 - 30 , 59, 59 )];
    [cell.contentView addSubview:stLogo];
    
    EditionSection *section = [_edition.sections objectAtIndex:indexPath.row];
    
    /*CGRect textLabelFrame = cell.textLabel.frame;
    float xOffset = 15;
    
    textLabelFrame.origin.x += xOffset;
    [cell.textLabel setFrame:textLabelFrame];*/
    
    [cell.textLabel setText:section.name];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:25]];
    [cell setIndentationLevel:8];
    
    [cell setBackgroundColor:[UIColor blackColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    
    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditionSection *section = [_edition.sections objectAtIndex:indexPath.row];
    [_rdDelegate PDFVGotoSection:section.pageNumber - 1];
    
    [self closeSectionPopup:self];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
     [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closeSectionPopup:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
} 

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
