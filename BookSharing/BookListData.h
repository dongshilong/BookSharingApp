//
//  BookListData.h
//  BookSharing
//
//  Created by GIGIGUN on 13/7/3.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookInfo.h"


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

// Data sync 
-(void) Books_MergeDataWithCoreData:(NSArray*) Data;
-(void) Books_FirePOSTConnectionToServerWithBookIndo : (BookInfo *)BookInfoObj;
-(void) Books_FireDELETEConnectionToServerWithBookIndo : (BookInfo *)BookInfoObj;
-(void) Books_FirePUTConnectionToServerWithBookIndo : (BookInfo *)BookInfoObj;



@end
