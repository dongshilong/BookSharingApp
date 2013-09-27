//
//  SeachViewController.m
//  BookSharing
//
//  Created by GIGIGUN on 13/9/26.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "SeachViewController.h"
@interface SeachViewController ()

@end

@implementation SeachViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Test
    _TableDataSec0 = [NSMutableArray arrayWithObjects:@"Click to clear search results", nil];
    // Test ==
    
    // 1. Init UI
    _SearchBar.searchBarStyle = UISearchBarStyleProminent;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"Search Book";
    [_TableView setHidden:YES];
    
    // 2. Setup Slide Bar function
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
        // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // 3. Init Flags
    ShowSearchResult = NO;

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_SearchBar resignFirstResponder];
    [self RemoveLoadingView];
}

#pragma mark - UI activities
-(void) ShowLoadingView
{
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"Searching" owner:self options:nil];
    _SearchingView = [subviewArray objectAtIndex:0];
    _SearchingView.frame = CGRectMake(80, 280, _SearchingView.frame.size.width, _SearchingView.frame.size.height);
    [_SearchingView.LoadingIcon startAnimating];
    
    [self.view addSubview:_SearchingView];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

}


-(void) RemoveLoadingView
{
    if (_SearchingView != nil) {
        [_SearchingView removeFromSuperview];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    // To remove keyboard when touch on the white area
    
    //UITouch *touch = [touches anyObject];
    //CGPoint currentPosition = [touch locationInView:self.view];
    
    [_SearchBar resignFirstResponder];

}

#pragma mark - Search Keyword
- (void)SearchBookWebTaskWithKeyWord:(NSString *) SearchStr
{
    
    VIEW_LOG(@"SearchBookWebTask");
    _BookSearch = [[BooksHtml alloc] init];
    
    if (ShowSearchResult == YES) {
        ShowSearchResult = NO;
    }
    
    // Test
    if (([SearchStr length] == 0) || (SearchStr == nil)) {
        //[_SearchBook Books_FireQueryWithKeyWords:@"ios app"];
        [_BookSearch Books_FireQueryWithKeyWords:@"9789866272516"];
        
    } else {
        
        VIEW_LOG(@"search text = %@", SearchStr);
        [_BookSearch Books_FireQueryWithKeyWords:SearchStr];
        
    }
    
    // TODO: Break here if no one key in search text.
    [self performSelector:@selector(CheckNotify)];
    
    // Enable loading icon on the status bar
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}


#pragma mark - Search Book Notification
-(void) CheckNotify
{
    // Regist BOOK_INDO_NOTIFY_ID Notify center
    
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:BOOK_INFO_NOTIFY_ID
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification)
     {
         
         NSDictionary *dict = notification.userInfo;
         VIEW_LOG(@"GET Notified %@", [dict objectForKey:BOOK_SEARCH_NOTIFICATION_KEY]);
         
         if (([[dict objectForKey:BOOK_SEARCH_NOTIFICATION_KEY] isEqualToString:BOOK_SEARCH_RESULT_TABLE_DONE])){
             
             // Extract Book Name | Book Author | Book Info URL Array
             //_BookInfoObj = [[BookInfo alloc] init];
             _SearchBookInfoObjArray = [[NSMutableArray alloc] init];
             
             NSArray *BookNameArray = [_BookSearch Books_ExtractToBookNameArrayWithDictionary:_BookSearch.BookSearchDic];
             
             
             NSUInteger NumOfBooks = [BookNameArray count];
             VIEW_LOG(@" - %lu - Book(s) in the dictionary", (unsigned long)NumOfBooks);
             
             // TODO: [Casper] Build up bookInfoObj array for tableView display
             
             for (int i = 0; i < [BookNameArray count]; i ++) {
                 
                 BookInfo *TempBookInfoObj = [[BookInfo alloc] init];
                 TempBookInfoObj = [_BookSearch Books_ExtractToSingleBookInfoObjWithDictionary:_BookSearch.BookSearchDic ByIndex:i];
                 
                 [_SearchBookInfoObjArray addObject:TempBookInfoObj];
                 VIEW_LOG(@"_BookInfoObjArray size count = %i", [_SearchBookInfoObjArray count]);
                 
             }
             
             [_TableView reloadData];
             
             
             if (NumOfBooks == 1) {
                 
                 // If just 1 result, jump to detailed view
                // _BookInfoObj = [_BookSearch Books_ExtractToSingleBookInfoObjWithDictionary:_BookSearch.BookSearchDic];
                 
                 if (ShowSearchResult == NO) {
                     [_TableView setHidden:NO];

                     /*
                     _DetailedView = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailedView"];
                     _DetailedView.BookInfoObj = _BookInfoObj;
                     _DetailedView.FatherView = SearchBookView;
                     [self presentSemiViewController:_DetailedView];
                     
                     
                     [[NSNotificationCenter defaultCenter] removeObserver:self];
                     //[self performSegueWithIdentifier: @"BookDetailedInfo" sender: self];
                      */
                     ShowSearchResult = YES;
                 }
                 
                 
             } else {
                 if (ShowSearchResult == NO) {
                     [_TableView setHidden:NO];

                     ShowSearchResult = YES;
                 }
             }
             
             [self RemoveLoadingView];
             
         }
         
     }];
    
}



#pragma mark - SearchBar delegate method
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    VIEW_LOG(@"searchBarSearchButtonClicked");
    [self SearchBookWebTaskWithKeyWord:searchBar.text];
    [_SearchBar resignFirstResponder];
    [_BarCodeReaderBtn setHidden:YES];
    [self ShowLoadingView];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    VIEW_LOG(@"searchBarTextDidBeginEditing");
    // TODO: [Casper] Fetch local data and display
    
}


#pragma mark - Table data source method (Search Result Table)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    
    switch (section) {
        case 0:
            numberOfRows =[_TableDataSec0 count];
            break;
            
        case 1:
            numberOfRows =[_SearchBookInfoObjArray count];
            break;
            
        default:
            break;
    }
    
    return numberOfRows;
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *sectionStr = [[NSString alloc] init];
    
    switch (section) {
        case 0:
            sectionStr = nil;
            break;
                
        case 1:
            sectionStr = @"Rsults on Internet";
            break;
            
        case 2:
            sectionStr = @"Rsults of you list";
            break;
            
        default:
            break;
    }
        
    return sectionStr;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        // Set the first cell as CLEAR BTN
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
        cell.textLabel.text = @"Click to clear search results";
        cell.detailTextLabel.text = nil;
    }
    
    if (indexPath.section == 1) {
        // Results on internet
        BookInfo *BookInfoForDisplay = [BookInfo new];
        BookInfoForDisplay = [_SearchBookInfoObjArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = BookInfoForDisplay.BookName;
        cell.detailTextLabel.text = BookInfoForDisplay.BookAuthor;
    }
    //cell.textLabel.text = [NSString stringWithFormat:@"%@", [book valueForKey:@"bookName"]];
    //cell.imageView.image = [UIImage imageWithData:[book valueForKey:@"bookCoverImage"]];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [book valueForKey:@"bookAuthor"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (((indexPath.section == 0) && (indexPath.row == 0))) {
        _SearchBar.text = @"";
        [_TableDataSec0 removeAllObjects];
        [_SearchBookInfoObjArray removeAllObjects];
        _TableDataSec0 = [NSMutableArray arrayWithObjects:@"Click to clear search results", nil];
        [_TableView reloadData];
        // TODO: It needs some animation during the search result table hidden
        [_TableView setHidden:YES];
        [_BarCodeReaderBtn setHidden:NO];
        [_TableView deselectRowAtIndexPath:indexPath animated:NO];
    }

}


/*
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (((indexPath.section == 0) && (indexPath.row == 0))) {
        _SearchBar.text = @"";
        [_TableDataSec0 removeAllObjects];
        _TableDataSec0 = [NSMutableArray arrayWithObjects:@"Click to clear search results", nil];
        [_TableView reloadData];
        // TODO: It needs some animation during the search result table hidden
        [_TableView setHidden:YES];
        [_BarCodeReaderBtn setHidden:NO];
    }
    
    return indexPath;
}
*/


#pragma mark - Button Event
- (IBAction)BookListBtn:(id)sender
{
    // Back to BookListView
    UIViewController *View = [self.storyboard instantiateViewControllerWithIdentifier:@"BookListView"];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromLeft;
    
    [self.navigationController.view.layer
     addAnimation:transition forKey:kCATransition];
    
    [self.navigationController pushViewController:View animated:YES];
    
}

- (IBAction)BarCodeReaderBtn:(id)sender {
    VIEW_LOG(@"Barcode Reader");
}


@end
