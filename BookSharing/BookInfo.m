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

-(BookInfo*) initWithCoreDataObj : (NSManagedObject*) bookCoreData
{
    if (self != nil) {
        //BookInfo *BookInfoObj = [[BookInfo alloc] init];
        BookName = [bookCoreData valueForKey:BOOK_DIC_BOOK_NAME_KEY];
        BookAuthor = [bookCoreData valueForKey:BOOK_DIC_BOOK_AUTHOR_KEY];
        BookInfoURL = [bookCoreData valueForKey:BOOK_DIC_BOOK_URL_KEY];
    }
    
    return self;
}

@end
