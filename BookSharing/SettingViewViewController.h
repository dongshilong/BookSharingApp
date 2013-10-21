//
//  SettingViewViewController.h
//  BookSharing
//
//  Created by GIGIGUN on 13/10/21.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface SettingViewViewController : UIViewController <FBLoginViewDelegate, FBUserSettingsDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (unsafe_unretained, nonatomic) IBOutlet FBLoginView *FBLoginView;

@property (weak, nonatomic) IBOutlet UILabel *ProfileName;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;

@end
