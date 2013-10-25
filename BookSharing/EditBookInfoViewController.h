//
//  EditBookInfoViewController.h
//  BookSharing
//
//  Created by GIGIGUN on 2013/10/23.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookListData.h"
#import "BookInfo.h"
@interface EditBookInfoViewController : UIViewController
@property  BOOL TheBookIsDeleted;
@property  BOOL TheBookIsEdited;
@property (strong, nonatomic)   BookListData    *BookDataBase;
@property (strong, nonatomic)   BookInfo        *BookInfoObj;
@property (strong, nonatomic)   NSManagedObject *book;

- (IBAction)DeleteBtn:(id)sender;
- (IBAction)CancelBtn:(id)sender;
- (IBAction)DoneBtn:(id)sender;

@end
