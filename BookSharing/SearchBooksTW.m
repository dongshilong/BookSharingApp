//
//  SearchBooksTW.m
//  ShareBook
//
//  Created by GIGIGUN on 13/9/11.
//  Copyright (c) 2013年 GIGIGUN. All rights reserved.
//

#import "SearchBooksTW.h"

@implementation SearchBooksTW

//
// 將 Key_Word_A & Key_Word_B 用 "+" 連起來
//
-(NSString *) PrepareQueryString:(NSString*) KeyWords
{
    NSString *QueryString = [[NSString alloc] init];
    QueryString = [KeyWords stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    BOOKS_SEARCH_LOG(@"QueryString %@", QueryString);
    
    return QueryString;
}

//
// 將 Key Word 包裝成搜尋網址
//
-(NSURL*) BooksTW_PrepareSearchURLWithKeyWords : (NSString *) KeyWords
{
    // prepare query string
    KeyWords = [self PrepareQueryString:KeyWords];
    KeyWords = [NSString stringWithFormat:@"%@%@", KeyWords, @"&apid=books&areaid=head_wel_search"];
    NSString *str = [NSString stringWithFormat:@"http://search.books.com.tw/exep/prod_search.php?cat=BKA&key=%@", KeyWords];
    BOOKS_SEARCH_LOG(@"%@", str);
    
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [[NSURL alloc] initWithString:str];
}


-(NSString*) BooksTW_TableBookNameScapting : (NSData *)HtmlData WithIndex : (NSUInteger) Index
{
    NSString        *BookName;
    TFHppleElement  *element;
    TFHpple         *HtmlParser = [TFHpple hppleWithHTMLData:HtmlData];

    NSString *SearchResultXpathQueryString = [NSString stringWithFormat:@"%@%i%@", @"//*[@id=\"searchlist\"]/ul/li[", Index, @"]/a[1]"];
    NSArray *SearchResultNodes = [HtmlParser searchWithXPathQuery:SearchResultXpathQueryString];
    
    if ((SearchResultNodes == nil) || ([SearchResultNodes count] == 0)) {
        
        BOOKS_ERROR_LOG(@"node not found");
        return nil;
        
    } else {
        
        element = [SearchResultNodes objectAtIndex:0];
        BookName = [[NSString alloc] initWithString:[element objectForKey:@"title"]];
        BOOKS_SEARCH_LOG(@"Book Name = %@", BookName);
    }
    
    return BookName;
}



-(NSString*) BooksTW_TableBookInfoURLStringScapting : (NSData *)HtmlData WithIndex : (NSUInteger) Index
{
    NSString        *BookInfoURL;
    TFHppleElement  *element;
    TFHpple         *HtmlParser = [TFHpple hppleWithHTMLData:HtmlData];
    
    NSString *SearchResultXpathQueryString = [NSString stringWithFormat:@"%@%i%@", @"//*[@id=\"searchlist\"]/ul/li[", Index, @"]/a[1]"];
    NSArray *SearchResultNodes = [HtmlParser searchWithXPathQuery:SearchResultXpathQueryString];
    
    if ((SearchResultNodes == nil) || ([SearchResultNodes count] == 0)) {
        
        BOOKS_ERROR_LOG(@"node not found");
        return nil;
        
    } else {
        
        element = [SearchResultNodes objectAtIndex:0];
        BookInfoURL = [[NSString alloc] initWithString:[element objectForKey:@"href"]];
        BOOKS_SEARCH_LOG(@"Book Url = %@", BookInfoURL);
    }
    
    return BookInfoURL;
}


-(NSString*) BooksTW_TableBookAuthorStringScapting : (NSData *)HtmlData WithIndex : (NSUInteger) Index
{
    NSString        *BookAuthor;
    TFHppleElement  *element;
    TFHpple         *HtmlParser = [TFHpple hppleWithHTMLData:HtmlData];
    NSString *SearchResultXpathQueryString = [NSString stringWithFormat:@"%@%i%@", @"//*[@id=\"searchlist\"]/ul/li[", Index, @"]/a[2]"];
    
    NSArray *SearchResultNodes = [HtmlParser searchWithXPathQuery:SearchResultXpathQueryString];
    if ((SearchResultNodes == nil) || ([SearchResultNodes count] == 0)) {
        
        BOOKS_ERROR_LOG(@"node not found");
        return nil;
        
    } else {
        
        element = [SearchResultNodes objectAtIndex:0];
        BookAuthor = [[NSString alloc] initWithString:[[element firstChild] content]];
        BOOKS_SEARCH_LOG(@"Book Author = %@", BookAuthor);
    }
    
    return BookAuthor;
}


-(NSString*) BooksTW_TableBookCoverURLScapting : (NSData *)HtmlData WithIndex : (NSUInteger) Index
{
    NSString        *BookCoverURL;
    TFHppleElement  *element;
    TFHpple         *HtmlParser = [TFHpple hppleWithHTMLData:HtmlData];
    NSString *SearchResultXpathQueryString = [NSString stringWithFormat:@"%@%i%@", @"//*[@id=\"searchlist\"]/ul/li[", Index, @"]/a[1]/img"];
    NSArray *SearchResultNodes = [HtmlParser searchWithXPathQuery:SearchResultXpathQueryString];
    if ((SearchResultNodes == nil) || ([SearchResultNodes count] == 0)) {
        
        BOOKS_ERROR_LOG(@"node not found");
        return nil;
        
    } else {
        
        element = [SearchResultNodes objectAtIndex:0];
        BookCoverURL = [[NSString alloc] initWithString:[element objectForKey:@"src"]];
        BOOKS_SEARCH_LOG(@"Book Cover URL = %@", BookCoverURL);
    }
    
    return BookCoverURL;
}


//
// 在 HTML DATA 中建立搜尋結果表格
//
-(NSDictionary*) BooksTW_PrepareBoosSearchResultTable:(NSData*) SearchResultHtmlData
{
 
    // 20130911 work around
    // 因為 result number 失效，無法顯示搜尋到多少結果
    
    /*
    _SearchResultNum = [self BooksTW_PrepareSearchResultByHtmlData:SearchResultHtmlData];
    if (_SearchResultNum == 0) {
        return nil;
    }
    */
    
    TFHpple         *HtmlParser = [TFHpple hppleWithHTMLData:SearchResultHtmlData];
    NSString        *SearchResultXpathQueryString;
    NSArray         *SearchResultNodes;
    NSMutableArray  *TempBookNameArray = [[NSMutableArray alloc] init];
    NSMutableArray  *TempBookURLArray = [[NSMutableArray alloc] init];
    NSMutableArray  *TempBookAuthorArray = [[NSMutableArray alloc] init];
    NSMutableArray  *TempBookCoverURLArray = [[NSMutableArray alloc] init];
    
    // 1.依序搜尋 15 個
    //  //*[@id=\"searchlist\"]/ul/li[1]
        //*[@id="searchlist"]/ul/li[1]
    
    if (SearchResultHtmlData == nil) {
        BOOKS_ERROR_LOG(@"NO HTML DATA");
    }
    
    for (int i = 1; i <= MAX_SEARCH_RESULT_PER_PAGE; i++) {
        
        // 1.Scraping 15 items in the page
        SearchResultXpathQueryString = [[NSString alloc] initWithFormat:@"%@%i%@", @"//*[@id=\"searchlist\"]/ul/li[", i, @"]"];
        BOOKS_SEARCH_LOG(@"%@", SearchResultXpathQueryString);
        SearchResultNodes = [HtmlParser searchWithXPathQuery:SearchResultXpathQueryString];
        
        if (([SearchResultNodes count] == 0) || SearchResultNodes == nil) {
            if (i == 1) {
                BOOKS_ERROR_LOG(@"NO SEARCH RESULT");
            } else {
                BOOKS_SEARCH_LOG(@"Got %i book(s) in this page", (i - 1));
            }
            break;
        }
        
        // 2. Scraping how many page
        
        // 3.Scraping the info
        // 3.1 Find Book Name and add to TempBookNameArray
        [TempBookNameArray addObject:[self BooksTW_TableBookNameScapting:SearchResultHtmlData WithIndex:i]];
        
        // 3.2 Find Book info URL and add to TempBookURLArray
        [TempBookURLArray addObject:[self BooksTW_TableBookInfoURLStringScapting:SearchResultHtmlData WithIndex:i]];
        
        // 3.3 Find Book Author and add to TempBookAuthorArray
        [TempBookAuthorArray addObject:[self BooksTW_TableBookAuthorStringScapting:SearchResultHtmlData WithIndex:i]];
        
        // 3.4 Find Book Cover URL for Table display  BooksTW_TableBookCoverURLScapting
        [TempBookCoverURLArray addObject:[self BooksTW_TableBookCoverURLScapting:SearchResultHtmlData WithIndex:i]];
    }
    
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
