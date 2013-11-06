//
//  TableCell.h
//  BookSharing
//
//  Created by GIGIGUN on 13/7/16.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *BookNameLab;
@property (weak, nonatomic) IBOutlet UILabel *BookAuthorLab;
@property (weak, nonatomic) IBOutlet UIImageView *BookCoverImg;
@property (weak, nonatomic) IBOutlet UIImageView *BookCoverImgSmall;

@end
