//
//  NSMutableArray+Queue.h
//  BookSharing
//
//  Created by GIGIGUN on 2013/10/29.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Queue)
- (void) enqueue: (id)item;
- (id) dequeue;
- (id) peek;
@end
