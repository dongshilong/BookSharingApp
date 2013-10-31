//
//  DetailedViewController.m
//  BookSharing
//
//  Created by GIGIGUN on 13/9/25.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "DetailedViewController.h"
#import "UIViewController+KNSemiModal.h"
#import "BookListViewController.h"

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
    _BookAlreadyHave = NO;
    
    // 1. Assign Header View
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"BookInfoHeader" owner:self options:nil];
    _BookInfoHeaderView = (BookInfoHeader *)[subviewArray objectAtIndex:0];
    _BookInfoHeaderView.frame = CGRectMake(0, 64, _BookInfoHeaderView.frame.size.width, _BookInfoHeaderView.frame.size.height);
    _BookInfoHeaderView.BackLab.layer.cornerRadius = 4;
    [self.view addSubview:_BookInfoHeaderView];
    
    // 2. If self came from SearchView, Fire detailed info connection.
    VIEW_LOG(@"From %i", _FatherView);
    if (_FatherView == SearchBookView) {
        
        self.navigationItem.rightBarButtonItem = nil;
        
        if (_BookInfoObj.BookCoverImage != nil) {
            
            _BookInfoHeaderView.BookCoverViewSMALL.image = [UIImage imageWithData:_BookInfoObj.BookCoverImage];
            _BookInfoHeaderView.BookNameLab.text = _BookInfoObj.BookName;
            _BookInfoHeaderView.BookAuthorLab.text = _BookInfoObj.BookAuthor;
            
            VIEW_LOG(@"%@", [_BookInfoObj.BookInfoURL absoluteString]);
            [self FireDetailedInfoWithBookInfoURL:_BookInfoObj.BookInfoURL];
            [self ShowLoadingView];
        }
        
    } else if (_FatherView == ListBookView) {
        
        // 3. Assign Scroll View
        // if self comes from List View, the bookInfoObj would init by NSManagedObject
        _BookInfoObj = [[BookInfo alloc] initWithCoreDataObj:_book];
        
        _BookInfoHeaderView.BookCoverView.image = [UIImage imageWithData:_BookInfoObj.BookCoverImage];
        _BookInfoHeaderView.BookNameLab.text = _BookInfoObj.BookName;
        _BookInfoHeaderView.BookAuthorLab.text = _BookInfoObj.BookAuthor;

        [self DetailedView_SetScrollContentWithBookInfoObj:_BookInfoObj WithFatherView:ListBookView];
        
    }
    
    // 4. Set flag and init models
    _NotificationState_OLD = @"Init";
    _BookDataBase = [[BookListData alloc] init];
    
    // 5. init image data
    _responseData = [[NSMutableData alloc] init];
    
    // Google Analytics
    self.screenName = @"Detailed Info View";
    
    // Facebook
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 //_ProfileName.text = user.name;
                 //self.userProfileImage.profileID = [user objectForKey:@"id"];
                 NSLog(@"%@ - %@", user.name, [user objectForKey:@"id"]);
             }
         }];
    } else {
        
        //VIEW_LOG(@"Facebook Test is NOT open");
    }
    
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

// EditBookInfoViewController Show and Hide Notify
-(void) KSemiModalTransNotify
{
    [[NSNotificationCenter defaultCenter] addObserverForName:kSemiModalDidShowNotification
                                                      object:nil queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification)
     {
         VIEW_LOG(@"The Semi View Shows");
     }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kSemiModalDidHideNotification
                                                      object:nil queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification)
     {
        if(_editBookViewContoller.TheBookIsDeleted)
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
         VIEW_LOG(@"The Semi View Hide");
     }];

}

// BooksHtml Model Notify
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
                 _BookInfoObj.BookInfoIntro = _BookInfoQuery.BookInfoObj.BookInfoIntro;
                 
                 NSArray *SearchISBN = [_BookDataBase Books_CoreDataSearchWithBookISBN:_BookInfoObj.BookISBN];
                 if ([SearchISBN count] != 0) {
                     
                     _BookAlreadyHave = YES;
                     NSLog(@"ISBN FOUND!!");
                     
                 }
                 
                 // TODO: [Casper] if BookISBN is nil, try to get it from somewhere else.
                 [self DetailedView_SetScrollContentWithBookInfoObj:_BookInfoObj WithFatherView:SearchBookView];
                 
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

-(void) BookSaveViewAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SAVE SUCCESS"
                                                    message:@"Back to search result"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    //將Alerts顯示於畫面上
    [alert show];
    
    
}

// 點了 OK 後要執行的 Method
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
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


-(BOOL) DetailedView_SetScrollContentWithBookInfoObj:(BookInfo*) BookInfoObj WithFatherView:(FatherViewController) FatherView
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
    
    // Assign btn on the subview
    _BookInfoDetailedView = (DetailedScroller *)[subviewArray objectAtIndex:0];
    
    [_Scroller addSubview:_BookInfoDetailedView];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    UIFont *font2 = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];

    float StartY = 230.0f;
    CGSize size = CGSizeMake(300, 0);
    
    // Hide Save Btn when came from list view
    if (FatherView == ListBookView) {
        
        StartY = 180.0f;
        [_BookInfoDetailedView.SaveBtn setHidden:YES];
        
    } else {
        
        if (_BookAlreadyHave) {
            
            // Book Already in by judging from ISBN barcode
            _BookInfoDetailedView.SaveBtn.alpha = 0.4;
            _BookInfoDetailedView.SaveBtn.enabled = NO;
            
        }
    }
    
    // Assign Save Btn
    [_BookInfoDetailedView.SaveBtn addTarget:self
                                      action:@selector(SaveBookInfoObj)
                            forControlEvents:UIControlEventTouchUpInside];
    

    // Place Strong Intro Label
    if ((BookInfoObj.BookInfoStrongIntro != nil) &&
        (NO == [BookInfoObj.BookInfoStrongIntro isEqualToString:BOOKS_CORE_DATA_DEFAULT_VALUE])) {

        UILabel *StrongLab = [[UILabel alloc] init];
        [StrongLab setText:BookInfoObj.BookInfoStrongIntro];
        [StrongLab setFont:font];
        StrongLab.numberOfLines = 0;
        [StrongLab setBackgroundColor: [UIColor whiteColor]];
        CGSize constraint = CGSizeMake(300, 20000.0f);
        
        size = [StrongLab sizeThatFits:constraint];
        [StrongLab setFrame:CGRectMake(10, StartY + 20, size.width, size.height)];
        StrongLab.numberOfLines = 0;
        [_Scroller addSubview: StrongLab];
        
        StartY = StartY + 20 + size.height;

    }
    
    // Place Intro Label
    if ((BookInfoObj.BookInfoIntro != nil) &&
        (NO == [BookInfoObj.BookInfoIntro isEqualToString:BOOKS_CORE_DATA_DEFAULT_VALUE])) {
        
        UILabel *IntroLab = [[UILabel alloc] init];
        [IntroLab setText:BookInfoObj.BookInfoIntro];
        [IntroLab setFont:font2];
        IntroLab.numberOfLines = 0;
        [IntroLab setBackgroundColor: [UIColor whiteColor]];
        CGSize constraint = CGSizeMake(300, 20000.0f);
        
        size = [IntroLab sizeThatFits:constraint];
        [IntroLab setFrame:CGRectMake(10, StartY + 20, size.width, size.height)];
        IntroLab.numberOfLines = 0;
        [_Scroller addSubview: IntroLab];
        
        StartY = StartY + 20 + size.height;

        
    }
    

    [_Scroller setContentSize:CGSizeMake(320, StartY + 50)];
    
    return Success;
}

#pragma mark - Book Database methods
-(void) SaveBookInfoObj
{
    
    // Search Book In DB With ISBN
    NSArray *SearchResult;
    if (_BookInfoObj.BookISBN != nil) {
        
        SearchResult = [NSArray arrayWithArray:[_BookDataBase Books_CoreDataSearchWithBookISBN:_BookInfoObj.BookISBN]];
        
        if ([SearchResult count] != 0) {
            VIEW_LOG(@"Book Already in the DB");
        }

    } else {
        
        // TODO: if there were no ISBN in this book,
        VIEW_ERROR_LOG(@"Could not execute ISBN search");

    }
    
    VIEW_LOG(@"Save %@ to data base", _BookInfoObj.BookName);
    if (BOOKSLIST_SUCCESS != [_BookDataBase Books_SaveBookInfoObj:_BookInfoObj InDatabase:BOOK_LIST]) {
        VIEW_ERROR_LOG(@"SAVE ERROR");
    }
    
    // Set Force Sync
    extern BOOL GLOBAL_FORCE_SYNC;
    GLOBAL_FORCE_SYNC = YES;
    
    [_BookDataBase Books_FirePOSTConnectionToServerWithBookInfo:_BookInfoObj];
    
    [self BookSaveViewAlert];
    
}

-(void) DeleteBookInfoObjInDB
{
    NSLog(@"DELETE");
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
        _BookInfoObj.BookCoverImage = _responseData;
        [_BookInfoHeaderView.BookCoverViewSMALL setHidden:YES];
        
    }
}

- (IBAction)EditBtn:(id)sender {
    
    [self performSelector:@selector(KSemiModalTransNotify)];
    _editBookViewContoller = [self.storyboard instantiateViewControllerWithIdentifier:@"EditBook"];
    //_editBookViewContoller.BookInfoObj = _BookInfoObj;
    _editBookViewContoller.book = _book;
    
    [self presentSemiViewController:_editBookViewContoller];
}
@end
