//
//  BooksHtml.h
//  ShareBook
//
//  Created by GIGIGUN on 13/9/11.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFHpple.h"
#import "BookInfo.h"
#import "SearchBooksTW.h"

#define BOOK_INFO_NOTIFY_ID                         @"BookInfoNotify"
#define BOOK_SEARCH_NOTIFICATION_KEY                @"Status"

#define ISBN_MIN_LENGTH 10
#define ISBN_MAX_LENGTH 13

#define BOOK_SEARCH_RESULT_TABLE_DONE               @"BOOK_SEARCH_RESULT_TABLE_DONE"


@interface BooksHtml : NSObject<NSURLConnectionDelegate> {
    NSMutableData       *_responseData;
    NSURLConnection     *conn;
    BOOL                NotificationSent;
}

typedef enum {
    BOOKS_INIT = 0x00,
    BOOKS_SEARCH_KEY_WORDS,
} BOOKS_HTML_STATE;


@property BOOKS_HTML_STATE              State;
@property (nonatomic, strong) BookInfo *BookInfoObj;
@property (nonatomic, strong) SearchBooksTW *BooksTW;
@property (nonatomic, strong) NSDictionary *BookSearchDic;


-(BooksHtml*) init;
-(void) Books_FireQueryWithKeyWords:(NSString *) KeyWord;

-(NSArray*) Books_ExtractToBookNameArrayWithDictionary : (NSDictionary *) SearchBooksDic;
-(NSArray*) Books_ExtractToBookAuthorArrayWithDictionary : (NSDictionary *) SearchBooksDic;
-(NSArray*) Books_ExtractToBookDetailedUrlArrayWithDictionary : (NSDictionary *) SearchBooksDic;
-(NSArray*) Books_ExtractToBookCoverUrlArrayWithDictionary : (NSDictionary *) SearchBooksDic;
-(BookInfo *) Books_ExtractToSingleBookInfoObjWithDictionary : (NSDictionary *) SearchBooksDic;

@end
