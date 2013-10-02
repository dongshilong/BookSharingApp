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

// For Detailed Page
-(NSURL*) BooksTW_ScrapingSingleBookCoverURLInDetailedPage:(NSData *)HtmlData;
-(NSString*) BooksTW_ScrapingSingleBookISBNInDetailedPage:(NSData *)HtmlData;
-(NSString*) BooksTW_ScrapingSingleBookStrongDescription:(NSData *)HtmlData;
-(BOOL) BooksTW_ScrapingSingleBookSideColumnInfo:(NSData *)HtmlData ForBookinfoObj:(BookInfo *) BoonInfoObj;

@end
