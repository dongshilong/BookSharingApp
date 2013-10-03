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
        BookInfoURL = [bookCoreData valueForKey:BOOKS_CORE_DATA_KEY_BOOK_INFO_URL];
        BookCoverImage = [bookCoreData valueForKey:BOOKS_CORE_DATA_KEY_BOOK_COVER_IMG];
        BookInfoStrongIntro = [bookCoreData valueForKey:BOOKS_CORE_DATA_KEY_BOOK_INFO_STRONG_INTRO];
        BookISBN = [bookCoreData valueForKey:BOOKS_CORE_DATA_KEY_BOOK_ISBN];
        BookInfoGUID = [bookCoreData valueForKey:BOOKS_CORE_DATA_KEY_BOOK_ID];
    }
    
    return self;
}

@end
