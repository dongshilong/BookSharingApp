//
//  BookListData.m
//  BookSharing
//
//  Created by GIGIGUN on 13/7/3.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//
//  =====================================================
//  20130708 Casper add bookGuid attribute
//  20130708 Casper add bookCoverImage attribute
//  20130709 Casper add bookInfoURL attribute
//  20130709 Casper add bookCreateTime attribute
//  20130822 Casper add bookCoverImageUrlSmall and bookCoverImageUrlLarge
//
//  =====================================================
#import "BookListData.h"
#import "BookListViewController.h"
#import "NSMutableArray+Queue.h"

@implementation BookListData
//@synthesize fetchedResultsController;

-(BookListData*) init{
    self = [super init];
    
    if ( self ) {
        CoreDataKey = [[NSArray alloc] initWithObjects:
                       BOOKS_CORE_DATA_KEY_BOOK_NAME,
                       BOOKS_CORE_DATA_KEY_BOOK_ISBN,
                       BOOKS_CORE_DATA_KEY_BOOK_AUTHOR,
                       BOOKS_CORE_DATA_KEY_BOOK_ID,
                       BOOKS_CORE_DATA_KEY_BOOK_COVER_IMG,
                       BOOKS_CORE_DATA_KEY_BOOK_INFO_URL,
                       BOOKS_CORE_DATA_KEY_BOOK_CREATE_T,
                       BOOKS_CORE_DATA_KEY_BOOK_UPDATE_T,
                       @"bookCoverUrlSmall",
                       BOOKS_CORE_DATA_KEY_BOOK_IMG_URL,
                       BOOKS_CORE_DATA_KEY_BOOK_INFO_INTRO,
                       BOOKS_CORE_DATA_KEY_BOOK_INFO_STRONG_INTRO,
                       @"bookAuthorIntro",
                       BOOKS_CORE_DATA_KEY_BOOK_SERVER_URL,
                       BOOKS_CORE_DATA_KEY_BOOK_DELETED,
                       nil];
        
        _waitToGetImgCoverArray = [[NSMutableArray alloc] init];
        AppDelegate *theAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        _context = [theAppDelegate managedObjectContext];

    }
    
    return self;
}

-(void) Books_SendStatusNotificationWithValue: (NSString *) Value
{
    NSArray *userInfoKeys = [NSArray arrayWithObjects:BOOKLIST_NOTIFY_KEY, nil];
    NSArray *userInfoValues = [NSArray arrayWithObjects:Value, nil];
    
    BOOKS_SEARCH_LOG(@"Send Notification with value = %@", Value);
    
    NSNotification *notification = [NSNotification notificationWithName:BOOKLIST_NOTIFY_ID
                                                                 object:nil
                                                               userInfo:[NSDictionary dictionaryWithObjects:userInfoValues forKeys:userInfoKeys]];
    
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    
}



#pragma mark - Core data for Book List
-(NSArray*) Books_GetCoreDataKey
{
    return CoreDataKey;
}

// Set data as NaN if nil
-(BookInfo*) Books_CheckDataNilForBookInfo : (BookInfo*) BookInfoObj
{
    if (BookInfoObj.BookName == nil) {
        BookInfoObj.BookName = BOOKS_CORE_DATA_DEFAULT_VALUE;
    }
    
    if (BookInfoObj.BookAuthor == nil) {
        BookInfoObj.BookAuthor = BOOKS_CORE_DATA_DEFAULT_VALUE;
    }
    
    if (BookInfoObj.BookISBN == nil) {
        BookInfoObj.BookISBN = BOOKS_CORE_DATA_DEFAULT_VALUE;
    }
    
    if (BookInfoObj.BookInfoURL == nil) {
        BookInfoObj.BookInfoURL = [NSURL URLWithString:BOOKS_CORE_DATA_DEFAULT_VALUE];
    }
    
    if (BookInfoObj.BookCoverURL == nil) {
        BookInfoObj.BookCoverURL = [NSURL URLWithString:BOOKS_CORE_DATA_DEFAULT_VALUE];
    }
    
    if (BookInfoObj.BookCoverHDURL == nil) {
        BookInfoObj.BookCoverHDURL = [NSURL URLWithString:BOOKS_CORE_DATA_DEFAULT_VALUE];
    }
    
    if (BookInfoObj.BookCoverImage == nil) {
        NSString* str = BOOKS_CORE_DATA_DEFAULT_VALUE;
        BookInfoObj.BookCoverImage = [str dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    if (BookInfoObj.BookInfoIntro == nil) {
        BookInfoObj.BookInfoIntro = BOOKS_CORE_DATA_DEFAULT_VALUE;
    }
    
    if (BookInfoObj.BookInfoStrongIntro == nil) {
        BookInfoObj.BookInfoStrongIntro = BOOKS_CORE_DATA_DEFAULT_VALUE;
    }
    
    if (BookInfoObj.BookInfoAuthorIntro == nil) {
        BookInfoObj.BookInfoAuthorIntro = BOOKS_CORE_DATA_DEFAULT_VALUE;
    }
    
    if (BookInfoObj.BookSearverURL == nil) {
        BookInfoObj.BookSearverURL = [NSURL URLWithString:BOOKS_CORE_DATA_DEFAULT_VALUE];
    }
    
    
    return BookInfoObj;
}

// 將 BookInfo 的 object 存入 Core Data
-(BOOKLIST_STATUS) Books_SaveBookInfoObj : (BookInfo*) BookInfoObj
{
    if (BookInfoObj.BookInfoCreateTime == nil) {
        
        // For New Data
        NSUUID *Guid = [[NSUUID alloc] init];
        NSDate *date = [NSDate date];
        
        BookInfoObj.BookInfoCreateTime = date;
        BookInfoObj.BookInfoUpdateTime = date;
        BookInfoObj.BookInfoGUID = [Guid UUIDString];
        
    }
    
    BookInfoObj = [self Books_CheckDataNilForBookInfo:BookInfoObj];
    NSString *DeletedString = BOOKS_CORE_DATA_NOT_DELETED;
    
    NSArray *CoreDataValue = [NSArray arrayWithObjects:
                              BookInfoObj.BookName,
                              BookInfoObj.BookISBN,
                              BookInfoObj.BookAuthor,
                              BookInfoObj.BookInfoGUID,
                              BookInfoObj.BookCoverImage,
                              [BookInfoObj.BookInfoURL absoluteString],
                              BookInfoObj.BookInfoCreateTime,
                              BookInfoObj.BookInfoUpdateTime,
                              [BookInfoObj.BookCoverURL absoluteString],
                              [BookInfoObj.BookCoverHDURL absoluteString],
                              BookInfoObj.BookInfoIntro,
                              BookInfoObj.BookInfoStrongIntro,
                              BookInfoObj.BookInfoAuthorIntro,
                              [BookInfoObj.BookSearverURL absoluteString],
                              DeletedString,
                              nil];
    
    return [self Books_CoreDataSave:[self Books_GetCoreDataKey] andValue:CoreDataValue];
    
}


-(BOOKLIST_STATUS) Books_CoreDataSave:(NSArray*) Key andValue:(NSArray*) Value
{
    /*
    for (int i = 0; i < [Value count]; i++) {
        NSLog(@"%i - %i - %@", i, [Value count], [Value objectAtIndex:i]);
    }
    */
    
    if ([Value count] != [Key count]) {
        NSLog(@"ERROR in ([Value count] != [Key count]) %i - %i", [Value count], [Key count]);
        return BOOKSLIST_ERROR;
    }
    
    NSManagedObject *newBook = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:_context];
    for (NSInteger i = 0; i < [Key count]; i++) {
        // fill out the book value
        [newBook setValue:[Value objectAtIndex:i] forKey:[Key objectAtIndex:i]];
    }
    
    NSError *error = nil;
    if (![_context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        return BOOKSLIST_ERROR;
    }
    return BOOKSLIST_SUCCESS;
}

// 刪除 Core Data 中特定的資料
-(BOOKLIST_STATUS) Books_CoreDataDelete:(NSManagedObject*) Book
{
    
    [_context deleteObject:Book];
    
    NSError *error = nil;
    
    if (![_context save:&error]) {
        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        return BOOKSLIST_ERROR;
    }    

    return BOOKSLIST_SUCCESS;
}

// UPDATE Core Data 中特定的資料
-(BOOKLIST_STATUS) Books_CoreDataUpdateWithoObject : (NSManagedObject*) Book
{
    NSError *error = nil;
    // Save the object to persistent store
    if (![_context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    return BOOKSLIST_SUCCESS;

}

// 取出 Core Data 中所有 Book 的資料，Array 中存的是 NSManagedObject
-(NSMutableArray*) Books_CoreDataFetch
{
    NSMutableArray *BookList = [[NSMutableArray alloc] init];
//    NSLog(@"Books_CoreDataFetch");
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Book"];
    BookList = [[_context executeFetchRequest:fetchRequest error:nil] mutableCopy];
  
    return BookList;
}


// 取出 Core Data 中所有 Book 的資料，Array 中存的是 NSManagedObject
// 新增判斷是否為 deleted
-(NSMutableArray*) Books_CoreDataFetchNoDeletedData
{
    NSMutableArray *BookList = [[NSMutableArray alloc] init];
    //    NSLog(@"Books_CoreDataFetch");
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Book"];
    BookList = [[_context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    for (int i = 0; i < [BookList count]; i++) {
        
        NSManagedObject *tempBook = [BookList objectAtIndex:i];

        if ([[tempBook valueForKey:BOOKS_CORE_DATA_KEY_BOOK_DELETED] isEqualToString:BOOKS_CORE_DATA_IS_DELETED]) {
            
            [BookList removeObjectAtIndex:i];
            
        }
        else {
            
            NSLog(@"PUT INTO BOOKLIST = %@", [tempBook valueForKey:BOOKS_CORE_DATA_KEY_BOOK_NAME]);
            
        }
        
    }
    
    return BookList;
}

-(BOOKLIST_STATUS) Books_CoreDataSetThisBookAsDeleted : (NSManagedObject *) Book
{
    
    [Book setValue:BOOKS_CORE_DATA_IS_DELETED forKey:BOOKS_CORE_DATA_KEY_BOOK_DELETED];
    return [self Books_CoreDataUpdateWithoObject:Book];

}

// 在 Book 中搜尋 Book Server URL
-(NSArray*) Books_CoreDataSearchWithBookSearverURL : (NSURL*) BookSearverURL
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
	// NSSortDescriptor tells defines how to sort the fetched results
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:BOOKS_CORE_DATA_KEY_BOOK_SERVER_URL ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
    // fetchRequest needs to know what entity to fetch
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:_context];
	[fetchRequest setEntity:entity];
    
    NSFetchedResultsController  *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_context sectionNameKeyPath:nil cacheName:@"Root"];
    
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"bookServerURL contains[cd] %@", [BookSearverURL absoluteString]];
    
    [fetchedResultsController.fetchRequest setPredicate:predicate];
    
	NSError *error = nil;
	if (![fetchedResultsController performFetch:&error])
	{
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    return fetchedResultsController.fetchedObjects;

}

// 在 Book 中搜尋 Book Name
-(NSArray*) Books_CoreDataSearchWithBookName : (NSString*) BookNameString
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
	// NSSortDescriptor tells defines how to sort the fetched results
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:BOOKS_CORE_DATA_KEY_BOOK_NAME ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
    // fetchRequest needs to know what entity to fetch
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:_context];
	[fetchRequest setEntity:entity];
    
    NSFetchedResultsController  *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_context sectionNameKeyPath:nil cacheName:@"Root"];
    
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"bookName contains[cd] %@", BookNameString];
    
    [fetchedResultsController.fetchRequest setPredicate:predicate];

	NSError *error = nil;
	if (![fetchedResultsController performFetch:&error])
	{
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}

    return fetchedResultsController.fetchedObjects;
}



-(NSArray*) Books_CoreDataSearchWithBookAuthor : (NSString*) SearchString
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
	// NSSortDescriptor tells defines how to sort the fetched results
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:BOOKS_CORE_DATA_KEY_BOOK_AUTHOR ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
    // fetchRequest needs to know what entity to fetch
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:_context];
	[fetchRequest setEntity:entity];
    
    NSFetchedResultsController  *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_context sectionNameKeyPath:nil cacheName:@"Root"];
    
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"bookAuthor contains[cd] %@", SearchString];
    
    [fetchedResultsController.fetchRequest setPredicate:predicate];
    
	NSError *error = nil;
	if (![fetchedResultsController performFetch:&error])
	{
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    return fetchedResultsController.fetchedObjects;
}


-(NSArray*) Books_CoreDataSearchWithBookISBN : (NSString*) SearchString
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
	// NSSortDescriptor tells defines how to sort the fetched results
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:BOOKS_CORE_DATA_KEY_BOOK_ISBN ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
    // fetchRequest needs to know what entity to fetch
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:_context];
	[fetchRequest setEntity:entity];
    
    NSFetchedResultsController  *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_context sectionNameKeyPath:nil cacheName:@"Root"];
    
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"bookISBN contains[cd] %@", SearchString];
    
    [fetchedResultsController.fetchRequest setPredicate:predicate];
    
	NSError *error = nil;
	if (![fetchedResultsController performFetch:&error])
	{
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    return fetchedResultsController.fetchedObjects;
}


-(NSArray*) Books_CoreDataSearchWithBookID : (NSString*) BookIDStr
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
	// NSSortDescriptor tells defines how to sort the fetched results
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:BOOKS_CORE_DATA_KEY_BOOK_ID ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
    // fetchRequest needs to know what entity to fetch
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:_context];
	[fetchRequest setEntity:entity];
    
    NSFetchedResultsController  *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_context sectionNameKeyPath:nil cacheName:@"Root"];
    
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"bookGuid contains[cd] %@", BookIDStr];
    
    [fetchedResultsController.fetchRequest setPredicate:predicate];
    
	NSError *error = nil;
	if (![fetchedResultsController performFetch:&error])
	{
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    return fetchedResultsController.fetchedObjects;
}


#pragma mark - Sync Data

// Save update time for server
-(BOOKLIST_STATUS) Books_SaveCurrentAsLastSyncTime
{

    NSManagedObject *UpdateTimeObj;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SyncTime"];
    NSMutableArray *LastTimeUpdate = [[_context executeFetchRequest:fetchRequest error:nil] mutableCopy];

    if ([LastTimeUpdate count] != 0) {
        UpdateTimeObj = [[_context executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    } else {
        UpdateTimeObj = [NSEntityDescription insertNewObjectForEntityForName:@"SyncTime" inManagedObjectContext:_context];
    }

    NSDate *UpdateTime = [NSDate date];
    NSLog(@"Save Update Time = %@", UpdateTime);
    [UpdateTimeObj setValue:UpdateTime forKey:@"lastUpdateTime"];
    
    NSError *error = nil;
    if (![_context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        return BOOKSLIST_ERROR;
    }
    return BOOKSLIST_SUCCESS;
}

// Get sync time for server
-(NSDate*) Books_GetTheLastSyncTime
{
    //    NSLog(@"Books_CoreDataFetch");
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SyncTime"];
    NSManagedObject *UpdateTimeObj = [[_context executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    NSDate *UpdateTime = [UpdateTimeObj valueForKey:@"lastUpdateTime"];
    NSLog(@"Get update time %@", UpdateTime);
    
    return UpdateTime;

}

-(void) Books_GetServerDataAndMerge
{
    
    // Sync Start
    
    [self Books_SendStatusNotificationWithValue:BOOKLIST_DATABASE_SYNC_START];
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://booksharingapps.herokuapp.com/bookinfos.json"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                         {
                                             // Read the data from the returned JSON object
                                             NSArray *BooksArray = [NSArray arrayWithArray:JSON];
                                             
                                             if ([BooksArray count] != 0) {
                                                 
                                                 [self Books_MergeDataWithCoreData:BooksArray];
                                                 
                                          } else {
                                                 
                                                 NSLog(@"TEST VIEW = READ SEARVER - NODATA");
                                                 
                                             }
                                             
                                         }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response,NSError *error, id JSON)
                                         {

                                             NSLog(@"NSError: %@",error.localizedDescription);
                                             
                                         }];
    [operation start];
    
}

// 利用 BookInfo 中的 IMG_URL 來拿網路上的 IMG
-(void) Books_GetImageCoverAndUpdateIntoCoreData
{
    [self Books_SendStatusNotificationWithValue:BOOKLIST_DATABASE_GET_IMAGE_COVER_START];

    if ((_waitToGetImgCoverArray == nil) || [_waitToGetImgCoverArray count] == 0) {
        // NOTHING
    } else {
        
        do {
            
            BookInfo *TempBookInfoObj = [_waitToGetImgCoverArray dequeue];

            NSArray *BookDBArray = [self Books_CoreDataSearchWithBookID:TempBookInfoObj.BookInfoGUID];
            
            if ([BookDBArray count] != 0) {
                
                NSManagedObject *BookManagedObj = [BookDBArray objectAtIndex:0];
                NSURL *BookImgURL = [NSURL URLWithString:[BookManagedObj valueForKey:BOOKS_CORE_DATA_KEY_BOOK_IMG_URL]];
                NSData *BookImgCover = [NSData dataWithContentsOfURL:BookImgURL];
                [BookManagedObj setValue:BookImgCover forKey:BOOKS_CORE_DATA_KEY_BOOK_COVER_IMG];
                
                [self Books_CoreDataUpdateWithoObject:BookManagedObj];
            }

            
        } while ([_waitToGetImgCoverArray count] != 0);
        
    }
    
    [self Books_SendStatusNotificationWithValue:BOOKLIST_DATABASE_GET_IMAGE_COVER_END];

    
}


// To Merge data between Server and Local Data
// Force Sync Data 是有缺 SERVER URL Attr 的資料
-(BOOKLIST_STATUS) Books_MergeDataWithCoreData:(NSArray*) Data
{
    // 1. Check ID
    // 2. Check Update Time
    // 3. Check url
    
    int countForMerge = 0;
    if ([Data count] != 0) {
        
        // reverse the Data to ensure the latest object be handled first
        [Data reverseObjectEnumerator];
        for (int Count = 0; Count < [Data count]; Count++) {
            
            //NSLog(@"%@",[[Data objectAtIndex:Count] valueForKey:BOOKS_WEB_DB_KEY_BOOK_ID]);
            
            NSString *GuidStr = [[Data objectAtIndex:Count] valueForKey:BOOKS_WEB_DB_KEY_BOOK_ID];
            if (GuidStr != nil) {
                NSArray *IDFound =[NSArray arrayWithArray:[self Books_CoreDataSearchWithBookID:GuidStr]];
                
                if([IDFound count] == 0) {
                    
                    countForMerge++;
                    BookInfo *BookInfoObj = [[BookInfo alloc] initWithJSONObj:[Data objectAtIndex:Count]];
                    [self Books_SaveBookInfoObj:BookInfoObj];
                    
                    // Add to queue, and list view will filled it out when loading
                    [_waitToGetImgCoverArray enqueue:BookInfoObj];
                    
                } else {
                    NSLog(@"ID FOUND");

                    if ([IDFound count] == 1) {
                        // Check url Area
                        NSManagedObject *TempBookObj = [IDFound objectAtIndex:0];
                        if ([[TempBookObj valueForKey:BOOKS_CORE_DATA_KEY_BOOK_SERVER_URL] isEqualToString:BOOKS_CORE_DATA_DEFAULT_VALUE]) {
                            

                            [TempBookObj setValue:[[Data objectAtIndex:Count] valueForKey:BOOKS_WEB_DB_KEY_BOOK_SEARVER_URL] forKey:BOOKS_CORE_DATA_KEY_BOOK_SERVER_URL];
                            NSLog(@"New book update url = %@", [TempBookObj valueForKey:BOOKS_CORE_DATA_KEY_BOOK_SERVER_URL]);
                            [self Books_CoreDataUpdateWithoObject:TempBookObj];
                            
                        }
                        
                    }
                    
                    //NSLog(@"ID FOUND - DO NOTHING");
                    
                }
                
            } else {
                
                NSLog(@"GuidStr == nil");
                
            }
        }
    }
    
    NSLog(@"Total %i books save into DB", countForMerge);
    
    if (BOOKSLIST_SUCCESS == [self Books_SaveCurrentAsLastSyncTime]) {
        
        [self Books_SendStatusNotificationWithValue:BOOKLIST_DATABASE_SYNC_END];
        
        // If the data comes from server, the book cover image is nil.
        // Then the following method would get image cover and update core data
        [self Books_GetImageCoverAndUpdateIntoCoreData];

        
    } else {
        
        [self Books_SendStatusNotificationWithValue:BOOKLIST_DATABASE_SYNC_ERROR];

    }

    
    return BOOKSLIST_SUCCESS;
}

-(void) Books_FirePOSTConnectionToServerWithBookInfo : (BookInfo *)BookInfoObj
{
    // Encode the Image with Base64
    // NSData *imageData = UIImagePNGRepresentation(_imageView.image);
    // NSString *imageDataEncodedeString = [imageData base64EncodedString];
    
    // Send Request to Server
    // Create the request with url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://booksharingapps.herokuapp.com/bookinfos.json"]];
    
    // Add header value and set http for POST requeest as JSON
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    NSLog(@"Htttp Method %@ ", request.HTTPMethod);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-d H:m:s"];
    NSLog(@"POST Date = %@", [formatter stringFromDate:BookInfoObj.BookInfoCreateTime]);
    
    NSMutableDictionary *newAccount = [[NSMutableDictionary alloc]init];
    [newAccount setObject:BookInfoObj.BookName forKey:BOOKS_WEB_DB_KEY_BOOK_NAME];
    [newAccount setObject:BookInfoObj.BookAuthor forKey:BOOKS_WEB_DB_KEY_BOOK_AUTHOR];
    [newAccount setObject:BookInfoObj.BookISBN forKey:BOOKS_WEB_DB_KEY_BOOK_ISBN];
    [newAccount setObject:[BookInfoObj.BookCoverHDURL absoluteString] forKey:BOOKS_WEB_DB_KEY_BOOK_IMG_URL];
    [newAccount setObject:[formatter stringFromDate:BookInfoObj.BookInfoCreateTime] forKey:BOOKS_WEB_DB_KEY_BOOK_CREATE_T];
    [newAccount setObject:[formatter stringFromDate:BookInfoObj.BookInfoUpdateTime] forKey:BOOKS_WEB_DB_KEY_BOOK_UPDATE_T];
    [newAccount setObject:BookInfoObj.BookInfoStrongIntro forKey:BOOKS_WEB_DB_KEY_BOOK_STRONG_INTRO];
    [newAccount setObject:BookInfoObj.BookInfoIntro forKey:BOOKS_WEB_DB_KEY_BOOK_INTRO];
    [newAccount setObject:BookInfoObj.BookInfoGUID forKey:BOOKS_WEB_DB_KEY_BOOK_ID];

    //NSLog(@"%@", newAccount);
    
    //transform the dictionary key-value pair into NSData object
//#warning Casper modified POST Method without testing
    //NSData *newAccountJSONData = [NSJSONSerialization dataWithJSONObject:newAccount options:NSJSONReadingMutableContainers error:nil];
    NSData *newAccountJSONData = [NSJSONSerialization dataWithJSONObject:newAccount options:NSJSONWritingPrettyPrinted error:nil];
    
    
    //let the NSData object be the data of the request
    [request setHTTPBody:newAccountJSONData];
    
    //create connection with the request and the connection will be sented immediately
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    // the connection created is successfully
    if (connection) {
        _receivedData = [[NSMutableData alloc] init];
        _ServerState = BOOKLIST_STATE_POSTING;
    }
}

// CASPER TEST
-(void) Books_FireDELETEConnectionToServerWithBookInfo : (BookInfo *)BookInfoObj
{
    // Encode the Image with Base64
    // NSData *imageData = UIImagePNGRepresentation(_imageView.image);
    // NSString *imageDataEncodedeString = [imageData base64EncodedString];
    
    // Send Request to Server
    // Create the request with url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:BookInfoObj.BookSearverURL];

    // Add header value and set http for POST requeest as JSON
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"DELETE"];
    
    NSLog(@"Htttp Method %@ ", request.HTTPMethod);
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    // the connection created is successfully
    if (connection) {
        _receivedData = [[NSMutableData alloc] init];
        _ServerState = BOOKLIST_STATE_DELETING;
    }
}



// CASPER TEST "PUT"
// TODO: Get specific Book info URL on the Server
-(void) Books_FirePUTConnectionToServerWithBookInfo : (BookInfo *)BookInfoObj
{
    // Encode the Image with Base64
    // NSData *imageData = UIImagePNGRepresentation(_imageView.image);
    // NSString *imageDataEncodedeString = [imageData base64EncodedString];
    
    // Send Request to Server
    // Create the request with url

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://booksharingapps.herokuapp.com/bookinfos/3.json"]];
    
    // Add header value and set http for POST requeest as JSON
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"PUT"];
    NSLog(@"UPDATE id =2 ");
    NSLog(@"Htttp Method %@ ", request.HTTPMethod);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-d H:m:s"];
    
    NSMutableDictionary *newAccount = [[NSMutableDictionary alloc]init];
    [newAccount setObject:[formatter stringFromDate:BookInfoObj.BookInfoUpdateTime] forKey:BOOKS_WEB_DB_KEY_BOOK_UPDATE_T];

    NSLog(@"%@", newAccount);
    
    NSData *newAccountJSONData = [NSJSONSerialization dataWithJSONObject:newAccount options:NSJSONWritingPrettyPrinted error:nil];
    
    
    //let the NSData object be the data of the request
    [request setHTTPBody:newAccountJSONData];

    /*
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setDateFormat:@"YYYY-MM-d H:m:s"];
     NSLog(@"POST Date = %@", [formatter stringFromDate:BookInfoObj.BookInfoCreateTime]);
     
     NSMutableDictionary *newAccount = [[NSMutableDictionary alloc]init];
     [newAccount setObject:BookInfoObj.BookName forKey:BOOKS_WEB_DB_KEY_BOOK_NAME];
     [newAccount setObject:BookInfoObj.BookAuthor forKey:BOOKS_WEB_DB_KEY_BOOK_AUTHOR];
     [newAccount setObject:BookInfoObj.BookISBN forKey:BOOKS_WEB_DB_KEY_BOOK_ISBN];
     [newAccount setObject:[BookInfoObj.BookCoverHDURL absoluteString] forKey:BOOKS_WEB_DB_KEY_BOOK_IMG_URL];
     [newAccount setObject:[formatter stringFromDate:BookInfoObj.BookInfoCreateTime] forKey:BOOKS_WEB_DB_KEY_BOOK_CREATE_T];
     [newAccount setObject:[formatter stringFromDate:BookInfoObj.BookInfoUpdateTime] forKey:BOOKS_WEB_DB_KEY_BOOK_UPDATE_T];
     [newAccount setObject:BookInfoObj.BookInfoStrongIntro forKey:BOOKS_WEB_DB_KEY_BOOK_STRONG_INTRO];
     [newAccount setObject:BookInfoObj.BookInfoIntro forKey:BOOKS_WEB_DB_KEY_BOOK_INTRO];
     
     NSLog(@"BookInfoObj.BookInfoGUID = %@", BookInfoObj.BookInfoGUID);
     [newAccount setObject:BookInfoObj.BookInfoGUID forKey:BOOKS_WEB_DB_KEY_BOOK_ID];
     
     
     NSLog(@"%@", newAccount);
     
     //transform the dictionary key-value pair into NSData object
     //#warning Casper modified POST Method without testing
     //NSData *newAccountJSONData = [NSJSONSerialization dataWithJSONObject:newAccount options:NSJSONReadingMutableContainers error:nil];
     NSData *newAccountJSONData = [NSJSONSerialization dataWithJSONObject:newAccount options:NSJSONWritingPrettyPrinted error:nil];
     
     
     //let the NSData object be the data of the request
     [request setHTTPBody:newAccountJSONData];
     */
    //create connection with the request and the connection will be sented immediately
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    // the connection created is successfully
    if (connection) {
        _receivedData = [[NSMutableData alloc] init];
    }
}

-(void) Books_HandleResponseWithHttpResponse:(NSHTTPURLResponse*) response;
{
    switch (_ServerState) {
            
        case BOOKLIST_STATE_IDLE:
            NSLog(@"BOOK LIST IDLE - Nothing happen");
            break;
            
        case BOOKLIST_STATE_DELETING:
            
            NSLog(@"BOOK LIST DELETING");
            if (([response statusCode] == 204) || ([response statusCode] == 404)) {
                
                NSLog(@"responseURL = %@", [response.URL absoluteString]);
                NSArray *TempBookObjArray = [self Books_CoreDataSearchWithBookSearverURL:response.URL];
                
                if (([TempBookObjArray count] != 1) || ([TempBookObjArray count] == 0)) {
                    
                    NSLog(@"[TempBookObjArray count] = %i ERROR", [TempBookObjArray count]);
                    
                } else {
                    
                    NSLog(@"delete book in core data");
                    NSManagedObject *bookObj = [TempBookObjArray objectAtIndex:0];
                    [self Books_CoreDataDelete:bookObj];
                    
                }
            }
            break;
            
        case BOOKLIST_STATE_POSTING:
            NSLog(@"BOOK LIST POSTING");

            break;
            
        default:
            break;
    }
}


#pragma mark - delege meethod of NSURLConnection
-(void) Books_SendNotificationToViewController:(id) Object withSinglevalue:(NSString*) Value andSingleKey:(NSString*) Key
{
    
    NSArray *userInfoKeys = [NSArray arrayWithObjects:Key, nil];
    NSArray *userInfoValues = [NSArray arrayWithObjects:Value, nil];
    
    //準備訊息內容
    NSNotification *notification = [NSNotification notificationWithName:@"BookInfoNotify"
                                                                 object:Object
                                                               userInfo:[NSDictionary dictionaryWithObjects:userInfoValues forKeys:userInfoKeys]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Send Notification to tell ViewController the data is done uploaded.  
    [connection cancel];
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        NSLog(@"did receive responced %d - %@", [httpResponse statusCode], [httpResponse.URL absoluteString]);
        [self Books_HandleResponseWithHttpResponse:httpResponse];
    }
}


@end
