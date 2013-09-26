//
//  Searching.m
//  BookSharing
//
//  Created by GIGIGUN on 13/9/26.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "Searching.h"

@implementation Searching

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"test");

    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [_LoadingIcon startAnimating];
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
