//
//  BooksHtml.m
//  ShareBook
//
//  Created by GIGIGUN on 13/9/11.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "BooksHtml.h"

@implementation BooksHtml

-(BooksHtml*) init
{
    if (self != nil) {
        [self Books_ResetAll];
        
    }
    return self;
}

-(void) Books_ResetAll
{
    _BookInfoObj = [[BookInfo alloc] init];
    _responseData = [[NSMutableData alloc] init];
    _BookInfoObj.BookName = @"NaN";
    _BookInfoObj.BookAuthor = @"NaN";
    _BookInfoObj.BookCoverURL = [NSURL URLWithString:@"NaN"];
    _BookInfoObj.BookISBN = @"NaN";
    _BookInfoObj.BookInfoIntro = @"NaN";
    _State = BOOKS_INIT;
    NotificationSent = NO;
}


-(void) Books_SendStatusNotificationWithValue: (NSString *) Value
{
    NSArray *userInfoKeys = [NSArray arrayWithObjects:BOOK_SEARCH_NOTIFICATION_KEY, nil];
    NSArray *userInfoValues = [NSArray arrayWithObjects:Value, nil];
    
    BOOKS_SEARCH_LOG(@"Send Notification with value = %@", Value);
    
    NSNotification *notification = [NSNotification notificationWithName:BOOK_INFO_NOTIFY_ID
                                                                 object:nil
                                                               userInfo:[NSDictionary dictionaryWithObjects:userInfoValues forKeys:userInfoKeys]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    
}

#pragma mark - Methods interface
-(NSArray*) Books_ExtractToBookNameArrayWithDictionary : (NSDictionary *) SearchBooksDic
{
    NSArray *BookNameArray;

    BookNameArray = [NSArray arrayWithArray:[SearchBooksDic objectForKey:BOOK_DIC_BOOK_NAME_KEY]];

    return BookNameArray;
}


-(NSArray*) Books_ExtractToBookAuthorArrayWithDictionary : (NSDictionary *) SearchBooksDic
{
    NSArray *BookAuthorArray;
    
    BookAuthorArray = [NSArray arrayWithArray:[SearchBooksDic objectForKey:BOOK_DIC_BOOK_AUTHOR_KEY]];
    
    return BookAuthorArray;
}



-(NSArray*) Books_ExtractToBookDetailedUrlArrayWithDictionary : (NSDictionary *) SearchBooksDic
{
    NSArray *BookURLArray;
    
    BookURLArray = [NSArray arrayWithArray:[SearchBooksDic objectForKey:BOOK_DIC_BOOK_URL_KEY]];
    
    return BookURLArray;
}


-(NSArray*) Books_ExtractToBookCoverUrlArrayWithDictionary : (NSDictionary *) SearchBooksDic
{
    NSArray *BookCoverURLArray;
    
    BookCoverURLArray = [NSArray arrayWithArray:[SearchBooksDic objectForKey:BOOK_DIC_BOOK_COVER_URL_KEY]];
    
    return BookCoverURLArray;
}

-(BookInfo *) Books_ExtractToSingleBookInfoObjWithDictionary : (NSDictionary *) SearchBooksDic ByIndex : (NSUInteger) Index
{
    BookInfo *BookInfoObj = [[BookInfo alloc] init];
    
    BookInfoObj.BookName = [[self Books_ExtractToBookNameArrayWithDictionary:SearchBooksDic] objectAtIndex:Index];
    BookInfoObj.BookAuthor = [[self Books_ExtractToBookAuthorArrayWithDictionary:SearchBooksDic] objectAtIndex:Index];
    BookInfoObj.BookInfoURL = [[self Books_ExtractToBookDetailedUrlArrayWithDictionary:SearchBooksDic] objectAtIndex:Index];
    BookInfoObj.BookCoverURL = [[self Books_ExtractToBookCoverUrlArrayWithDictionary:SearchBooksDic] objectAtIndex:Index];
    
    return BookInfoObj;
}
/*
-(NSInteger) Books_GetBooksDicSize : (NSDictionary  *) SearchBooksDic
{
    [SearchBooksDic ]
}
*/

#pragma mark - State Machine
-(void) Books_StateMachine
{
    switch (_State) {
            
        case BOOKS_INIT:
            BOOKS_SEARCH_LOG(@"BOOKS_INIT");
            NotificationSent = NO;
            break;
            
        case BOOKS_SEARCH_KEY_WORDS:
            {
                if (_BookSearchDic == nil) {
                    
                    _BookSearchDic = [[NSDictionary alloc] init];
                    _BookSearchDic = [_BooksTW BooksTW_PrepareBoosSearchResultTable:_responseData];
                    BOOKS_SEARCH_LOG(@"BOOKS_SEARCH_KEY_WORDS");
                                        
                    if (_BookSearchDic != nil) {
                        BOOKS_SEARCH_LOG(@"NOTIFICATION  = %i", NotificationSent);
                        
                        if (NotificationSent == NO) {
                            [self Books_SendStatusNotificationWithValue:BOOK_SEARCH_RESULT_TABLE_DONE];
                            NotificationSent = YES;
                        }
                    }
                }
            }
            break;
            
        default:
            break;
    }
}



#pragma mark - Search URL Generator
-(NSURL*) PrepareSearchURLWithKeyword : (NSString*) KeyWord
{
    _BooksTW = [[SearchBooksTW alloc] init];
    return [_BooksTW BooksTW_PrepareSearchURLWithKeyWords:KeyWord];
}

-(void) Books_FireQueryWithKeyWords:(NSString *) KeyWord
{
    NSURL *SearchingURL = [self PrepareSearchURLWithKeyword:KeyWord];
    NSURLRequest *request=[NSURLRequest requestWithURL:SearchingURL];
    BOOKS_SEARCH_LOG(@"Fire Connection !! %@", [request.URL absoluteString]);
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    _State = BOOKS_SEARCH_KEY_WORDS;
}


#pragma mark - NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    BOOKS_SEARCH_LOG(@"didReceiveResponse");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    BOOKS_SEARCH_LOG(@"didReceiveData");
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    BOOKS_SEARCH_LOG(@"connectionDidFinishLoading");
    [self Books_StateMachine];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    BOOKS_ERROR_LOG(@"didFailWithError");

}
@end
