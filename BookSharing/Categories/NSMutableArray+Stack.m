//
//  NSMutableArray+Stack.m
//  BookSharing
//
//  Created by GIGIGUN on 2013/10/29.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "NSMutableArray+Stack.h"

@implementation NSMutableArray (Stack)

- (void) push: (id)item {
    [self addObject:item];
}

- (id) pop {
    id item = nil;
    if ([self count] != 0) {
        item = [self lastObject];
        [self removeLastObject];
    }
    return item;
}

- (id) peek {
    id item = nil;
    if ([self count] != 0) {
        item = [self lastObject];
    }
    return item;
}
@end
