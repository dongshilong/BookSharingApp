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



#define UI_BARCODEBTN_DEFAULT_LOC_CENTER_4_INCH         473.0
#define UI_BARCODEBTN_MOVE_LOC_CENTER_4_INCH            253.0
#define UI_BARCODEBTN_DEFAULT_LOC_CENTER_3_5_INCH       373.0
#define UI_BARCODEBTN_MOVE_LOC_CENTER_3_5_INCH          203.0


@interface SeachViewController : GAITrackedViewController
                    <UISearchBarDelegate, UISearchDisplayDelegate,
                    UITableViewDataSource, UITableViewDelegate,
                    ZBarReaderDelegate> {
    BOOL ShowSearchResult;
                        
}

@property SearchEngine CurrentSearchEngine;

@property (weak, nonatomic)     IBOutlet UISearchBar        *SearchBar;
@property (strong, nonatomic)   IBOutlet UIBarButtonItem    *sidebarButton;
@property (strong, nonatomic)   IBOutlet UIBarButtonItem    *bookListButton;
@property (strong, nonatomic)   IBOutlet UIButton           *BarCodeReaderBtn;
@property (weak, nonatomic)     IBOutlet UITableView        *TableView;

@property (strong, atomic)      NSString        *NotificationState_OLD;
@property (strong, atomic)      NSMutableArray  *TableDataSec0;
@property (strong, atomic)      NSMutableArray  *SearchBookInfoObjArray;
@property (strong, atomic)      NSMutableArray  *TableCoverImageArray;
@property (strong, nonatomic)   NSIndexPath     *LocalIndexPath;
@property (nonatomic)           CGPoint BarcodeDefaultLocation;
@property (nonatomic)           CGPoint BarcodeMoveLocation;


@property (weak, nonatomic)     Searching   *SearchingView;
@property (strong, atomic)      BooksHtml   *BookSearch;
@property (strong, nonatomic)   BookInfo    *BookInfoObj;

@property (strong, nonatomic)   ZBarReaderViewController *reader;

- (IBAction)BookListBtn:(id)sender;
//- (IBAction)BarcodeReaderBtn:(id)sender;

@end
