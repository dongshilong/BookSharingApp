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
            
            _BookInfoHeaderView.BookCoverViewSMALL.image = [UIImage imageWithData:_BookInfoObj.BookCoverImage];
//            _BookInfoHeaderView.BookCoverView.image = [UIImage imageWithData:_BookInfoObj.BookCoverImage];
            _BookInfoHeaderView.BookNameLab.text = _BookInfoObj.BookName;
            
            // TODO: [Casper] Tty to get detailed information
            VIEW_LOG(@"%@", [_BookInfoObj.BookInfoURL absoluteString]);
            [self FireDetailedInfoWithBookInfoURL:_BookInfoObj.BookInfoURL];
            [self ShowLoadingView];
        }
        
    } else {
        
        // 3. Assign Scroll View
        [self DetailedView_SetScrollContentWithBookInfoObj:_BookInfoObj];
        
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

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [BookCoverConn cancel];
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
                 _NotificationState_OLD = BOOK_DETAILED_BOOK_INFO_PAGE_DONE;
                 
                 // TODO: [Casper] To Pass whole information to view layer
                 _BookInfoObj.BookCoverHDURL = _BookInfoQuery.BookInfoObj.BookCoverHDURL;
                 _BookInfoObj.BookISBN = _BookInfoQuery.BookInfoObj.BookISBN;
                 _BookInfoObj.BookInfoStrongIntro = _BookInfoQuery.BookInfoObj.BookInfoStrongIntro;
                 // TODO: [Casper] if BookISBN is nil, try to get it from somewhere else.
                 
                 
                 [self DetailedView_SetScrollContentWithBookInfoObj:_BookInfoObj];
                 
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
    if (_BookInfoQuery == nil) {
        _BookInfoQuery = [[BooksHtml alloc] init];
    }
    
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

-(void) SetupScrollViewWithContentView : (UIView*) DetailedView
{

    NSArray *ScrollerArray = [[NSBundle mainBundle] loadNibNamed:@"DetailedScroller" owner:self options:nil];
    DetailedView = (DetailedScroller *)[ScrollerArray objectAtIndex:0];
    DetailedView.frame = CGRectMake(0, 0, DetailedView.frame.size.width, DetailedView.frame.size.height);

    [_Scroller setContentSize:CGSizeMake(320, DetailedView.frame.size.height)];
    [_Scroller setScrollEnabled:YES];
    [_Scroller addSubview:DetailedView];
}


-(BOOL) DetailedView_SetScrollContentWithBookInfoObj:(BookInfo*) BookInfoObj
{
    BOOL Success = NO;

    [_Scroller setContentSize:CGSizeMake(320, 1000)];
    [_Scroller setScrollEnabled:YES];
    
    // Assign Scrolling view
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"DetailedScroller" owner:self options:nil];
    if (subviewArray == nil) {
        VIEW_ERROR_LOG(@"CANNOT FIND DetailedScroller.xib");
        return NO;
    }
    
    _BookInfoDetailedView = (DetailedScroller *)[subviewArray objectAtIndex:0];
    [_Scroller addSubview:_BookInfoDetailedView];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    float StartY = 0.0f;

    
    if (BookInfoObj.BookInfoStrongIntro) {
        
        UILabel* StrongLab = [[UILabel alloc] init];
        [StrongLab setText:BookInfoObj.BookInfoStrongIntro];
        [StrongLab setFont:font];
        StrongLab.numberOfLines = 0;
        [StrongLab setBackgroundColor: [UIColor whiteColor]];
        CGSize constraint = CGSizeMake(300, 20000.0f);
        
        CGSize size = [StrongLab sizeThatFits:constraint];
        [StrongLab setFrame:CGRectMake(10, StartY + 10, size.width, size.height)];
        StrongLab.numberOfLines = 0;
        
        [_Scroller setContentSize:CGSizeMake(320, StartY + size.height + 50)];
        [_Scroller addSubview: StrongLab];
        
    }

    
    
    /*
    UILabel *StrongIntroLab = [[UILabel alloc] init];
    StrongIntroLab.text = BookInfoObj.BookInfoStrongIntro;
    StrongIntroLab.backgroundColor = [UIColor blackColor];
    [StrongIntroLab setFont:font];
    [StrongIntroLab setFrame:CGRectMake(10, 10, StrongIntroLab.frame.size.width, StrongIntroLab.frame.size.height)];
    //CGSize constraint = CGSizeMake(300, 20000.0f);
    
    //[StrongIntroLab setFrame:CGRectMake(10, 10, size.width, size.height)];
    //NSLog(@"size height %f", size.height);
    StrongIntroLab.numberOfLines = 0;
    NSLog(@"!!!!!\n%@", StrongIntroLab);
*/
    return Success;
}


#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    VIEW_LOG(@"connectionDidFinishLoading");
    NSURLRequest *CurrRequest = [connection currentRequest];
    
    if ([[CurrRequest.URL absoluteString] isEqualToString:[_BookInfoObj.BookCoverHDURL absoluteString]]) {
        
        VIEW_LOG(@"%@", [UIImage imageWithData:_responseData]);
        _BookInfoHeaderView.BookCoverView.image = [UIImage imageWithData:_responseData];
        [_BookInfoHeaderView.BookCoverViewSMALL setHidden:YES];
        
    }
}





@end
