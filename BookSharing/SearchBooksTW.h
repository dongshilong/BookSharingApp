//
//  SearchBooksTW.h
//  ShareBook
//
//  Created by GIGIGUN on 13/9/11.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookInfo.h"
#import "TFHpple.h"

#define MAX_SEARCH_RESULT_PER_PAGE 15
@interface SearchBooksTW : NSObject

-(NSURL*) BooksTW_PrepareSearchURLWithKeyWords : (NSString *) KeyWords;
-(NSDictionary*) BooksTW_PrepareBoosSearchResultTable:(NSData*) SearchResultHtmlData;


@end