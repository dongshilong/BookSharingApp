//
//  BookListViewController.m
//  BookSharing
//
//  Created by GIGIGUN on 13/9/24.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "BookListViewController.h"
#import "DetailedViewController.h"
#import "SWRevealViewController.h"
#import "TableCell.h"

@interface BookListViewController ()

@end

@implementation BookListViewController
@synthesize tableView = _tableView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    InitedInViewDidLoaded = YES;
    
    // 1. Init models
    _BookList = [[BookListData alloc] init];
    
    // 2. Init table data
    _tableData = [[NSMutableArray alloc] initWithArray:[_BookList Books_CoreDataFetch]];
    [self.tableView reloadData];
    
    
    // 3. Setup slide bar
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
        // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // 4. Setup UI activity
    self.navigationItem.title = @"Book List";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.clearsSelectionOnViewWillAppear = NO;

    
    
    /*
    // Hide Search Bar at the beginning
    CGRect Bounds = _tableView.bounds;
    Bounds.origin.y = Bounds.origin.y + _SearchBar.bounds.size.height;
    _tableView.bounds = Bounds;
    [_tableView reloadData];
    
    
    if ([_tableData count] == 0) {
        // Hide Table View And Place Search
        _tableView.hidden = YES;
        NSLog(@"No data, Place search Suggestion view");
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"NothingInDB" owner:self options:nil];
        UIView *SuggestionView = [subviewArray objectAtIndex:0];
        SuggestionView.frame = CGRectMake(0, 44, SuggestionView.frame.size.width, SuggestionView.frame.size.height);
        
        //[self.view addSubview:SuggestionView];
        
    } else {
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Add code here to do background processing
            //
            //
#warning selector not implemented
            //[self performSelector:@selector(getTableImage)];
            
            dispatch_async( dispatch_get_main_queue(), ^{
                // Add code here to update the UI/send notifications based on the
                // results of the background processing
                [_tableView reloadData];
            });
        });
        
    }
    */
    
}


-(void) viewWillAppear:(BOOL)animated
{
    if (InitedInViewDidLoaded) {
        // Everything is ready in ViewDidLoaded
        InitedInViewDidLoaded = NO;
    } else {
        NSLog(@"ViewWillAppear");
        // View appeared without init
        // UI function should reloaded
    }
    
    [super viewWillAppear:animated];

    /*
    [_tableView deselectRowAtIndexPath:_LocalIndexPath animated:animated];
    _tableData = [[NSMutableArray alloc] initWithArray:[_BookList Books_CoreDataFetch]];
    
    if ([_tableData count] == 0) {
        // Hide Table View And Place Search
        _tableView.hidden = YES;
        NSLog(@"No data, Place search Suggestion view");
        
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"NothingInDB" owner:self options:nil];
        UIView *SuggestionView = [subviewArray objectAtIndex:0];
        SuggestionView.frame = CGRectMake(0, 44, SuggestionView.frame.size.width, SuggestionView.frame.size.height);
        
        //[self.view addSubview:SuggestionView];
        
    } else {
        //[self.view addSubview:_tableView];
    }
    [self.searchDisplayController setActive:NO];
    // Hide Search Bar at the beginning
    CGRect Bounds = _tableView.bounds;
    Bounds.origin.y = Bounds.origin.y + _SearchBar.bounds.size.height;
    _tableView.bounds = Bounds;
    [_tableView reloadData];
    
    */
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *sectionStr = [[NSString alloc] init];
    
    if ([self.searchDisplayController isActive]) {
        
        switch (section) {
            case 0:
                sectionStr = @"book name";
                break;
                
            case 1:
                sectionStr = @"book author";
                break;
                
            default:
                break;
        }
        
    } else {
        return nil;
    }
    return sectionStr;
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        return [_SearchResultDisplayArray count];
    } else {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        return [[_SearchResultDisplayArray objectAtIndex:section] count];
        //return [_SearchBookNameTableData count];
        
    } else {
        
        return [_tableData count];
        
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"BookDetailedInfo" sender:nil];
    return indexPath;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        // Search list
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        NSManagedObject *book = [[_SearchResultDisplayArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [book valueForKey:@"bookName"]];
        cell.imageView.image = [UIImage imageWithData:[book valueForKey:@"bookCoverImage"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [book valueForKey:@"bookAuthor"]];
        
        return cell;
        
    } else {
        
        // Normal list
        static NSString *CellIdentifier = @"TableCell";
        
        TableCell *cell = (TableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        
        NSManagedObject *book = [self.tableData objectAtIndex:indexPath.row];
        cell.BookNameLab.text = [NSString stringWithFormat:@"%@", [book valueForKey:@"bookName"]];
        cell.BookAuthorLab.text = [NSString stringWithFormat:@"%@", [book valueForKey:@"bookAuthor"]];
        cell.BookCoverImg.image = [UIImage imageWithData:[book valueForKey:@"bookCoverImage"]];
        
        return cell;
    }
    
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue identifier = %@", segue.identifier);

    if ([segue.identifier isEqualToString:@"BookDetailedInfo"])
    {
        DetailedViewController *destViewController = segue.destinationViewController;
        destViewController.FatherView = ListBookView;
        
        if ([self.searchDisplayController isActive]) {
            
            //NSManagedObject *book = [[_SearchResultDisplayArray objectAtIndex:_LocalIndexPath.section] objectAtIndex:_LocalIndexPath.row];
            //destViewController.Book = book;
            
        } else {
            
            //NSManagedObject *book = [self.tableData objectAtIndex:_LocalIndexPath.row];
            //destViewController.Book = book;
            //destViewController.FatherView = ListBookView;
        }
        
    }
}


#pragma mark - Button Event
- (IBAction)AddBtn:(id)sender
{
    UIViewController *View = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchView"];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromLeft;
    
    [self.navigationController.view.layer
     addAnimation:transition forKey:kCATransition];
    
    [self.navigationController pushViewController:View animated:YES];

}


@end
