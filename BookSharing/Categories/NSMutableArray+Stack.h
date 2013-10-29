//
//  NSMutableArray+Stack.h
//  BookSharing
//
//  Created by GIGIGUN on 2013/10/29.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Stack)
- (void) push: (id)item;
- (id) pop;
- (id) peek;
@end
