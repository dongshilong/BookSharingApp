//
//  BookListData.h
//  BookSharing
//
//  Created by GIGIGUN on 13/7/3.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFJSONRequestOperation.h"
#import "BookInfo.h"

#define BOOKLIST_NOTIFY_ID              @"BOOKLIST_NOTIFY_ID"
#define BOOKLIST_NOTIFY_KEY             @"BOOKLIST_NOTIFY_KEY"
#define BOOKLIST_DATABASE_SYNC_START    @"BOOKLIST_DATABASE_SYNC_START"
#define BOOKLIST_DATABASE_SYNC_END      @"BOOKLIST_DATABASE_SYNC_END"
#define BOOKLIST_DATABASE_SYNC_ERROR    @"BOOKLIST_DATABASE_SYNC_ERROR"


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
-(BOOKLIST_STATUS) Books_SaveBookInfoObj : (BookInfo*) BookInfoObj;


// Search Book Name in Core Data with KeyWord
-(NSArray*) Books_CoreDataSearchWithBookName : (NSString*) BookNameString;
-(NSArray*) Books_CoreDataSearchWithBookAuthor : (NSString*) SearchString;
-(NSArray*) Books_CoreDataSearchWithBookISBN : (NSString*) SearchString;

// Data connection with server
-(BOOKLIST_STATUS) Books_MergeDataWithCoreData:(NSArray*) LocalData;
-(void) Books_FirePOSTConnectionToServerWithBookInfo : (BookInfo *)BookInfoObj;
-(void) Books_FireDELETEConnectionToServerWithBookInfo : (BookInfo *)BookInfoObj;
-(void) Books_FirePUTConnectionToServerWithBookInfo : (BookInfo *)BookInfoObj;
-(void) Books_GetServerDataAndMerge;
-(NSDate*) Books_GetTheLastSyncTime;


@end
