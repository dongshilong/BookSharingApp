//
//  AppDelegate.h
//  ShareBook
//
//  Created by GIGIGUN on 13/9/5.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SettingViewViewController.h"
#import "GAI.h"

@class SettingViewViewController;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (readonly, strong, nonatomic) NSManagedObjectContext          *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel            *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator    *persistentStoreCoordinator;

// Google analytics
@property(nonatomic, strong) id<GAITracker> tracker;

@property (strong, nonatomic) FBSession *session;
@property (strong, nonatomic) SettingViewViewController *loginViewController;


@end
