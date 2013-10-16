//
//  MainViewController.m
//  BookSharing
//
//  Created by GIGIGUN on 13/9/24.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "MainViewController.h"
#import "SWRevealViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

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
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// 2013.10.16 [CASPER] Fix front view behavior
//                     front view go back when touched.
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    VIEW_LOG(@"    self.revealViewController.frontViewPosition  = %i", self.revealViewController.frontViewPosition );
    if (self.revealViewController.frontViewPosition == FrontViewPositionRight) {
        [self.revealViewController performSelector:@selector(revealToggle:)];
    }
}

@end
