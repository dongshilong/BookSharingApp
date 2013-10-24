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
                       @"bookCoverUrlLarge",
                       BOOKS_CORE_DATA_KEY_BOOK_INFO_INTRO,
                       BOOKS_CORE_DATA_KEY_BOOK_INFO_STRONG_INTRO,
                       @"bookAuthorIntro",
                       nil];
        AppDelegate *theAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        _context = [theAppDelegate managedObjectContext];

    }
    
    return self;
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
    
    return BookInfoObj;
}

-(BOOKLIST_STATUS) Books_SaveBookInfoObj : (BookInfo*) BookInfoObj
{
    NSUUID *Guid = [[NSUUID alloc] init];
    NSDate *date = [NSDate date];
    
    BookInfoObj.BookInfoCreateTime = date;
    BookInfoObj.BookInfoUpdateTime = date;
    BookInfoObj.BookInfoGUID = [Guid UUIDString];
    BookInfoObj = [self Books_CheckDataNilForBookInfo:BookInfoObj];
    
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


-(BOOKLIST_STATUS) Books_CoreDataUpdateWithoObject : (NSManagedObject*) Book
{
    NSError *error = nil;
    // Save the object to persistent store
    if (![_context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    return BOOKSLIST_SUCCESS;

}

-(NSMutableArray*) Books_CoreDataFetch
{
    NSMutableArray *BookList = [[NSMutableArray alloc] init];
//    NSLog(@"Books_CoreDataFetch");
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Book"];
    BookList = [[_context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    //TODO: [Casper] The BookList should convert to Book Info formate
    
    return BookList;
}

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




-(void) Books_MergeDataWithCoreData:(NSArray*) Data
{
    
    if ([Data count] != 0) {
        for (int Count = 0; Count < [Data count]; Count++) {
            
            NSArray *ISBNFound =[NSArray arrayWithArray:[self Books_CoreDataSearchWithBookISBN:[[Data objectAtIndex:Count] valueForKey:@"isbn"]]];
            
            NSLog(@"test image url = %@", [[Data objectAtIndex:Count] valueForKey:@"imageurl"]);

            
            if([ISBNFound count] == 0) {
                
                
                
                NSLog(@"%@ - %@ NOT MATCH !!!", [[Data objectAtIndex:Count] valueForKey:@"name"], [[Data objectAtIndex:Count] valueForKey:@"isbn"]);
                //Add this onject into core data
                //NSDate *TempDate = [[NSDate alloc] init];
                NSData *TempData = [[NSData alloc] init];
                NSDate *CreateDate, *UpdateDate = [[NSDate alloc] init];
                
                if ([[[Data objectAtIndex:Count] valueForKey:@"createdTime"] length] != 0) {
                    
                    NSLog(@"%@", [[Data objectAtIndex:Count] valueForKey:@"createdTime"]);

                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"YYYY-MM-d H:m:s"];
                    
                    CreateDate = [dateFormatter dateFromString:[[Data objectAtIndex:Count] valueForKey:@"createdTime"]];
                    UpdateDate = [dateFormatter dateFromString:[[Data objectAtIndex:Count] valueForKey:@"updateTime"]];
                }
                
                //TODO introduction attribute fix
                NSArray *CoreDataValue = [[NSArray alloc] initWithObjects:
                                          [[Data objectAtIndex:Count] valueForKey:@"name"],
                                          [[Data objectAtIndex:Count] valueForKey:@"isbn"],
                                          [[Data objectAtIndex:Count] valueForKey:@"author"],
                                          @"GUID NULL",
                                          TempData,
                                          @"URL NULL",
                                          CreateDate,
                                          UpdateDate,
                                          [[Data objectAtIndex:Count] valueForKey:@"imageurl"],
                                          [[Data objectAtIndex:Count] valueForKey:@"imageurl"],
                                          nil];
                
                [self Books_CoreDataSave:CoreDataKey andValue:CoreDataValue];
                
            } else {
                
                NSLog(@"ISBN already inside ");
                
            }
        }
    }    
    // TODO: [Casper] To save last update time
}

-(void) Books_FirePOSTConnectionToServerWithBookIndo : (BookInfo *)BookInfoObj
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
    
    NSLog(@"Htttp Method%@ ", request.HTTPMethod);
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
    
    //create connection with the request and the connection will be sented immediately
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    // the connection created is successfully
    if (connection) {
        _receivedData = [[NSMutableData alloc] init];
    }
}

// CASPER TEST
// TODO: Get specific Book info URL on the Server
-(void) Books_FireDELETEConnectionToServerWithBookIndo : (BookInfo *)BookInfoObj
{
    // Encode the Image with Base64
    // NSData *imageData = UIImagePNGRepresentation(_imageView.image);
    // NSString *imageDataEncodedeString = [imageData base64EncodedString];
    
    // Send Request to Server
    // Create the request with url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://booksharingapps.herokuapp.com/bookinfos/1.json"]];
    
    // Add header value and set http for POST requeest as JSON
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"DELETE"];
    NSLog(@"DELETE id = 1");
    NSLog(@"Htttp Method%@ ", request.HTTPMethod);
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



// CASPER TEST "PUT"
// TODO: Get specific Book info URL on the Server
-(void) Books_FirePUTConnectionToServerWithBookIndo : (BookInfo *)BookInfoObj
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
    [self Books_SendNotificationToViewController:nil withSinglevalue:@"Finished Uploading Data" andSingleKey:@"Status"];
    [connection cancel];
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        NSLog(@"did receive responced %d", [httpResponse statusCode]);
    }
}


@end
