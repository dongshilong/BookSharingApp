//
//  BookListData.h
//  BookSharing
//
//  Created by GIGIGUN on 13/7/3.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookInfo.h"

#pragma mark - Core Data Key Define
#define BOOKS_CORE_DATA_KEY_BOOK_NAME       @"bookName"
#define BOOKS_CORE_DATA_KEY_BOOK_AUTHOR     @"bookAuthor"
#define BOOKS_CORE_DATA_KEY_BOOK_ISBN       @"bookISBN"
#define BOOKS_CORE_DATA_KEY_BOOK_COVER_IMG  @"bookCoverImage"
#define BOOKS_CORE_DATA_KEY_BOOK_INFO_URL   @"bookInfoURL"
#define BOOKS_CORE_DATA_KEY_BOOK_CREATE_T   @"bookCreateTime"
#define BOOKS_CORE_DATA_KEY_BOOK_UPDATE_T   @"bookUpdateTime"

#pragma mark - Web database Key Define
#define BOOKS_WEB_DB_KEY_BOOK_NAME          @"name"
#define BOOKS_WEB_DB_KEY_BOOK_AUTHOR        @"author"
#define BOOKS_WEB_DB_KEY_BOOK_ISBN          @"isbn"
#define BOOKS_WEB_DB_KEY_BOOK_IMG_URL       @"imageurl"
#define BOOKS_WEB_DB_KEY_BOOK_CREATE_T      @"createdTime"
#define BOOKS_WEB_DB_KEY_BOOK_UPDATE_T      @"updateTime"
#define BOOKS_WEB_DB_KEY_BOOK_INTRO         @"introduction"
#define BOOKS_WEB_DB_KEY_BOOK_TAG           @"tag"
#define BOOKS_WEB_DB_KEY_BOOK_TYPE          @"booktype"


@interface BookListData : NSObject {
    NSArray *CoreDataKey;
}




typedef enum {
    BOOKSLIST_SUCCESS = 0x00,
    BOOKSLIST_ERROR,
} BOOKLIST_STATUS;

@property (nonatomic, strong) NSManagedObjectContext * context;
@property (strong, nonatomic) NSMutableData *receivedData;

// Contructor
-(BookListData*) init;

// Utilities
-(NSArray*) Books_GetCoreDataKey;

// Core data 
-(BOOKLIST_STATUS) Books_CoreDataSave : (NSArray*) Key andValue:(NSArray*) Value;
-(NSMutableArray*) Books_CoreDataFetch;
-(BOOKLIST_STATUS) Books_CoreDataDelete : (NSManagedObject*) Book;
-(BOOKLIST_STATUS) Books_CoreDataUpdateWithoObject : (NSManagedObject*) Book;


// Search Book Name in Core Data with KeyWord
-(NSArray*) Books_CoreDataSearchWithBookName : (NSString*) BookNameString;
-(NSArray*) Books_CoreDataSearchWithBookAuthor : (NSString*) SearchString;

// Data sync 
-(void) Books_MergeDataWithCoreData:(NSArray*) Data;
-(void) Books_FirePOSTConnectionToServerWithBookIndo : (BookInfo *)BookInfoObj;



@end
