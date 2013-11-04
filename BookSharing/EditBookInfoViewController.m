//
//  EditBookInfoViewController.m
//  BookSharing
//
//  Created by GIGIGUN on 2013/10/23.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "EditBookInfoViewController.h"
#import "UIViewController+KNSemiModal.h"
@interface EditBookInfoViewController ()

@end

@implementation EditBookInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _BookDataBase = [[BookListData alloc] init];
    _TheBookIsDeleted = NO;
    _TheBookIsEdited = NO;
//    NSLog(@"%@", _BookInfoObj.BookName);
    _BookInfoObj = [[BookInfo alloc] initWithCoreDataObj:_book];
    // Google Analytics
    self.screenName = @"EditView";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)DeleteBtn:(id)sender {
    
    _TheBookIsDeleted = YES;
    _TheBookIsEdited = NO;

    if ((_BookInfoObj.BookSearverURL == nil) || ([[_BookInfoObj.BookSearverURL absoluteString] isEqualToString:BOOKS_CORE_DATA_DEFAULT_VALUE])) {
        //([[_BookInfoObj.BookSearverURL absoluteString] isEqualToString:BOOKS_CORE_DATA_DEFAULT_VALUE])
        // TODO: To update coredata deleted flag, and wait to delete it during sync process
        
    } else {
        
        [self performSelectorOnMainThread:@selector(SetDeletedSelector) withObject:Nil waitUntilDone:YES];
        [_BookDataBase Books_FireDELETEConnectionToServerWithBookInfo:_BookInfoObj];
        
    }
    
    [self dismissSemiModalView];
}
- (IBAction)CancelBtn:(id)sender {
    
    _TheBookIsDeleted = NO;
    _TheBookIsEdited = NO;
    [self dismissSemiModalView];
    
}

- (IBAction)DoneBtn:(id)sender {
    
    _TheBookIsDeleted = NO;
    _TheBookIsEdited = YES;
    NSDate *UpdateDate = [[NSDate alloc] init];
    _BookInfoObj.BookInfoUpdateTime = UpdateDate;
    [_BookDataBase Books_FirePUTConnectionToServerWithBookInfo:_BookInfoObj];
    [self dismissSemiModalView];
    
}

-(void) SetDeletedSelector
{
    [_BookDataBase Books_CoreDataSetThisBookAsDeleted:_book];

}
@end
