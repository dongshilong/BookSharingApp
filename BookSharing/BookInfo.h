//
//  BookInfo.h
//  BookSharing
//
//  Created by GIGIGUN on 13/7/9.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BOOK_DIC_BOOK_NAME_KEY                      @"bookName"
#define BOOK_DIC_BOOK_AUTHOR_KEY                    @"bookAuthor"
#define BOOK_DIC_BOOK_URL_KEY                       @"bookInfoURL"
#define BOOK_DIC_BOOK_COVER_URL_KEY                 @"bookCoverURL"

@interface BookInfo : NSObject
@property (nonatomic, strong) NSURL         *BookInfoURL;
@property (nonatomic, strong) NSString      *BookName;
@property (nonatomic, strong) NSString      *BookISBN;
@property (nonatomic, strong) NSString      *BookAuthor;
@property (nonatomic, strong) NSURL         *BookCoverURL;      //For small image
@property (nonatomic, strong) NSURL         *BookCoverHDURL;    //For large image
@property (nonatomic, strong) NSData        *BookCoverImage;
@property (nonatomic, strong) NSString      *BookInfoIntro;
@property (nonatomic, strong) NSString      *BookInfoStrongIntro;
@property (nonatomic, strong) NSString      *BookInfoAuthorIntro;
@property (nonatomic, strong) NSString      *BookType;
@property (nonatomic, strong) NSDate        *BookInfoCreateTime;
@property (nonatomic, strong) NSDate        *BookInfoUpdateTime;

-(BookInfo*) initWithCoreDataObj : (NSManagedObject*) bookCoreData;

@end
