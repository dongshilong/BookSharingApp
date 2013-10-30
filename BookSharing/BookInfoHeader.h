//
//  BookInfoHeader.h
//  BookSharing
//
//  Created by GIGIGUN on 13/9/29.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BookInfo.h"
@interface BookInfoHeader : UIView
@property (weak, nonatomic) IBOutlet UIImageView *BookCoverView;
@property (weak, nonatomic) IBOutlet UIImageView *BookCoverViewSMALL;

@property (weak, nonatomic) IBOutlet UILabel *BackLab;
@property (weak, nonatomic) IBOutlet UILabel *BookNameLab;
@property (weak, nonatomic) IBOutlet UILabel *BookAuthorLab;

@end
