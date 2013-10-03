//
//  SeachViewController.m
//  BookSharing
//
//  Created by GIGIGUN on 13/9/26.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "SeachViewController.h"
#import "TableCellSmall.h"
#import "DetailedViewController.h"

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
    _NotificationState_OLD = @"Init";
    _LocalIndexPath = [[NSIndexPath alloc] init];
    
    // 4. Init Data
    BarcodeDefaultLocation = CGPointMake(_BarCodeReaderBtn.center.x, _BarCodeReaderBtn.center.y);
    _TableDataSec0 = [NSMutableArray arrayWithObjects:@"Click to clear search results", nil];

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
    [_TableView deselectRowAtIndexPath:_LocalIndexPath animated:NO];

    [self RemoveLoadingView];
}

-(void) resetData
{
    VIEW_LOG(@"RESET!!!");
    _SearchBar.text = @"";
    [_TableDataSec0 removeAllObjects];
    [_SearchBookInfoObjArray removeAllObjects];
    _TableDataSec0 = [NSMutableArray arrayWithObjects:@"Click to clear search results", nil];
    [_TableView reloadData];
    // TODO: It needs some animation during the search result table hidden
    
    NSLog(@"TEST ANIMATION");
    [self AnimationHideTableView];
    
    [_TableView setHidden:YES];
    [_BarCodeReaderBtn setHidden:NO];
    //[_TableView deselectRowAtIndexPath:indexPath animated:NO];
    [_TableCoverImageArray removeAllObjects];
    _NotificationState_OLD = @"Init";

}

#pragma mark - UI activities
-(void) SingleBtnAlertWithString: (NSString *) AlertString
                                  MessageStr : (NSString*) Message
                                andBtnString : (NSString*) BtnString
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:AlertString
                                                    message:Message
                                                   delegate:self
                                          cancelButtonTitle:BtnString
                                          otherButtonTitles:nil];
    
    //將Alerts顯示於畫面上
    [alert show];
    
}


-(void) MoveUpBarcodeReaderBtn
{
    
    CGPoint MoveUp = CGPointMake( _BarCodeReaderBtn.center.x, 180.0f + _BarCodeReaderBtn.frame.size.width / 2.0f);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    _BarCodeReaderBtn.center = MoveUp;
    [UIView commitAnimations];
    
}

-(void) ResetBarcodeReaderBtnAndDisapear : (BOOL) SetDisapear
{
    
    CGPoint Reset = BarcodeDefaultLocation;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0f];
    _BarCodeReaderBtn.center = Reset;
    [UIView commitAnimations];
    
    if (SetDisapear) {
        [_BarCodeReaderBtn setHidden:YES];
    }
    
}


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
    
    if ([_SearchBookInfoObjArray count] != 0) {
        
        [self ResetBarcodeReaderBtnAndDisapear:YES];
        [_TableView setHidden:NO];
        
    } else {
        [self ResetBarcodeReaderBtnAndDisapear:NO];
    }
    [_SearchBar resignFirstResponder];

}

// 提供 Table view 在離開以及消失時的動畫
-(void) AnimationHideTableView
{
    if(_TableView.hidden == NO)
    {
        CATransition *transition = [CATransition animation];
        
        [transition setDelegate:self];
        [transition setDuration:0.3f];
        
        [transition setType:kCATransitionFade];
        [transition setSubtype:kCATransitionFromBottom];
        
        [[_TableView layer] addAnimation:transition forKey:@"myTransition"];
    }
}



#pragma mark - Search Keyword
- (void)SearchBookWebTaskWithKeyWord:(NSString *) SearchStr
{
    
    VIEW_LOG(@"SearchBookWebTask");
    if (_BookSearch == nil) {
        _BookSearch = [[BooksHtml alloc] init];
    }
    
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
         VIEW_LOG(@"GET Notified %@ - (OLD)%@", [dict objectForKey:BOOK_SEARCH_NOTIFICATION_KEY], _NotificationState_OLD);
         
         if ([[dict objectForKey:BOOK_SEARCH_NOTIFICATION_KEY] isEqualToString:_NotificationState_OLD]) {
             
             // Do nothing if the same notify comes up
             VIEW_LOG(@"Same as _NotificationState_OLD");

             
         } else {
             
             if (([[dict objectForKey:BOOK_SEARCH_NOTIFICATION_KEY] isEqualToString:BOOK_SEARCH_RESULT_TABLE_DONE])){
                 
                 // Extract Book Name | Book Author | Book Info URL Array | Book Cover URL
                 // To guerentee all the data is the latest
                 _NotificationState_OLD = BOOK_SEARCH_RESULT_TABLE_DONE;
                 [_SearchBookInfoObjArray removeAllObjects];
                 NSUInteger Size = [[_BookSearch Books_ExtractToBookNameArrayWithDictionary:_BookSearch.BookSearchDic] count];
                 
                 if (Size != 0) {
                     
                     for (int i = 0; i < Size; i ++) {
                         
                         BookInfo *TempBookInfoObj = [[BookInfo alloc] init];
                         TempBookInfoObj = [_BookSearch Books_ExtractToSingleBookInfoObjWithDictionary:_BookSearch.BookSearchDic ByIndex:i];
                         [_SearchBookInfoObjArray addObject:TempBookInfoObj];
                         VIEW_LOG(@"_BookInfoObjArray size count = %i", [_SearchBookInfoObjArray count]);
                         
                     }
                     
                     if (ShowSearchResult == NO) {
                         
                         // To avoid execution twice
                         [_TableView reloadData];
                         [_TableView setHidden:NO];
                         ShowSearchResult = YES;
                         
                     }
                     
                     dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                         
                         // To query table image in background
                         [self performSelector:@selector(getTableImage)];
                        
                         dispatch_async( dispatch_get_main_queue(), ^{
                             // Add code here to update the UI/send notifications based on the
                             // results of the background processing
                             [_TableView reloadData];
                             
                         });
                     });
                     
                 } else {
                     
                     [self SingleBtnAlertWithString:@"Book Not Found"
                                         MessageStr:@"Enter another keyword and try again" andBtnString:@"OK"];
                     VIEW_LOG(@"There's no result");
                     
                 }
                 
                 [self RemoveLoadingView];

             }
         }
         
         
             
     }];
}


-(void) getTableImage
{
    VIEW_LOG(@"getTableImage %i ===", [_SearchBookInfoObjArray count]);
    [_TableCoverImageArray removeAllObjects];
    
    for (int i = 0; i < [_SearchBookInfoObjArray count]; i ++) {

        //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:2];
        //NSArray *IndexPathArray = [NSArray arrayWithObjects:indexPath, nil];
        BookInfo *TempBook = [_SearchBookInfoObjArray objectAtIndex:i];
        NSData *CoverImageData = [NSData dataWithContentsOfURL:TempBook.BookCoverURL];
        //NSLog(@"%@", [TempBook.BookCoverURL absoluteString]);
        
       // [_TableView reloadRowsAtIndexPaths:IndexPathArray withRowAnimation:UITableViewRowAnimationNone];
        [_TableCoverImageArray addObject:CoverImageData];
    }
    
}



#pragma mark - SearchBar delegate method
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    VIEW_LOG(@"searchBarSearchButtonClicked");

    if (_TableCoverImageArray == nil) {
        _TableCoverImageArray = [[NSMutableArray alloc] init];
    }
    
    if (_SearchBookInfoObjArray == nil) {
        _SearchBookInfoObjArray = [[NSMutableArray alloc] init];
    }
    _NotificationState_OLD = @"Init";
    [_TableCoverImageArray removeAllObjects];
    [_SearchBookInfoObjArray removeAllObjects];
    [_TableView setHidden:YES];
    [_SearchBar resignFirstResponder];
    [_BarCodeReaderBtn setHidden:YES];
    [self ShowLoadingView];
    
    [self SearchBookWebTaskWithKeyWord:searchBar.text];

}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    VIEW_LOG(@"searchBarTextDidBeginEditing");
    [_TableView setHidden:YES];
    [self RemoveLoadingView];
    [_BookSearch Books_RemoveConnection];

    [_BarCodeReaderBtn setHidden:NO];
    [self MoveUpBarcodeReaderBtn];
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
    
    static NSString *CellIdentifier;
    
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        // Set the first cell as CLEAR BTN
        CellIdentifier = @"ClearCell";
        
    } else {
        
        CellIdentifier = @"Cell";
        
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 1) {
        // Results on internet
        BookInfo *BookInfoForDisplay = [BookInfo new];
        BookInfoForDisplay = [_SearchBookInfoObjArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = BookInfoForDisplay.BookName;
        cell.detailTextLabel.text = BookInfoForDisplay.BookAuthor;
        
        if (_TableCoverImageArray != nil && [_TableCoverImageArray count] != 0) {
            
            if ([_TableCoverImageArray objectAtIndex:indexPath.row] != nil) {
                cell.imageView.image = [UIImage imageWithData:[_TableCoverImageArray objectAtIndex:indexPath.row]];
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _LocalIndexPath = indexPath;
    
    if (((indexPath.section == 0) && (indexPath.row == 0))) {
        [_TableView deselectRowAtIndexPath:indexPath animated:NO];
        [self resetData];
    } else {
        
        VIEW_LOG(@"select at index path section : %i - row : %i", indexPath.section, indexPath.row);
    }

}



#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"BookDetailedInfo"])
    {
        NSIndexPath *Selection = [_TableView indexPathForSelectedRow];
        BookInfo *BookInfoForParse = [BookInfo new];
        BookInfoForParse = [_SearchBookInfoObjArray objectAtIndex:Selection.row];
        
        DetailedViewController *destViewController = segue.destinationViewController;
        destViewController.FatherView = SearchBookView;
        destViewController.BookInfoObj = BookInfoForParse;
        destViewController.BookInfoObj.BookCoverImage = [_TableCoverImageArray objectAtIndex:Selection.row];
    }
}


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

- (IBAction)BarcodeReaderBtn:(id)sender
{
    VIEW_LOG(@"BarcodeReaderBtn");
    
    if (_TableCoverImageArray == nil) {
        _TableCoverImageArray = [[NSMutableArray alloc] init];
    }
    
    if (_SearchBookInfoObjArray == nil) {
        _SearchBookInfoObjArray = [[NSMutableArray alloc] init];
    }
    _NotificationState_OLD = @"Init";
    [_TableCoverImageArray removeAllObjects];
    [_SearchBookInfoObjArray removeAllObjects];
    [_TableView setHidden:YES];
    
    
    [_SearchBar resignFirstResponder];
    _SearchBar.text = @"9789866272516";

    [self SearchBookWebTaskWithKeyWord:_SearchBar.text];
    [self ShowLoadingView];
    [self ResetBarcodeReaderBtnAndDisapear:YES];
    
}


@end
