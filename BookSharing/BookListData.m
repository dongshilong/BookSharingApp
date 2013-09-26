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
                       @"bookName",
                       @"bookISBN",
                       @"bookAuthor",
                       @"bookGuid",                     //  20130708 Casper add bookGuid attribute
                       @"bookCoverImage",               //  20130708 Casper add bookCoverImage attribute
                       @"bookInfoURL",                  //  20130709 Casper add bookInfoURL attribute
                       @"bookCreateTime",               //  20130709 Casper add bookCreateTime attribute
                       @"bookUpdateTime",               //  20130823
                       @"bookCoverUrlSmall",            //  20130822 
                       @"bookCoverUrlLarge",            //  20130822
                       @"bookIntro",                    //  20130903
                       @"bookStrongIntro",               //  20130903
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
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"bookName" ascending:YES];
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
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"bookAuthor" ascending:YES];
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
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"bookISBN" ascending:YES];
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
    [newAccount setObject:BookInfoObj.BookName forKey:@"name"];
    [newAccount setObject:BookInfoObj.BookAuthor forKey:@"author"];
    [newAccount setObject:BookInfoObj.BookISBN forKey:@"isbn"];
    [newAccount setObject:[BookInfoObj.BookCoverHDURL absoluteString] forKey:@"imageurl"];
    [newAccount setObject:[formatter stringFromDate:BookInfoObj.BookInfoCreateTime] forKey:@"createdTime"];
    [newAccount setObject:[formatter stringFromDate:BookInfoObj.BookInfoUpdateTime] forKey:@"updateTime"];
    [newAccount setObject:BookInfoObj.BookInfoIntro forKey:@"introduction"];
    //introduction
    //NSLog(@"%@", BookInfoObj.BookCoverURL );
    //[newAccount setObject:_booktypeTextField.text forKey:@"booktype"];
    //[newAccount setObject:_tagTextField.text forKey:@"tag"];
    //[newAccount setObject:imageDataEncodedeString forKey:@"icon_image_data"];
    
    NSLog(@"%@", newAccount);
    
    //transform the dictionary key-value pair into NSData object
#warning Casper modified POST Method without testing
    //    NSData *newAccountJSONData = [NSJSONSerialization dataWithJSONObject:newAccount options:NSJSONReadingMutableContainers error:nil];
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
        NSLog(@"%d", [httpResponse statusCode]);
    }
}


@end
