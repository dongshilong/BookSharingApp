//
//  SearchFindBook.h
//  BookSharing
//
//  Created by GIGIGUN on 2013/11/5.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//
// ====================================================
// 2013.11.05 FindBook.com only provide ISBN Search for backup
// ====================================================

#import <Foundation/Foundation.h>
#import "BookInfo.h"
#import "TFHpple.h"

@interface SearchFindBook : NSObject
@property (strong, nonatomic) NSString *KeyWord;

-(NSURL*) FindBook_PrepareURLByISBN:(NSString*) ISBNStr;

-(BOOL) FindBook_isBookExistInHtmlData:(NSData*) HtmlData;


-(NSString*) FindBook_PrepareBookNameWithHtmlData:(NSData *) HtmlData;
-(NSString*) FindBook_PrepareBookAuthorWithHtmlData:(NSData *) HtmlData;
-(NSString*) FindBook_PrepareBookIntro:(NSData *) HtmlData;

//-(NSURL*) FindBook_PrepareBookHDCoverImageURL:(NSData *) HtmlData;

-(NSDictionary*) FindBook_PrepareBoosSearchResultTable:(NSData*) HtmlData;


@end
