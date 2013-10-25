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
    NSLog(@"%@", _BookInfoObj.BookName);
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)DeleteBtn:(id)sender {
    
    _TheBookIsDeleted = YES;
    _TheBookIsEdited = NO;
    [_BookDataBase Books_CoreDataDelete:_book];
    //[_BookDataBase Books_FireDELETEConnectionToServerWithBookIndo:_BookInfoObj];
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
    [_BookDataBase Books_FirePUTConnectionToServerWithBookIndo:_BookInfoObj];
    [self dismissSemiModalView];
    
}
@end
