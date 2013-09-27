//
//  TableCellSmall.m
//  BookSharing
//
//  Created by GIGIGUN on 13/8/21.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "TableCellSmall.h"

@implementation TableCellSmall
@synthesize BookNameLab;
@synthesize BookCoverImg;

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
