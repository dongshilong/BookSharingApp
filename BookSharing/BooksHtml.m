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
        _BookSearchKeyWord = nil;
        [self Books_ResetAll];
        
    }
    return self;
}

-(void) Books_ResetAll
{
    if (_BookInfoObj == nil) {
        _BookInfoObj = [[BookInfo alloc] init];
    }
    
    if (_responseData == nil) {
        _responseData = [[NSMutableData alloc] init];
    }
    
    [_responseData setLength:0];
    _BookSearchDic = nil;
    _BookInfoObj.BookName = @"NaN";
    _BookInfoObj.BookAuthor = @"NaN";
    _BookInfoObj.BookCoverURL = [NSURL URLWithString:@"NaN"];
    _BookInfoObj.BookISBN = @"NaN";
    _BookInfoObj.BookInfoIntro = @"NaN";
    _State = BOOKS_INIT;
    NotificationSent = NO;
}

//
// Usage: 判斷輸入的 String 是否為數字
// Parameter: string
//
-(bool) IS_NumericStr:(NSString*) hexText
{
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    
    NSNumber* number = [numberFormatter numberFromString:hexText];
    
    if (number != nil) {
        NSLog(@"%@ is numeric", hexText);
        //do some stuff here
        return YES;
    }
    
    NSLog(@"%@ is not numeric", hexText);
    //or do some more stuff here
    return NO;
}


// ISBN String Judgement
-(BOOL) IS_ISBNStr:(NSString *) inputStr
{
    if (![self IS_NumericStr:inputStr]) {
        return NO;
    }
    
    if (([inputStr length] != 10) && ([inputStr length] != 13)) {
        return NO;
    }
    
    return YES;
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

#pragma mark - For FindBook Search Engine Only
-(NSString*) Books_ExtractBookIntro
{
    return [_FindBooks FindBook_PrepareBookIntro:_responseData];
}

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
                BOOKS_SEARCH_LOG(@"BOOKS_SEARCH_KEY_WORDS");

                if (_BookSearchDic == nil) {
                    
                    _BookSearchDic = [[NSDictionary alloc] init];
                    _BookSearchDic = [_BooksTW BooksTW_PrepareBoosSearchResultTable:_responseData];
                    
                    
                    if (_BookSearchDic != nil) {
                        if ([[_BookSearchDic valueForKey:BOOK_DIC_BOOK_NAME_KEY] count] == 0) {
                            
                            [conn cancel];
                            
                            // if ISBN, use findbook to research
                            if ([self IS_ISBNStr:_BookSearchKeyWord]) {
                                
                                [self Books_SendStatusNotificationWithValue:BOOK_SEARCH_NOT_FOUND_RETRY];
                                [self Books_FireRetryQuery];

                            } else {
                                
                                [self Books_SendStatusNotificationWithValue:BOOK_SEARCH_NOT_FOUND_NO_RETRY];
                                
                            }
                            
                        } else {
                            
                            BOOKS_SEARCH_LOG(@"NOTIFICATION  = %i", NotificationSent);
                            
                            [self Books_SendStatusNotificationWithValue:BOOK_SEARCH_RESULT_TABLE_DONE];
                            _State = BOOKS_INIT;

                        }
                    }
                } else {
                    
                    _State = BOOKS_INIT;
                    
                }
            }
            break;
            
        case BOOKS_SEARCH_KEY_WORDS_RETRY:
            {
                BOOKS_SEARCH_LOG(@"BOOKS_SEARCH_KEY_WORDS_RETRY");
                
                if ([_FindBooks FindBook_isBookExistInHtmlData:_responseData]) {
                    _BookSearchDic = [_FindBooks FindBook_PrepareBoosSearchResultTable:_responseData];
                    [self Books_SendStatusNotificationWithValue:BOOK_SEARCH_NOT_FOUND_RETRY_DONE];
                } else {
                    [self Books_SendStatusNotificationWithValue:BOOK_SEARCH_NOT_FOUND_NO_RETRY];
                }
                _State = BOOKS_INIT;

            }
            break;
            
        case BOOKS_GET_DETAILED_INFO:
            {
                BOOKS_SEARCH_LOG(@"BOOKS_GET_DETAILED_INFO");                
                _BookInfoObj.BookCoverHDURL = [_BooksTW BooksTW_ScrapingSingleBookCoverURLInDetailedPage:_responseData];
                _BookInfoObj.BookISBN = [_BooksTW BooksTW_ScrapingSingleBookISBNInDetailedPage:_responseData];
                _BookInfoObj.BookInfoStrongIntro = [_BooksTW BooksTW_ScrapingSingleBookStrongDescription:_responseData];
                _BookInfoObj.BookInfoIntro = [_BooksTW BooksTW_ScrapingSingleBookNormalDescription:_responseData];
                
                
                BOOKS_SEARCH_LOG(@"%@", [_BookInfoObj.BookCoverHDURL absoluteString]);
                BOOKS_SEARCH_LOG(@"%@", _BookInfoObj.BookISBN);
                BOOKS_SEARCH_LOG(@"%@", _BookInfoObj.BookInfoStrongIntro);

                if (NotificationSent == NO) {
                    [self Books_SendStatusNotificationWithValue:BOOK_DETAILED_BOOK_INFO_PAGE_DONE];
                    
                    _State = BOOKS_INIT;
                    NotificationSent = YES;
                }
            }
            break;
        default:
            break;
    }
}



#pragma mark - Connection firing


-(void) Books_FireRetryQuery
{
    if (_FindBooks == nil) {
        _FindBooks = [[SearchFindBook alloc] init];
    }
    
    NSURL *SearchingURL = [_FindBooks FindBook_PrepareURLByISBN:_BookSearchKeyWord];
    NSURLRequest *request=[NSURLRequest requestWithURL:SearchingURL];
    
    [self Books_ResetAll];
    BOOKS_SEARCH_LOG(@"Fire Connection !! \n%@", [request.URL absoluteString]);
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    _State = BOOKS_SEARCH_KEY_WORDS_RETRY;
}


-(NSURL*) PrepareSearchURLWithKeyword : (NSString*) KeyWord
{
    _BooksTW = [[SearchBooksTW alloc] init];
    _BookSearchKeyWord = [NSString stringWithString:KeyWord];
    
    return [_BooksTW BooksTW_PrepareSearchURLWithKeyWords:KeyWord];
}

-(void) Books_FireQueryWithKeyWords:(NSString *) KeyWord
{
    NSURL *SearchingURL = [self PrepareSearchURLWithKeyword:KeyWord];
    NSURLRequest *request=[NSURLRequest requestWithURL:SearchingURL];
    
    [self Books_ResetAll];
    BOOKS_SEARCH_LOG(@"Fire Connection !! \n%@", [request.URL absoluteString]);
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    _State = BOOKS_SEARCH_KEY_WORDS;
}

-(void) Books_FireQueryBookDetailedInfoWithURL:(NSURL *) BookInfoURL
{
    
    BOOKS_SEARCH_LOG(@"Fire Image Cover Connection!!! \n%@", [BookInfoURL absoluteString]);
    _BooksTW = [[SearchBooksTW alloc] init];
    NSURLRequest *request=[NSURLRequest requestWithURL:BookInfoURL];
    // Create url connection and fire request
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    _State = BOOKS_GET_DETAILED_INFO;

}

-(void) Books_RemoveConnection
{
    [conn cancel];
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
