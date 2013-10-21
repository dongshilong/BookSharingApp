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
 - (id) initWithFrame:(CGRect)frame
 {
 if ((self = [super initWithFrame:frame]))
 {
 [self setup];
 }
 return self;
 }
 
 - (id) initWithCoder:(NSCoder *)coder
 {
 if ((self = [super initWithCoder:coder]))
 {
 [self setup];
 }
 return self;
 }
 
 - (void) setup
 {
 if (iOS7OrLater)
 {
 self.opaque = NO;
 self.backgroundColor = [UIColor clearColor];
 
 UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
 toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
 toolbar.barTintColor = self.tintColor;
 [self insertSubview:toolbar atIndex:0];
 }
 }
 */

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
