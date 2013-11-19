//
//  BookInfo.m
//  BookSharing
//
//  Created by GIGIGUN on 13/7/9.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "BookInfo.h"

@implementation BookInfo

@synthesize BookInfoURL;
@synthesize BookSearverURL;
@synthesize BookName;
@synthesize BookISBN;
@synthesize BookAuthor;
@synthesize BookCoverURL;
@synthesize BookCoverHDURL;
@synthesize BookCoverImage;
@synthesize BookInfoIntro;
@synthesize BookInfoStrongIntro;
@synthesize BookInfoAuthorIntro;
@synthesize BookInfoCreateTime;
@synthesize BookInfoUpdateTime;
@synthesize BookInfoGUID;

-(BookInfo*) initWithCoreDataObj : (NSManagedObject*) bookCoreData
{
    if (self != nil) {
        
        //BookInfo *BookInfoObj = [[BookInfo alloc] init];
        BookName = [bookCoreData valueForKey:BOOKS_CORE_DATA_KEY_BOOK_NAME];
        BookAuthor = [bookCoreData valueForKey:BOOKS_CORE_DATA_KEY_BOOK_AUTHOR];
        BookInfoURL = [NSURL URLWithString:[bookCoreData valueForKey:BOOKS_CORE_DATA_KEY_BOOK_INFO_URL] ];
        BookCoverImage = [bookCoreData valueForKey:BOOKS_CORE_DATA_KEY_BOOK_COVER_IMG];
        BookInfoStrongIntro = [bookCoreData valueForKey:BOOKS_CORE_DATA_KEY_BOOK_INFO_STRONG_INTRO];
        BookInfoIntro = [bookCoreData valueForKey:BOOKS_CORE_DATA_KEY_BOOK_INFO_INTRO];
        BookISBN = [bookCoreData valueForKey:BOOKS_CORE_DATA_KEY_BOOK_ISBN];
        BookInfoGUID = [bookCoreData valueForKey:BOOKS_CORE_DATA_KEY_BOOK_ID];
        BookSearverURL = [NSURL URLWithString:[bookCoreData valueForKey:BOOKS_CORE_DATA_KEY_BOOK_SERVER_URL]];
        BookCoverHDURL = [NSURL URLWithString:[bookCoreData valueForKey:BOOKS_CORE_DATA_KEY_BOOK_COVER_URL_LARGE]];
    }
    
    return self;
}

-(BookInfo*) initWithJSONObj : (NSData*) bookJSONData
{
    
    if (self != nil) {
        
        //BookInfo *BookInfoObj = [[BookInfo alloc] init];
        BookName = [bookJSONData valueForKey:BOOKS_WEB_DB_KEY_BOOK_NAME];
        BookAuthor = [bookJSONData valueForKey:BOOKS_WEB_DB_KEY_BOOK_AUTHOR];
        //BookInfoURL = [bookJSONData valueForKey:BOOKS_CORE_DATA_KEY_BOOK_INFO_URL];
        //BookCoverImage = [bookJSONData valueForKey:BOOKS_CORE_DATA_KEY_BOOK_COVER_IMG];
        BookInfoStrongIntro = [bookJSONData valueForKey:BOOKS_WEB_DB_KEY_BOOK_STRONG_INTRO];
        BookInfoIntro = [bookJSONData valueForKey:BOOKS_WEB_DB_KEY_BOOK_INTRO];
        BookISBN = [bookJSONData valueForKey:BOOKS_WEB_DB_KEY_BOOK_ISBN];
        BookInfoGUID = [bookJSONData valueForKey:BOOKS_WEB_DB_KEY_BOOK_ID];
        BookSearverURL = [NSURL URLWithString:[bookJSONData valueForKey:BOOKS_WEB_DB_KEY_BOOK_SEARVER_URL]];
        BookCoverHDURL = [NSURL URLWithString:[bookJSONData valueForKey:BOOKS_WEB_DB_KEY_BOOK_IMG_URL]];
        BookInfoURL = [NSURL URLWithString:[bookJSONData valueForKey:BOOKS_WEB_DB_KEY_BOOK_INFO_URL]]; //[CASPER] 2013.11.15:Add new attr on server

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-d H:m:s"];
        NSDate *CreateTimeDate = [dateFormatter dateFromString:[bookJSONData valueForKey:BOOKS_WEB_DB_KEY_BOOK_CREATE_T]];
        NSDate *UpdateTimeDate = [dateFormatter dateFromString:[bookJSONData valueForKey:BOOKS_WEB_DB_KEY_BOOK_UPDATE_T]];


        BookInfoCreateTime = CreateTimeDate;
        BookInfoUpdateTime = UpdateTimeDate;
        
    }
    
    return self;

}

-(SearchEngine) WhereThisBookFrom
{
    NSRange Range;

    if ([[self.BookInfoURL absoluteString] isEqualToString:BOOKS_CORE_DATA_DEFAULT_VALUE]) {
        return SEARCH_ENGINE_BOOKS_TW;
    }
    
    Range = [[self.BookInfoURL absoluteString] rangeOfString:@"books.com"];
    if (Range.length != 0) {
        
        return SEARCH_ENGINE_BOOKS_TW;
        
    } else {
        
        return SEARCH_ENGINE_FIND_BOOK;
    }
}


@end
