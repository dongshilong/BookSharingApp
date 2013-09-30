//
//  DetailedViewController.h
//  BookSharing
//
//  Created by GIGIGUN on 13/9/25.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BooksHtml.h"
#import "BookInfo.h"
#import "BookInfoHeader.h"
#import "DetailedScroller.h"
#import "Searching.h"

@interface DetailedViewController : UIViewController

typedef enum {
    ListBookView = 0x00,
    SearchBookView,
} FatherViewController;
@property FatherViewController FatherView;

@property (weak, nonatomic) IBOutlet UIScrollView *Scroller;
@property (weak, nonatomic)     BookInfoHeader      *BookInfoHeaderView;
@property (strong, nonatomic)   DetailedScroller    *BookInfoDetailedView;
@property (weak, nonatomic)     Searching           *SearchingView;

@property (strong, atomic)      NSString        *NotificationState_OLD;
@property (strong, nonatomic)   BooksHtml       *BookInfoQuery;
@property (strong, nonatomic)   BookInfo        *BookInfoObj;
@end
