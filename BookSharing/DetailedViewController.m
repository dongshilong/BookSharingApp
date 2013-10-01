//
//  DetailedViewController.m
//  BookSharing
//
//  Created by GIGIGUN on 13/9/25.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "DetailedViewController.h"
@interface DetailedViewController ()

@end

@implementation DetailedViewController

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
    
    // 1. Assign Header View
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"BookInfoHeader" owner:self options:nil];
    _BookInfoHeaderView = (BookInfoHeader *)[subviewArray objectAtIndex:0];
    _BookInfoHeaderView.frame = CGRectMake(0, 64, _BookInfoHeaderView.frame.size.width, _BookInfoHeaderView.frame.size.height);
    _BookInfoHeaderView.BackLab.layer.cornerRadius = 4;
    [self.view addSubview:_BookInfoHeaderView];
    
    // 2. If self came from SearchView, Fire detailed info connection.
    VIEW_LOG(@"From %i - %@", _FatherView, _BookInfoObj.BookName);
    if (_FatherView == SearchBookView) {
        
        if (_BookInfoObj.BookCoverImage != nil) {
            
            _BookInfoHeaderView.BookCoverView.image = [UIImage imageWithData:_BookInfoObj.BookCoverImage];
            _BookInfoHeaderView.BookNameLab.text = _BookInfoObj.BookName;
            
            // TODO: [Casper] Tty to get detailed information
            VIEW_LOG(@"%@", [_BookInfoObj.BookInfoURL absoluteString]);
            [self FireDetailedInfoWithBookInfoURL:_BookInfoObj.BookInfoURL];
            [self ShowLoadingView];
        }
        
    } else {
        
        // 3. Assign Scroll View
        NSArray *ScrollerArray = [[NSBundle mainBundle] loadNibNamed:@"DetailedScroller" owner:self options:nil];
        _BookInfoDetailedView = (DetailedScroller *)[ScrollerArray objectAtIndex:0];
        _BookInfoDetailedView.frame = CGRectMake(0, 0, _BookInfoDetailedView.frame.size.width, _BookInfoDetailedView.frame.size.height);
        
        [_Scroller setContentSize:CGSizeMake(320, _BookInfoDetailedView.frame.size.height)];
        [_Scroller setScrollEnabled:YES];
        [_Scroller addSubview:_BookInfoDetailedView];
        
    
    }
    

    
    
    // 4. Set flag
    _NotificationState_OLD = @"Init";
    
    // 5. init image data
    _responseData = [[NSMutableData alloc] init];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Notifications
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
         
         if ([[dict objectForKey:BOOK_SEARCH_NOTIFICATION_KEY] isEqualToString:_NotificationState_OLD]) {
             
             // Do nothing if the same notify comes up
             VIEW_LOG(@"Same as _NotificationState_OLD");
             
             
         } else {
             
             if (([[dict objectForKey:BOOK_SEARCH_NOTIFICATION_KEY] isEqualToString:BOOK_DETAILED_BOOK_INFO_PAGE_DONE]))
             {
                 VIEW_LOG(@"BOOK_DETAILED_BOOK_INFO_PAGE_DONE");
                 // TODO: [Casper] To Pass whole information to view layer
                 _BookInfoObj.BookCoverHDURL = _BookInfoQuery.BookInfoObj.BookCoverHDURL;
                 _BookInfoObj.BookISBN = _BookInfoQuery.BookInfoObj.BookISBN;
                 
                 if (_BookInfoObj.BookCoverHDURL != nil) {
                     [self FireBookCoverHDQueryConnectionWithBookCoverHDURL:_BookInfoObj.BookCoverHDURL];
                     // CHECK CONNECTION DELEGATE METHOD
                 }
                 
                 [self RemoveLoadingView];
             }
         }
         
         
         
     }];
}


#pragma mark - Connection
-(void) FireDetailedInfoWithBookInfoURL:(NSURL*) BookDetailedInfoURL
{
    
    _BookInfoQuery = [[BooksHtml alloc] init];
    [_BookInfoQuery Books_FireQueryBookDetailedInfoWithURL:BookDetailedInfoURL];

    [self performSelector:@selector(CheckNotify)];
    
    // Enable loading icon on the status bar
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

}

-(void) FireBookCoverHDQueryConnectionWithBookCoverHDURL: (NSURL*) BookCoverURLHD
{
    
    VIEW_LOG(@"Fire Image Cover Connection!!!");
    NSURLRequest *request=[NSURLRequest requestWithURL:BookCoverURLHD];
    BookCoverConn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
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


-(BOOL) DetailedView_SetScrollContentWithBookInfoObj:(BookInfo*) BookInfoObj ForContentView:(UIView*) ContentView
{
    BOOL Success = NO;
    
    // 1. Set BookIntro Label
    
    return Success;
}


#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    BOOKS_SEARCH_LOG(@"didReceiveData");
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    VIEW_LOG(@"connectionDidFinishLoading");
    NSURLRequest *CurrRequest = [connection currentRequest];
    if ([[CurrRequest.URL absoluteString] isEqualToString:[_BookInfoObj.BookCoverHDURL absoluteString]]) {
        VIEW_LOG(@"%@", [UIImage imageWithData:_responseData]);
        _BookInfoHeaderView.BookCoverView.image = [UIImage imageWithData:_responseData];
    }
}





@end
