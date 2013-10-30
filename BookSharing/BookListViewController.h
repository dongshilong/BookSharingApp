//
//  BookListViewController.h
//  BookSharing
//
//  Created by GIGIGUN on 13/9/24.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BookListData.h"
#import "BookInfo.h"
#import "NSMutableArray+Queue.h"

extern BOOL GLOBAL_FORCE_SYNC;

@interface BookListViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate> {
    BOOL InitedInViewDidLoaded;
}

@property (weak, nonatomic) IBOutlet UISearchBar *SearchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;


@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) NSArray *SearchBookNameTableData;
@property (nonatomic, strong) NSArray *SearchBookAuthorTableData;
@property (nonatomic, strong) NSArray *SearchResultDisplayArray;

@property (nonatomic, strong) BookListData *BookList;

@property (nonatomic) NSIndexPath *LocalIndexPath;

- (IBAction)AddBtn:(id)sender;

@end
