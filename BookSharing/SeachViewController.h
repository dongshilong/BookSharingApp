//
//  SeachViewController.h
//  BookSharing
//
//  Created by GIGIGUN on 13/9/26.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "BooksHtml.h"
#import "Searching.h"

@interface SeachViewController : UIViewController <UISearchBarDelegate> {
    BOOL SeguePerformed;
}

@property (weak, nonatomic) IBOutlet UISearchBar *SearchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *bookListButton;

@property (weak, nonatomic)     Searching *SearchingView;
@property (strong, atomic)      BooksHtml *BookSearch;
@property (nonatomic, strong)   BookInfo  *BookInfoObj;

- (IBAction)BookListBtn:(id)sender;


@end
