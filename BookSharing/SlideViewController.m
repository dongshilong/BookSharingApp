//
//  SlideViewController.m
//  BookSharing
//
//  Created by GIGIGUN on 13/9/24.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "SlideViewController.h"

@interface SlideViewController ()

@end

@implementation SlideViewController

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
    [FBLoginView class];
    [FBProfilePictureView class];
    
    

    
    if(!_LoginView){
        _LoginView = [[FBLoginView alloc] initWithPublishPermissions:nil defaultAudience:FBSessionDefaultAudienceFriends];
    }
    _LoginView.frame = self.LoginView.bounds; //whatever you want
    NSLog(@"%f - %f", _LoginView.center.x, _LoginView.center.y);
    _LoginView.delegate = self;
    
    [self.view addSubview:_LoginView];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == IPHONE_SCREEN_4_INCH_HEIGHT) {
        
        [self.LoginView setCenter: CGPointMake(_LoginView.center.x, FB_LOGIN_VIEW_LOCATION_4_INCH_Y)];
        
    } else {
        
        [self.LoginView setCenter: CGPointMake(_LoginView.center.x, FB_LOGIN_VIEW_LOCATION_3_5_INCH_Y)];
        
    }
    
    if (FBSession.activeSession.isOpen) {
        
        [self populateUserDetails];
        self.userProfileImage.hidden = NO;
        _FbUserNameLab.hidden = NO;
        _LoginView.hidden = YES;
        
    } else {
        
        [self populateUserDetails];
        self.userProfileImage.hidden = YES;
        _FbUserNameLab.hidden = YES;
        _LoginView.hidden = NO;
        
    }
    
    _menuItems1 = @[@"HOT"];
    _menuItems2 = @[@"BookList", @"SearchBook", @"Setting"];
    _sectionItem = [[NSArray alloc] initWithObjects:_menuItems1, _menuItems2, nil];
    [_tableView setScrollEnabled:NO];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [_tableView deselectRowAtIndexPath:_localSelection animated:NO];
    
    if (FBSession.activeSession.isOpen) {
        
        [self populateUserDetails];
        self.userProfileImage.hidden = NO;
        _FbUserNameLab.hidden = NO;
        _LoginView.hidden = YES;
        
    } else {
        
        [self populateUserDetails];
        self.userProfileImage.hidden = YES;
        _FbUserNameLab.hidden = YES;
        _LoginView.hidden = NO;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_sectionItem count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[_sectionItem objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [[_sectionItem objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = nil;
            break;
        case 1:
            sectionName = @"MY BOOKs";
            break;
            // ...
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    _localSelection = indexPath;
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    destViewController.title = [[[_sectionItem objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] capitalizedString];
    
    
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
        
    }
    
}


#pragma mark - Facebook SDK
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    BOOKS_FB_LOG(@" loginViewShowingLoggedInUser");
    [self SetFbUIBehavior];
}


- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    BOOKS_FB_LOG(@" loginViewShowingLoggedOutUser");
    [self SetFbUIBehavior];
}

- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error{
    NSString *alertMessage, *alertTitle;
    
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
        BOOKS_FB_ERROR_LOG(@"user cancelled login %i", 0);
    } else {
        // For simplicity, this sample treats other errors blindly, but you should
        // refer to https://developers.facebook.com/docs/technical-guides/iossdk/errors/ for more information.
        alertTitle  = @"Unknown Error";
        alertMessage = @"Error. Please try again later.";
        BOOKS_FB_ERROR_LOG(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)populateUserDetails {
    
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 _FbUserNameLab.text = user.name;
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

-(void) SetFbUIBehavior
{
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
        self.userProfileImage.hidden = NO;
        _FbUserNameLab.hidden = NO;
        _LoginView.hidden = YES;
    } else {
        [self populateUserDetails];
        self.userProfileImage.hidden = YES;
        _FbUserNameLab.hidden = YES;
        _LoginView.hidden = NO;
    }
}


@end
