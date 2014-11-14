//
//  SectionPopUpVC.m
//  TheTimes
//
//  Created by KrisMraz on 10/17/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import "SectionPopUpVC.h"
#import "SemiModalAnimatedTransition.h"
#import "Constants.h"

@interface SectionPopUpVC ()

@property (nonatomic, assign) BOOL presenting;
@property (nonatomic, retain) SemiModalAnimatedTransition *semiModalAnimatedTransition;
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

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    self.presenting = YES;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.presenting = NO;
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView = [transitionContext respondsToSelector:@selector(viewForKey:)] ? [transitionContext viewForKey:UITransitionContextFromViewKey] : fromViewController.view;
    UIView *toView = [transitionContext respondsToSelector:@selector(viewForKey:)] ? [transitionContext viewForKey:UITransitionContextToViewKey] : toViewController.view;
    
    
    if (self.presenting) {
        [transitionContext.containerView addSubview:toView];
        [transitionContext.containerView addSubview:fromView];
        
        [transitionContext.containerView bringSubviewToFront:toView];
        
        [toViewController beginAppearanceTransition:YES animated:YES];
        [fromViewController beginAppearanceTransition:NO animated:YES];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:0 animations:^{
            
            if (IOS_VERSION_LOWER_THAN_8 && !IS_PORTRAIT) {
                [toView setFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH)];
            } else
                [toView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            
        } completion:^(BOOL finished) {
            [toViewController endAppearanceTransition];
            [fromViewController endAppearanceTransition];
            [transitionContext completeTransition:finished];
        }];
        
    } else {
        [transitionContext.containerView addSubview:fromView];
        [transitionContext.containerView addSubview:toView];
        
        [toViewController beginAppearanceTransition:YES animated:YES];
        [fromViewController beginAppearanceTransition:NO animated:YES];
        CGRect frame = toView.frame;
        frame.origin.x = -frame.size.width;
        toView.frame = frame;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:0 animations:^{
            CGRect frame = toView.frame;
            frame.origin.x = 0;
            toView.frame = frame;
        } completion:^(BOOL finished) {
            [toViewController endAppearanceTransition];
            [fromViewController endAppearanceTransition];
            [transitionContext completeTransition:finished];
        }];
    }

}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0;
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
     [self closeSectionPopup:self];
}

- (IBAction)closeSectionPopup:(id)sender {

    if(self.presentingViewController){
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
