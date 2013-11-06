//
//  SearchFindBook.m
//  BookSharing
//
//  Created by GIGIGUN on 2013/11/5.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "SearchFindBook.h"

@implementation SearchFindBook

//
// 將 Key Word 包裝成搜尋網址
//
-(NSURL*) FindBook_PrepareURLByISBN:(NSString*) ISBNStr
{
    NSString *URLStr = [NSString stringWithFormat:@"%@%@%@", @"https://findbook.tw/book/", ISBNStr,@"/basic"];
    _KeyWord = ISBNStr;
    return [[NSURL alloc] initWithString:URLStr];
}

-(BOOL) FindBook_isBookExistInHtmlData:(NSData*) HtmlData
{
    if (HtmlData == nil) {
        NSLog(@"ERROR, HtmlData = nil");
        return NO;
    }
    
    TFHpple *HtmlParser = [TFHpple hppleWithHTMLData:HtmlData];
    
    // xPath =//*[@id="main"]/div/h1
    NSString *SearchResultXpathQueryString = @"//*[@id=\"content\"]/div/div/h2[1]";
    NSArray *SearchResultNodes = [HtmlParser searchWithXPathQuery:SearchResultXpathQueryString];
    
    TFHppleElement *element = [SearchResultNodes objectAtIndex:0];

    if ([[[element firstChild] content] isEqualToString:@"一分鐘學會用 Findbook 搜尋"]) {
        return NO;
    }
    return YES;
}


-(NSString*) FindBook_PrepareBookNameWithHtmlData:(NSData *) HtmlData
{
    if (HtmlData == nil) {
        NSLog(@"ERROR, HtmlData = nil");
        return nil;
    }
    
    TFHpple *HtmlParser = [TFHpple hppleWithHTMLData:HtmlData];
    
    // xPath =//*[@id="main"]/div/h1
    NSString *SearchResultXpathQueryString = @"//*[@id=\"main\"]/div/h1";
    NSArray *SearchResultNodes = [HtmlParser searchWithXPathQuery:SearchResultXpathQueryString];
    
    TFHppleElement *element = [SearchResultNodes objectAtIndex:0];
    return [[element firstChild] content];
}

-(NSString*) FindBook_PrepareBookAuthorWithHtmlData:(NSData *) HtmlData
{
    
    if (HtmlData == nil) {
        NSLog(@"ERROR, HtmlData = nil");
        return nil;
    }
    
    TFHpple *HtmlParser = [TFHpple hppleWithHTMLData:HtmlData];
    
    // xPath = //*[@id="main"]/div/p[1]/a
    NSString *SearchResultXpathQueryString = @"//*[@id=\"main\"]/div/p[1]/a";
    NSArray *SearchResultNodes = [HtmlParser searchWithXPathQuery:SearchResultXpathQueryString];
    TFHppleElement *element = [SearchResultNodes objectAtIndex:0];
    
    return  [[element firstChild] content];
}


-(NSURL*) Books_PrepareBookCoverByISBN: (NSString*) ISBNStr
{
    //http://api.findbook.tw/book/cover/[ISBN].jpg
    NSString *ImageStr = @"http://api.findbook.tw/book/cover/";
    
    if (ISBNStr == nil) {
        NSLog(@"ERROR, BookISBN = nil in Books_PrepareBookCover");
        return nil;
    }
    
    ImageStr = [NSString stringWithFormat:@"%@%@%@", ImageStr, ISBNStr, @".jpg"];
    return [NSURL URLWithString:ImageStr];

}

-(NSString*) FindBook_PrepareBookIntro:(NSData *) HtmlData
{
    if (HtmlData == nil) {
        NSLog(@"ERROR, HtmlData = nil");
        return nil;
    }
    
    TFHpple *HtmlParser = [TFHpple hppleWithHTMLData:HtmlData];
    
//   //*[@id="content"]/div/div/div[6]/div/text()
    NSString *SearchResultXpathQueryString = @"//*[@id=\"content\"]/div/div/div[6]/div/text()";
    NSArray *SearchResultNodes = [HtmlParser searchWithXPathQuery:SearchResultXpathQueryString];

    if ((SearchResultNodes != nil) || ([SearchResultNodes count] != 0)) {
        
        
        TFHppleElement *element = [SearchResultNodes objectAtIndex:0];
        return [element valueForKey:@"raw"];
    }
    
    return nil;
}


-(NSDictionary*) FindBook_PrepareBoosSearchResultTable:(NSData*) HtmlData
{
    
    NSMutableArray  *TempBookNameArray = [[NSMutableArray alloc] init];
    NSMutableArray  *TempBookURLArray = [[NSMutableArray alloc] init];
    NSMutableArray  *TempBookAuthorArray = [[NSMutableArray alloc] init];
    NSMutableArray  *TempBookCoverURLArray = [[NSMutableArray alloc] init];
    
    
    if (HtmlData == nil) {
        BOOKS_ERROR_LOG(@"NO HTML DATA");
    }
    
    [TempBookNameArray addObject:[self FindBook_PrepareBookNameWithHtmlData:HtmlData]];
    [TempBookAuthorArray addObject:[self FindBook_PrepareBookAuthorWithHtmlData:HtmlData]];
    [TempBookURLArray addObject:[self FindBook_PrepareURLByISBN:_KeyWord]];
    [TempBookCoverURLArray addObject:[self Books_PrepareBookCoverByISBN:_KeyWord]];
    
    // 3. Build up dictionary
    NSDictionary    *SearchResultDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        TempBookURLArray,BOOK_DIC_BOOK_URL_KEY,
                                        TempBookNameArray, BOOK_DIC_BOOK_NAME_KEY,
                                        TempBookAuthorArray, BOOK_DIC_BOOK_AUTHOR_KEY,
                                        TempBookCoverURLArray, BOOK_DIC_BOOK_COVER_URL_KEY,
                                        nil];
    
    
    return SearchResultDic;
}


@end
