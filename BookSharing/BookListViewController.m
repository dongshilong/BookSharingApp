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
    //self.clearsSelectionOnViewWillAppear = YES;

    // Google Analytics
    self.screenName = @"ListView";

        // Hide Search Bar at the beginning
    CGRect Bounds = _tableView.bounds;
    Bounds.origin.y = Bounds.origin.y + _SearchBar.bounds.size.height;
    _tableView.bounds = Bounds;
    [_tableView reloadData];

    
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
        _tableData = [[NSMutableArray alloc] initWithArray:[_BookList Books_CoreDataFetchNoDeletedData]];
        [_tableView reloadData];
        
    }
    [_tableView deselectRowAtIndexPath:_LocalIndexPath animated:NO];
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// 2013.10.16 [CASPER] Fix front view behavior
//                     front view go back when touched.
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
}

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
             
             VIEW_LOG(@"BOOKLIST_DATABASE_SYNC_START");
             
         } else if ([[dict objectForKey:BOOKLIST_NOTIFY_KEY] isEqualToString:BOOKLIST_DATABASE_SYNC_END]) {
             
             VIEW_LOG(@"BOOKLIST_DATABASE_SYNC_END - To ensure the table data is full filled");
             //_tableData = [_BookList Books_CoreDataFetch];
             _tableData = [_BookList Books_CoreDataFetchNoDeletedData];
             [_tableView reloadData];
             
         } else if ([[dict objectForKey:BOOKLIST_NOTIFY_KEY] isEqualToString:BOOKLIST_DATABASE_SYNC_ERROR]) {
             
             VIEW_LOG(@"BOOKLIST_DATABASE_SYNC_ERROR");
         
         } else if ([[dict objectForKey:BOOKLIST_NOTIFY_KEY] isEqualToString:BOOKLIST_DATABASE_GET_IMAGE_COVER_END]) {
             
             VIEW_LOG(@"BOOKLIST_DATABASE_GET_IMAGE_COVER_END");
             //_tableData = [_BookList Books_CoreDataFetch];
             _tableData = [_BookList Books_CoreDataFetchNoDeletedData];
             [_tableView reloadData];
        
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
        cell.BookCoverImg.image = [UIImage imageWithData:[book valueForKey:@"bookCoverImage"]];
        
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
    
    
    // 2013.10.16 [CASPER] Fix front view behavior
    //                     front view go back when touched.
    VIEW_LOG(@"    self.revealViewController.frontViewPosition  = %i", self.revealViewController.frontViewPosition );
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
    _SearchBookNameTableData = [_BookList Books_CoreDataSearchWithBookName:searchText];
    _SearchBookAuthorTableData = [_BookList Books_CoreDataSearchWithBookAuthor:searchText];
    _SearchResultDisplayArray = [NSArray arrayWithObjects:
                                 _SearchBookNameTableData,
                                 _SearchBookAuthorTableData,
                                 nil];
    
    VIEW_LOG(@"Search result %i ！！！！～～～～", [_SearchBookNameTableData count]);
    VIEW_LOG(@"Search result %i ！！！！～～～～", [_SearchBookAuthorTableData count]);
    
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
    // 1. Check Force Update
    if (GLOBAL_FORCE_SYNC) {
        
        [self performSelector:@selector(DatabaseSyncNotification)];
        [_BookList  Books_GetServerDataAndMerge];
        GLOBAL_FORCE_SYNC = NO;
        
    } else {

        // 2. Check current time and update time (in core data)
        // if diff is over then 5 min, then sync
        NSDate *CurrentTime = [NSDate date];
        NSDate *UpdateTime = [_BookList Books_GetTheLastSyncTime];
        NSTimeInterval secondsBetween = [CurrentTime timeIntervalSinceDate:UpdateTime];
        
        if (secondsBetween >= SYNC_THRESHOLD_SEC) {
            
            VIEW_LOG(@"Update 5 min ago, execute update");
            [self performSelector:@selector(DatabaseSyncNotification)];
            [_BookList  Books_GetServerDataAndMerge];
            
        }

    }
}

@end
