//
//  SettingViewViewController.m
//  BookSharing
//
//  Created by GIGIGUN on 13/10/21.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "SettingViewViewController.h"
#import "SWRevealViewController.h"

@interface SettingViewViewController ()

@end

@implementation SettingViewViewController

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

    // Setup UI activity
    //self.navigationItem.title = @"Setting";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    // Set the gesture
    
    
    UIColor *BarColor = [UIColor colorWithRed:(9/255.0) green:(80/255.0) blue:(26/255.0) alpha:1.0];
    self.navigationController.navigationBar.barTintColor = BarColor;
    //self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
    
    // this will appear as the title in the navigation bar
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor lightGrayColor]; // change this color
    self.navigationItem.titleView = label;
    label.text = @"Setting";
    [label sizeToFit];
    
    

    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [FBProfilePictureView class];
    
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
        self.userProfileImage.hidden = NO;
    } else {
        self.userProfileImage.hidden = YES;
        self.ProfileName.hidden = YES;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Facebook
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    // if you become logged in, no longer flag to skip log in
    //self.shouldSkipLogIn = NO;
    //[self transitionToMainViewController];
    NSLog(@"CASPER TEST 2");

}


- (void)updateView {
    // get the app delegate, so that we can reference the session property
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
        self.userProfileImage.hidden = NO;
    } else {
        self.userProfileImage.hidden = YES;
    }
}


- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error{
    NSString *alertMessage, *alertTitle;
    NSLog(@"CASPER TEST ");
    // Facebook SDK * error handling *
    // Error handling is an important part of providing a good user experience.
    // Since this sample uses the FBLoginView, this delegate will respond to
    // login failures, or other failures that have closed the session (such
    // as a token becoming invalid). Please see the [- postOpenGraphAction:]
    // and [- requestPermissionAndPost] on `SCViewController` for further
    // error handling on other operations.
    
    if (error.fberrorShouldNotifyUser) {
        // If the SDK has a message for the user, surface it. This conveniently
        // handles cases like password change or iOS6 app slider state.
        alertTitle = @"Something Went Wrong";
        alertMessage = error.fberrorUserMessage;
    } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        // It is important to handle session closures as mentioned. You can inspect
        // the error for more context but this sample generically notifies the user.
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        // The user has cancelled a login. You can inspect the error
        // for more context. For this sample, we will simply ignore it.
        NSLog(@"user cancelled login");
    } else {
        // For simplicity, this sample treats other errors blindly, but you should
        // refer to https://developers.facebook.com/docs/technical-guides/iossdk/errors/ for more information.
        alertTitle  = @"Unknown Error";
        alertMessage = @"Error. Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    // Facebook SDK * login flow *
    // It is important to always handle session closure because it can happen
    // externally; for example, if the current session's access token becomes
    // invalid. For this sample, we simply pop back to the landing page.
    //AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //if (appDelegate.isNavigating) {
    // The delay is for the edge case where a session is immediately closed after
    // logging in and our navigation controller is still animating a push.
    [self performSelector:@selector(logOut) withObject:nil afterDelay:.5];
    //} else {
      //[self logOut];
    //}
}

- (void)logOut {
    // on log out we reset the main view controller
    //AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //[appDelegate resetMainViewController];
    //[self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)populateUserDetails {
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 _ProfileName.text = user.name;
                 self.userProfileImage.profileID = [user objectForKey:@"id"];
                 
             }
         }];
        
        /*
        FBRequest* friendsRequest = [FBRequest requestForMyFriends];
        [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                      NSDictionary* result,
                                                      NSError *error) {
            NSArray* friends = [result objectForKey:@"data"];
            NSLog(@"Found: %i friends", friends.count);
            for (NSDictionary<FBGraphUser>* friend in friends) {
                NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
            }
        }];
         */
    } else {
    
    }
}


@end
