//
//  SlideViewController.h
//  BookSharing
//
//  Created by GIGIGUN on 13/9/24.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
@interface SlideViewController : UIViewController <FBLoginViewDelegate, FBUserSettingsDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSIndexPath   *localSelection;
@property (nonatomic, strong) NSArray       *menuItems1;
@property (nonatomic, strong) NSArray       *menuItems2;
@property (nonatomic, strong) NSArray       *sectionItem;

@property (weak, nonatomic) IBOutlet UILabel *FbUserNameLab;
@property (strong, nonatomic) IBOutlet FBLoginView *LoginView;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;

@end
