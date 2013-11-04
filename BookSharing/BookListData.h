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

#define BOOK_LIST_DB_ENTITY                         @"Book" 
#define BOOK_HISTORY_DB_ENTITY                      @"BookHistory"

#define BOOKLIST_NOTIFY_ID                          @"BOOKLIST_NOTIFY_ID"
#define BOOKLIST_NOTIFY_KEY                         @"BOOKLIST_NOTIFY_KEY"
#define BOOKLIST_DATABASE_SYNC_START                @"BOOKLIST_DATABASE_SYNC_START"
#define BOOKLIST_DATABASE_SYNC_END                  @"BOOKLIST_DATABASE_SYNC_END"
#define BOOKLIST_DATABASE_SYNC_END_NO_MERGE         @"BOOKLIST_DATABASE_SYNC_END_NO_MERGE"
#define BOOKLIST_DATABASE_SYNC_ERROR                @"BOOKLIST_DATABASE_SYNC_ERROR"
#define BOOKLIST_DATABASE_GET_IMAGE_COVER_START     @"BOOKLIST_DATABASE_GET_IMAGE_COVER_START"
#define BOOKLIST_DATABASE_GET_IMAGE_COVER_END       @"BOOKLIST_DATABASE_GET_IMAGE_COVER_END"

@interface BookListData : NSObject {
    NSArray *CoreDataKey;
}

typedef enum {
    BOOKSLIST_SUCCESS = 0x00,
    BOOKSLIST_ERROR,
} BOOKLIST_STATUS;

typedef enum {
    BOOKLIST_STATE_IDLE = 0x00,
    BOOKLIST_STATE_DELETING,
    BOOKLIST_STATE_UPDATING,
    BOOKLIST_STATE_POSTING,
} BOOKLIST_SEARVER_SYNC_STATE;

typedef enum {
    BOOK_LIST = 0x00,
    BOOK_HISTORY,
} BOOKLIST_CORE_DATA_DB;

@property BOOKLIST_CORE_DATA_DB         BookListDatabase;
@property BOOKLIST_SEARVER_SYNC_STATE   ServerState;

@property (nonatomic, strong)   NSManagedObjectContext  *context;
@property (strong, nonatomic)   NSMutableData           *receivedData;
@property (strong)              NSMutableArray          *waitToGetImgCoverArray; //(BookInfo)
@property (strong)              NSMutableArray          *waitToDeleteBookArray; //(NSURL)

// Contructor
-(BookListData*) init;

// Utilities
-(NSArray*) Books_GetCoreDataKey;

// Core data 
//-(BOOKLIST_STATUS) Books_CoreDataSave : (NSArray*) Key andValue:(NSArray*) Value;
-(NSMutableArray*) Books_CoreDataFetchDataInDataBase:(BOOKLIST_CORE_DATA_DB) BookListDB;
-(NSMutableArray*) Books_CoreDataFetchNoDeletedData;
-(BOOKLIST_STATUS) Books_CoreDataDelete : (NSManagedObject*) Book;
-(BOOKLIST_STATUS) Books_CoreDataUpdateWithoObject : (NSManagedObject*) Book;
-(BOOKLIST_STATUS) Books_SaveBookInfoObj : (BookInfo*) BookInfoObj InDatabase : (BOOKLIST_CORE_DATA_DB) BookListDB;
-(BOOKLIST_STATUS) Books_CoreDataSetThisBookAsDeleted : (NSManagedObject *) Book;


// Search Book Name in Core Data with KeyWord
-(NSArray*) Books_CoreDataSearchWithBookName : (NSString*) BookNameString inDatabase:(BOOKLIST_CORE_DATA_DB) BookListDB;
-(NSArray*) Books_CoreDataSearchWithBookAuthor : (NSString*) SearchString inDatabase:(BOOKLIST_CORE_DATA_DB) BookListDB;
-(NSArray*) Books_CoreDataSearchWithBookISBN : (NSString*) SearchString inDatabase:(BOOKLIST_CORE_DATA_DB) BookListDB;
-(NSArray*) Books_CoreDataSearchWithBookID : (NSString*) BookIDStr inDatabase:(BOOKLIST_CORE_DATA_DB) BookListDB;


// Data connection with server
-(void) Books_GetServerDataAndMerge;
//-(BOOKLIST_STATUS) Books_MergeDataWithCoreData:(NSArray*) ServerData andForceSyncData:(NSArray*) ForceSyncData;
-(BOOKLIST_STATUS) Books_FirePOSTConnectionToServerWithBookInfo : (BookInfo *)BookInfoObj;
-(BOOKLIST_STATUS) Books_FireDELETEConnectionToServerWithBookInfo : (BookInfo *)BookInfoObj;
-(BOOKLIST_STATUS) Books_FirePUTConnectionToServerWithBookInfo : (BookInfo *)BookInfoObj;
-(NSDate*) Books_GetTheLastSyncTime;


@end
