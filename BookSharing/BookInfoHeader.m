//
//  BookInfoHeader.m
//  BookSharing
//
//  Created by GIGIGUN on 13/9/29.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "BookInfoHeader.h"

@implementation BookInfoHeader
@synthesize BookCoverView;
@synthesize BackLab;
@synthesize BookCoverViewSMALL;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
