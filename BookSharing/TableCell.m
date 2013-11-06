//
//  TableCell.m
//  BookSharing
//
//  Created by GIGIGUN on 13/7/16.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "TableCell.h"

@implementation TableCell
@synthesize BookNameLab;
@synthesize BookAuthorLab;
@synthesize BookCoverImg;
@synthesize BookCoverImgSmall;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
