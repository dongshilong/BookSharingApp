//
//  SeachViewController.h
//  BookSharing
//
//  Created by GIGIGUN on 13/9/26.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeachViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISearchBar *SearchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *bookListButton;

- (IBAction)BookListBtn:(id)sender;


@end
