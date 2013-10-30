//
//  DetailedViewController.h
//  BookSharing
//
//  Created by GIGIGUN on 13/9/25.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "BooksHtml.h"
#import "BookListData.h"
#import "BookInfo.h"
#import "BookInfoHeader.h"
#import "DetailedScroller.h"
#import "Searching.h"
#import "EditBookInfoViewController.h"

@interface DetailedViewController : GAITrackedViewController <NSURLConnectionDelegate> {
    NSURLConnection     *BookCoverConn;
    NSMutableData       *_responseData;

}

typedef enum {
    None = 0x00,
    ListBookView,
    SearchBookView,
} FatherViewController;
@property FatherViewController FatherView;

@property (weak, nonatomic) IBOutlet UIScrollView *Scroller;
@property (weak, nonatomic)     BookInfoHeader      *BookInfoHeaderView;
@property (strong, nonatomic)   DetailedScroller    *BookInfoDetailedView;
@property (weak, nonatomic)     Searching           *SearchingView;


@property (strong, atomic)      NSString        *NotificationState_OLD;
@property (strong, nonatomic)   BookListData    *BookDataBase;
@property (strong, nonatomic)   BooksHtml       *BookInfoQuery;
@property (strong, nonatomic)   BookInfo        *BookInfoObj;
@property (strong, nonatomic)   NSManagedObject *book;

@property (strong, nonatomic)     EditBookInfoViewController  *editBookViewContoller;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *EditBtn;
- (IBAction)EditBtn:(id)sender;

@end
