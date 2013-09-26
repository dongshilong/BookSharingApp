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
    
    // 1. Setup UI
    _SearchBar.searchBarStyle = UISearchBarStyleProminent;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"Search Book";
    // 2. Setup Slide Bar function
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
        // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // 3. Init Flags
    SeguePerformed = NO;

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



#pragma mark - Search Keyword
- (void)SearchBookWebTaskWithKeyWord:(NSString *) SearchStr
{
    
    VIEW_LOG(@"SearchBookWebTask");
    _BookSearch = [[BooksHtml alloc] init];
    
    if (SeguePerformed == YES) {
        SeguePerformed = NO;
    }
    
    if (([SearchStr length] == 0) || (SearchStr == nil)) {
        //[_SearchBook Books_FireQueryWithKeyWords:@"ios app"];
        [_BookSearch Books_FireQueryWithKeyWords:@"9789866272516"];
        
    } else {
        
        VIEW_LOG(@"search text = %@", SearchStr);
        [_BookSearch Books_FireQueryWithKeyWords:SearchStr];
        
    }
    
#warning CHECK NOTIFY MARKED
    // TODO: Break here if no one key in search text.
    //[self performSelector:@selector(CheckNotify)];
    
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
             _BookInfoObj = [[BookInfo alloc] init];
             
             NSArray *BookNameArray = [_BookSearch Books_ExtractToBookNameArrayWithDictionary:_BookSearch.BookSearchDic];
             
             
             NSUInteger NumOfBooks = [BookNameArray count];
             BOOKS_SEARCH_LOG(@" - %i - Book(s) in the dictionary", NumOfBooks);
             
             if (NumOfBooks == 1) {
                 
                 // If just 1 result, jump to detailed view
                 _BookInfoObj = [_BookSearch Books_ExtractToSingleBookInfoObjWithDictionary:_BookSearch.BookSearchDic];
                 
                 if (SeguePerformed == NO) {
                     /*
                     _DetailedView = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailedView"];
                     _DetailedView.BookInfoObj = _BookInfoObj;
                     _DetailedView.FatherView = SearchBookView;
                     [self presentSemiViewController:_DetailedView];
                     
                     
                     [[NSNotificationCenter defaultCenter] removeObserver:self];
                     //[self performSegueWithIdentifier: @"BookDetailedInfo" sender: self];
                      */
                     SeguePerformed = YES;
                 }
                 
                 
             } else {
                 if (SeguePerformed == NO) {
                     
                     SeguePerformed = YES;
                 }
             }
             
             [self RemoveLoadingView];
             
         }
         
     }];
    
}



#pragma mark - SearchBar delegate method
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBarSearchButtonClicked");
    [self SearchBookWebTaskWithKeyWord:searchBar.text];
    [_SearchBar resignFirstResponder];
    [self ShowLoadingView];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarTextDidBeginEditing");
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

@end
