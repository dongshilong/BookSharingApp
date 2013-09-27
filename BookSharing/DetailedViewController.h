//
//  DetailedViewController.h
//  BookSharing
//
//  Created by GIGIGUN on 13/9/25.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailedViewController : UIViewController

typedef enum {
    ListBookView = 0x00,
    SearchBookView,
} FatherViewController;

@property FatherViewController FatherView;

@end
