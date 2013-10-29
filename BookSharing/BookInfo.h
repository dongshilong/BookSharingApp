//
//  BookInfo.h
//  BookSharing
//
//  Created by GIGIGUN on 13/7/9.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Core Data Key Define
#define BOOKS_CORE_DATA_KEY_BOOK_NAME               @"bookName"
#define BOOKS_CORE_DATA_KEY_BOOK_AUTHOR             @"bookAuthor"
#define BOOKS_CORE_DATA_KEY_BOOK_ISBN               @"bookISBN"
#define BOOKS_CORE_DATA_KEY_BOOK_COVER_URL_SMALL    @"bookCoverUrlSmall"
#define BOOKS_CORE_DATA_KEY_BOOK_COVER_URL_LARGE    @"bookCoverUrlLarge"
#define BOOKS_CORE_DATA_KEY_BOOK_COVER_IMG          @"bookCoverImage"
#define BOOKS_CORE_DATA_KEY_BOOK_INFO_URL           @"bookInfoURL"
#define BOOKS_CORE_DATA_KEY_BOOK_INFO_STRONG_INTRO  @"bookStrongIntro"
#define BOOKS_CORE_DATA_KEY_BOOK_INFO_INTRO         @"bookIntro"
#define BOOKS_CORE_DATA_KEY_BOOK_CREATE_T           @"bookCreateTime"
#define BOOKS_CORE_DATA_KEY_BOOK_UPDATE_T           @"bookUpdateTime"
#define BOOKS_CORE_DATA_KEY_BOOK_ID                 @"bookGuid"
#define BOOKS_CORE_DATA_KEY_BOOK_SERVER_URL         @"bookServerURL"
#define BOOKS_CORE_DATA_KEY_BOOK_IMG_URL            @"bookCoverUrlLarge"
#define BOOKS_CORE_DATA_KEY_BOOK_DELETED            @"deleted"




#pragma mark - Web database Key Define
#define BOOKS_WEB_DB_KEY_BOOK_NAME                  @"name"
#define BOOKS_WEB_DB_KEY_BOOK_AUTHOR                @"author"
#define BOOKS_WEB_DB_KEY_BOOK_ISBN                  @"isbn"
#define BOOKS_WEB_DB_KEY_BOOK_IMG_URL               @"imageurl"
#define BOOKS_WEB_DB_KEY_BOOK_CREATE_T              @"createdTime"
#define BOOKS_WEB_DB_KEY_BOOK_UPDATE_T              @"updateTime"
#define BOOKS_WEB_DB_KEY_BOOK_INTRO                 @"introduction"
#define BOOKS_WEB_DB_KEY_BOOK_STRONG_INTRO          @"focusIntro"
#define BOOKS_WEB_DB_KEY_BOOK_TAG                   @"tag"
#define BOOKS_WEB_DB_KEY_BOOK_TYPE                  @"booktype"
#define BOOKS_WEB_DB_KEY_BOOK_ID                    @"bookid"
#define BOOKS_WEB_DB_KEY_BOOK_SEARVER_URL           @"url"



#define BOOK_DIC_BOOK_NAME_KEY                      BOOKS_CORE_DATA_KEY_BOOK_NAME
#define BOOK_DIC_BOOK_AUTHOR_KEY                    BOOKS_CORE_DATA_KEY_BOOK_AUTHOR
#define BOOK_DIC_BOOK_URL_KEY                       BOOKS_CORE_DATA_KEY_BOOK_INFO_URL
#define BOOK_DIC_BOOK_COVER_URL_KEY                 @"bookCoverURL"

#pragma mark - Core Data Value default
#define BOOKS_CORE_DATA_DEFAULT_VALUE               @"NaN"


@interface BookInfo : NSObject
@property (nonatomic, strong) NSURL         *BookInfoURL;
@property (nonatomic, strong) NSURL         *BookSearverURL;
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
@property (nonatomic, strong) NSString      *BookInfoGUID;

-(BookInfo*) initWithCoreDataObj : (NSManagedObject*) bookCoreData;
-(BookInfo*) initWithJSONObj : (NSArray*) bookJSONData;


@end
