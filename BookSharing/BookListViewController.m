//
//  BookListViewController.m
//  BookSharing
//
//  Created by GIGIGUN on 13/9/24.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "BookListViewController.h"
#import "DetailedViewController.h"
#import "SWRevealViewController.h"
#import "TableCell.h"

#define SYNC_THRESHOLD_SEC 300.0

BOOL GLOBAL_FORCE_SYNC = YES;


@interface BookListViewController ()

@end

@implementation BookListViewController
@synthesize tableView = _tableView;

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/


- (void)viewDidLoad
{
    [super viewDidLoad];
    InitedInViewDidLoaded = YES;
    
    // 1. Init models
    _BookList = [[BookListData alloc] init];
    _LocalIndexPath = [[NSIndexPath alloc] init];

    // 2. Init table data
    //_tableData = [[NSMutableArray alloc] initWithArray:[_BookList Books_CoreDataFetch]];
    _tableData = [[NSMutableArray alloc] initWithArray:[_BookList Books_CoreDataFetchNoDeletedData]];
//    [self.tableView reloadData];
    
    
    // 3. Setup slide bar
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
        // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    
    // 4. Setup UI activity
    self.navigationItem.title = @"Book List";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:9.0 green:80.0 blue:26.0 alpha:0.8]];
    //self.clearsSelectionOnViewWillAppear = YES;
    
    
    // Hide Search Bar at the beginning
    CGRect Bounds = _tableView.bounds;
    Bounds.origin.y = Bounds.origin.y + _SearchBar.bounds.size.height;
    _tableView.bounds = Bounds;
    [_tableView reloadData];

    // Google Analytics
    self.screenName = @"ListView";
    
    
    // [CASPER] : 2013/11/01 Setup Pull to refresh
    _PullToRefresh = [[UIRefreshControl alloc] init];
    [_PullToRefresh setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
    [_PullToRefresh addTarget:self action:@selector(SyncDataWithServer) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_PullToRefresh];
    [self SyncDataWithServer];

    
}




-(void) viewWillAppear:(BOOL)animated
{
    
    if (InitedInViewDidLoaded) {
        
        // Everything is ready in ViewDidLoaded
        InitedInViewDidLoaded = NO;
        
    } else {
        
        // View appeared without init
        // UI function should reloaded
        //_tableData = [[NSMutableArray alloc] initWithArray:[_BookList Books_CoreDataFetch]];
        LIST_VIEW_LOG(@"RELOAD DATA");

        _tableData = [[NSMutableArray alloc] initWithArray:[_BookList Books_CoreDataFetchNoDeletedData]];
        if (0 != [_tableData count]) {
            [_tableView reloadData];            
        }

        
    }
    
    [_tableView deselectRowAtIndexPath:_LocalIndexPath animated:NO];
    
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - UI behavior
// 2013.10.16 [CASPER] Fix front view behavior
//                     front view go back when touched.
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
}

-(void) ExecuteNotLoginViewWhenRefreshing:(BOOL) Refreshing
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIView *NotLoginView = [[UIView alloc] init];
    NotLoginView = [[[NSBundle mainBundle] loadNibNamed:@"BookListNotLoginAlert" owner:self options:nil] objectAtIndex:0];
    [NotLoginView setCenter:CGPointMake(screenBounds.size.width / 2, (screenBounds.size.height + NotLoginView.frame.size.height))];
    
    NotLoginView.layer.masksToBounds = YES;
    NotLoginView.layer.opaque = NO;
    NotLoginView.layer.cornerRadius = 4.0f;
    [_tableView addSubview:NotLoginView];
    
    NotLoginView.alpha = 0.2;
    [UIView animateWithDuration:2.0
                     animations:^{
                         
                         if (Refreshing) {
                             
                              NotLoginView.center = CGPointMake(screenBounds.size.width/2, screenBounds.size.height - NotLoginView.frame.size.height - 50);
                             
                         } else {
                              NotLoginView.center = CGPointMake(screenBounds.size.width/2, screenBounds.size.height - NotLoginView.frame.size.height - 20);
                         }
                         
                        
                         NotLoginView.alpha = 0.8;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:2.0
                                          animations:^{
                                              NotLoginView.center = CGPointMake(screenBounds.size.width/2, screenBounds.size.height + NotLoginView.frame.size.height);;
                                              NotLoginView.alpha = 0.2;
                                          }
                                          completion:^(BOOL finished){
                                              [NotLoginView removeFromSuperview];
                                              
                                          }];
                     }];}


#pragma mark - Get Data Sync Notification
-(void) DatabaseSyncNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:BOOKLIST_NOTIFY_ID
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification)
     {
         NSDictionary *dict = notification.userInfo;
         if ([[dict objectForKey:BOOKLIST_NOTIFY_KEY] isEqualToString:BOOKLIST_DATABASE_SYNC_START]) {
             
             LIST_VIEW_LOG(@"BOOKLIST_DATABASE_SYNC_START");
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

             
         } else if ([[dict objectForKey:BOOKLIST_NOTIFY_KEY] isEqualToString:BOOKLIST_DATABASE_SYNC_END]) {
             
             LIST_VIEW_LOG(@"BOOKLIST_DATABASE_SYNC_END - To ensure the table data is full filled");

             _tableData = [_BookList Books_CoreDataFetchNoDeletedData];
             [_tableView reloadData];

             
         } else if ([[dict objectForKey:BOOKLIST_NOTIFY_KEY] isEqualToString:BOOKLIST_DATABASE_SYNC_END_NO_MERGE]) {
             
             LIST_VIEW_LOG(@"BOOKLIST_DATABASE_SYNC_END_NO_MERGE");
             if (_PullToRefresh.refreshing){
                 [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:0.5];
             }
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             
         } else if ([[dict objectForKey:BOOKLIST_NOTIFY_KEY] isEqualToString:BOOKLIST_DATABASE_SYNC_ERROR]) {
             
             LIST_VIEW_LOG(@"BOOKLIST_DATABASE_SYNC_ERROR");
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         } else if ([[dict objectForKey:BOOKLIST_NOTIFY_KEY] isEqualToString:BOOKLIST_DATABASE_GET_IMAGE_COVER_END]) {
             
             LIST_VIEW_LOG(@"BOOKLIST_DATABASE_GET_IMAGE_COVER_END");
             
             if (_PullToRefresh.refreshing){
                 [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:0.5];
             }
             _tableData = [_BookList Books_CoreDataFetchNoDeletedData];
             [_tableView reloadData];
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        
         }
     }];
}


#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *sectionStr = [[NSString alloc] init];
    
    if ([self.searchDisplayController isActive]) {
        
        switch (section) {
            case 0:
                sectionStr = @"book name";
                break;
                
            case 1:
                sectionStr = @"book author";
                break;
                
            default:
                break;
        }
        
    } else {
        return nil;
    }
    return sectionStr;
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        return [_SearchResultDisplayArray count];
        
    } else {
        
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        return [[_SearchResultDisplayArray objectAtIndex:section] count];
        //return [_SearchBookNameTableData count];
        
    } else {
        
        return [_tableData count];
        
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        // Search list
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        NSManagedObject *book = [[_SearchResultDisplayArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [book valueForKey:@"bookName"]];
        cell.imageView.image = [UIImage imageWithData:[book valueForKey:@"bookCoverImage"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [book valueForKey:@"bookAuthor"]];
        
        return cell;
        
    } else {
        
        // Normal list
        static NSString *CellIdentifier = @"TableCell";
        
        TableCell *cell = (TableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        // 20131017 Casper : set selection highlight as none.
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSManagedObject *book = [self.tableData objectAtIndex:indexPath.row];
        cell.BookNameLab.text = [NSString stringWithFormat:@"%@", [book valueForKey:@"bookName"]];
        cell.BookAuthorLab.text = [NSString stringWithFormat:@"%@", [book valueForKey:@"bookAuthor"]];
        
        // 2013.11.06 [CASPER] Add Search Engine judgement
        if (SEARCH_ENGINE_BOOKS_TW == [_BookList WhereThisBookFromWithCoreData:book]) {
            
            cell.BookCoverImgSmall.hidden = YES;
            cell.BookCoverImg.hidden = NO;

            cell.BookCoverImg.image = [UIImage imageWithData:[book valueForKey:@"bookCoverImage"]];
            
        } else {
            
            cell.BookCoverImg.hidden = YES;
            cell.BookCoverImgSmall.hidden = NO;
            cell.BookCoverImgSmall.image = [UIImage imageWithData:[book valueForKey:BOOKS_CORE_DATA_KEY_BOOK_COVER_IMG]];

        }
        
        return cell;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 50;
    } else {
        return 100;
    }
    
}


#pragma mark - TableView delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _LocalIndexPath = indexPath;
    
    if (_PullToRefresh.refreshing){
        [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:0];
    }
    
    // 2013.10.16 [CASPER] Fix front view behavior
    //                     front view go back when touched.
    LIST_VIEW_LOG(@"    self.revealViewController.frontViewPosition  = %i", self.revealViewController.frontViewPosition );
    if (self.revealViewController.frontViewPosition == FrontViewPositionRight) {
        
        [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        
    } else {
        
        [self performSegueWithIdentifier:@"BookDetailedInfo" sender:nil];
        
    }
    
    return indexPath;
}



#pragma mark - SearchBar Method
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    // TODO: Modify the data display, deleted data should not be displayed
    _SearchBookNameTableData = [_BookList Books_CoreDataSearchWithBookName:searchText inDatabase:BOOK_LIST];
    _SearchBookAuthorTableData = [_BookList Books_CoreDataSearchWithBookAuthor:searchText inDatabase:BOOK_LIST];
    _SearchResultDisplayArray = [NSArray arrayWithObjects:
                                 _SearchBookNameTableData,
                                 _SearchBookAuthorTableData,
                                 nil];
    
    LIST_VIEW_LOG(@"Search result %i ！！！！～～～～", [_SearchBookNameTableData count]);
    LIST_VIEW_LOG(@"Search result %i ！！！！～～～～", [_SearchBookAuthorTableData count]);
    
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    
    return YES;
}




#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"BookDetailedInfo"])
    {
        DetailedViewController *destViewController = segue.destinationViewController;
        destViewController.FatherView = ListBookView;
        
        if ([self.searchDisplayController isActive]) {
            
            NSManagedObject *book = [[_SearchResultDisplayArray objectAtIndex:_LocalIndexPath.section] objectAtIndex:_LocalIndexPath.row];
            destViewController.book = book;

            
        } else {
            
            NSManagedObject *book = [_tableData objectAtIndex:_LocalIndexPath.row];
            destViewController.book = book;
            
        }
        
    }
}


#pragma mark - Button Event
- (void)stopRefresh
{
    [_PullToRefresh endRefreshing];
}


- (IBAction)AddBtn:(id)sender
{
    UIViewController *View = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchView"];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromLeft;
    
    [self.navigationController.view.layer
     addAnimation:transition forKey:kCATransition];
    
    [self.navigationController pushViewController:View animated:YES];

}


-(void) SyncDataWithServer
{

    if (_PullToRefresh.isRefreshing) {
        
        GLOBAL_FORCE_SYNC = YES;
        LIST_VIEW_LOG(@"is Refreshing");

    }

    if (GLOBAL_FORCE_SYNC) {
        if (FBSession.activeSession.isOpen) {
            
            LIST_VIEW_LOG(@"Sync executing");
            [self performSelector:@selector(DatabaseSyncNotification)];
            [_BookList  Books_GetServerDataAndMerge];
 
        } else {
            
            if (_PullToRefresh.refreshing){
                
                [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:0.3];
                sleep(0.5);
                [self ExecuteNotLoginViewWhenRefreshing:YES];
                
            } else {
                
                [self ExecuteNotLoginViewWhenRefreshing:NO];
                
            }
            
        }
        
        GLOBAL_FORCE_SYNC = NO;
        
    } else {
        
        // 2. Check current time and update time (in core data)
        // if diff is over then 5 min, then sync
        if (FBSession.activeSession.isOpen) {
        
            NSDate *CurrentTime = [NSDate date];
            NSDate *UpdateTime = [_BookList Books_GetTheLastSyncTime];
            
            if (UpdateTime != nil) {
                NSTimeInterval secondsBetween = [CurrentTime timeIntervalSinceDate:UpdateTime];
                
                if (secondsBetween >= SYNC_THRESHOLD_SEC) {
                    
                    LIST_VIEW_LOG(@"Update 5 min ago, execute update");
                    [self performSelector:@selector(DatabaseSyncNotification)];
                    [_BookList  Books_GetServerDataAndMerge];
                
                } else {
                    
                    LIST_VIEW_LOG(@"JUST SYNC - NO NEED to Sync");
                
                }
            
            } else {
                
                LIST_VIEW_LOG(@"Never been sync before, execute sync");
                
                [self performSelector:@selector(DatabaseSyncNotification)];
                [_BookList  Books_GetServerDataAndMerge];


            }
            
        } else {
            
            [self ExecuteNotLoginViewWhenRefreshing:NO];
        
        }
    }

}

@end
