//
//  SeachViewController.h
//  BookSharing
//
//  Created by GIGIGUN on 13/9/26.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "BooksHtml.h"
#import "Searching.h"
#import "ZBarSDK.h"


@interface SeachViewController : GAITrackedViewController
                    <UISearchBarDelegate, UISearchDisplayDelegate,
                    UITableViewDataSource, UITableViewDelegate,
                    ZBarReaderDelegate> {
    BOOL ShowSearchResult;
    CGPoint BarcodeDefaultLocation;
}

@property (weak, nonatomic)     IBOutlet UISearchBar        *SearchBar;
@property (strong, nonatomic)   IBOutlet UIBarButtonItem    *sidebarButton;
@property (strong, nonatomic)   IBOutlet UIBarButtonItem    *bookListButton;
@property (weak, nonatomic)     IBOutlet UIButton           *BarCodeReaderBtn;
@property (weak, nonatomic)     IBOutlet UITableView        *TableView;

@property (strong, atomic)      NSString        *NotificationState_OLD;
@property (strong, atomic)      NSMutableArray  *TableDataSec0;
@property (strong, atomic)      NSMutableArray  *SearchBookInfoObjArray;
@property (strong, atomic)      NSMutableArray  *TableCoverImageArray;
@property (strong, nonatomic)   NSIndexPath     *LocalIndexPath;

@property (weak, nonatomic)     Searching   *SearchingView;
@property (strong, atomic)      BooksHtml   *BookSearch;
@property (strong, nonatomic)   BookInfo    *BookInfoObj;



- (IBAction)BookListBtn:(id)sender;
- (IBAction)BarcodeReaderBtn:(id)sender;


@end
