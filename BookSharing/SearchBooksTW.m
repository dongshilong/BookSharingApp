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
        
        BOOKS_ERROR_LOG(@"BooksTW_TableBookCoverURLScapting node not found");
        return nil;
        
    } else {
        
        element = [SearchResultNodes objectAtIndex:0];
        BookCoverURL = [[NSString alloc] initWithString:[element objectForKey:@"src"]];
        BOOKS_SEARCH_LOG(@"Book Cover URL = %@", BookCoverURL);
    }
    
    return BookCoverURL;
}

//
// 在 HTML DATA 中找到 搜尋結果數目
//
-(NSInteger) BooksTW_PrepareSearchResultByHtmlData : (NSData *)HtmlData
{
    NSInteger SearchResult = 0;
    TFHpple *HtmlParser = [TFHpple hppleWithHTMLData:HtmlData];
    
    NSLog(@"Books_PrepareSearchResultByHtmlData ");
    
    
    NSString *SearchResultXpathQueryString = @"//div[1]/div[1]/div/ul/li[2]/span";
    NSArray *SearchResultNodes = [HtmlParser searchWithXPathQuery:SearchResultXpathQueryString];
    
    if ( (SearchResultNodes == nil) || ([SearchResultNodes count] == 0)) {
        return 0;
    } else {
        
        // To get search result number
        TFHppleElement *element = [SearchResultNodes objectAtIndex:0];
        //NSLog(@"%@", [[element firstChild] content]);
        SearchResult = [[[element firstChild] content] intValue];
        //_SearchResultNum = SearchResult;
    }
    
    
    return SearchResult;
    
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
    //NSLog(@"=== %i ===", [self BooksTW_PrepareSearchResultByHtmlData:SearchResultHtmlData]);
    
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
        [TempBookURLArray addObject:[NSURL URLWithString:[self BooksTW_TableBookInfoURLStringScapting:SearchResultHtmlData WithIndex:i] ]];
        
        // 3.3 Find Book Author and add to TempBookAuthorArray
        [TempBookAuthorArray addObject:[self BooksTW_TableBookAuthorStringScapting:SearchResultHtmlData WithIndex:i]];
        
        // 3.4 Find Book Cover URL for Table display  BooksTW_TableBookCoverURLScapting
        [TempBookCoverURLArray addObject:[NSURL URLWithString:[self BooksTW_TableBookCoverURLScapting:SearchResultHtmlData WithIndex:i] ]];
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

// ISBN
//
-(NSString*) BooksTW_ScrapingSingleBookISBNInDetailedPage:(NSData *)HtmlData
{
    NSString *ISBNStr = [[NSString alloc] init];
    TFHpple *HtmlParser = [TFHpple hppleWithHTMLData:HtmlData];
    NSRange TextRange;
    
    // Find ISBN string first
    NSString *HtmlDataStr = [[NSString alloc] initWithData:HtmlData encoding:NSUTF8StringEncoding];
    TextRange = [HtmlDataStr rangeOfString:@"ISBN"];
    
    if (TextRange.length == 0) {
        BOOKS_ERROR_LOG(@"NO ISBN IN THIS PAGE");
        return nil;
        
    } else {
        // reset TextRange
        TextRange.location = 0;
        TextRange.length = 0;
    }
    
    for (int Index1 = 1; Index1 <= 5; Index1 ++) {
        for (int Index2 = 1; Index2 <= 5; Index2 ++) {
            NSString *SearchResultXpathQueryString = [NSString stringWithFormat:@"%@%i%@%i%@",
                                                      @"/html/body/div[2]/div/div[", Index1, @"]/div[1]/div[",
                                                      Index2,
                                                      @"]/div/ul[1]/li[1]"];
            NSArray *SearchResultNodes = [HtmlParser searchWithXPathQuery:SearchResultXpathQueryString];
            
            if ((SearchResultNodes == nil) || ([SearchResultNodes count] == 0)) {
                
                //BOOKS_ERROR_LOG(@"Node Not Found with index %i !!", Index);
                
            } else {
                
                TFHppleElement *element = [SearchResultNodes objectAtIndex:0];
                element = [SearchResultNodes objectAtIndex:0];
                ISBNStr = [NSString stringWithFormat:@"%@", [[element firstChild] content]];
                TextRange = [ISBNStr rangeOfString:@"ISBN："];
                
                if (TextRange.length != 0) {
                    
                    ISBNStr = [ISBNStr substringFromIndex:TextRange.length];
                    BOOKS_SEARCH_LOG(@"ISBNStr = %@", [[element firstChild] content]);
                    
                    return ISBNStr;
                    
                } else {
                    
                    ISBNStr = nil;
                }
            }
            
            if ((Index1 == 5) && (Index2 == 5)) {
                BOOKS_ERROR_LOG(@"ISBN NOT FOUND");
                return nil;
            }
        }
    }
    
    
    return ISBNStr;
}

// Remove all html tag string
-(NSString *) stringByStrippingHTML:(NSString*) InputString
{
    NSRange r;
    NSString *s = InputString;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}


// 移除全形空白
// 移除<BR> <br>
// 移除所有的 HTML Tag
-(NSString *) stringArrangeIntroString:(NSString*) InputString
{
    
    NSRange range;
    range.length = 1;
    range.location = 0;
    
    for (int i = 0; i < [InputString length]; i++) {
        
        if ([InputString characterAtIndex:i] == 12288) {
            range.location = i;
            InputString = [InputString stringByReplacingCharactersInRange:range withString:@"@@"];
        }
    }
    
    InputString = [InputString stringByReplacingOccurrencesOfString:@"<BR>" withString:@"\n"];
    InputString = [InputString stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    InputString = [InputString stringByReplacingOccurrencesOfString:@"@@" withString:@""];
    InputString = [self stringByStrippingHTML:InputString];
    return InputString;
}


//
// 取出加強介紹
//
-(NSString*) BooksTW_ScrapingSingleBookStrongDescription:(NSData *)HtmlData
{
    NSString *BookDescription = nil;
    
    if (HtmlData == nil) {
        BOOKS_ERROR_LOG(@"ERROR, BookInfoObj.HtmlData = nil");
        return nil;
    }
    
    
    // SearchDic value = 搜尋區域的尾巴 , Key = 搜尋區域的頭
    NSDictionary *SearchDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                               @"</span></strong></p>", @"<strong><span style=\"color:#ff0000;\">",
                               @"</FONT></STRONG></P>", @"<STRONG><FONT color=#ff0000>",
                               nil];
    
    // Try to scraping the text by hand job    
    NSString *HtmlDataStr = [[NSString alloc] initWithData:HtmlData encoding:NSUTF8StringEncoding];
    NSArray *KeyArray = [NSArray arrayWithArray:[SearchDic allKeys]];
    NSRange TextRange1, TextRange2;
    
    for (NSString *KeyStr in KeyArray) {
        
        // Search for Key Str
        // HEAD location
        TextRange1 = [HtmlDataStr rangeOfString:KeyStr];
        if (TextRange1.length != 0) {
            // TAIL location
            BOOKS_SEARCH_LOG(@"Strong Intro KEY = %@", KeyStr);
            TextRange2 = [HtmlDataStr rangeOfString:[SearchDic objectForKey:KeyStr]];

            TextRange1.location = TextRange1.location + TextRange1.length;
            TextRange1.length = TextRange2.location - TextRange1.location;
            
            BookDescription = [NSString stringWithFormat:@"%@", [HtmlDataStr substringWithRange:TextRange1]];
            BookDescription = [self stringArrangeIntroString:BookDescription];
            break;
        }
        
    }
    
    return BookDescription;
}


-(NSString*) BooksTW_ScrapingSingleBookNormalDescription:(NSData *)HtmlData
{
    NSString *BookDescription = nil;
    
    if (HtmlData == nil) {
        BOOKS_ERROR_LOG(@"ERROR, BookInfoObj.HtmlData = nil");
        return nil;
    }
    
    
    // SearchDic value = 搜尋區域的尾巴 , Key = 搜尋區域的頭
    NSDictionary *SearchDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                               @"</span></strong></p>", @"<strong><span style=\"color:#ff0000;\">",
                               @"</FONT></STRONG></P>", @"<STRONG><FONT color=#ff0000>",
                               nil];
    
    // Try to scraping the text by hand job
    NSString *HtmlDataStr = [[NSString alloc] initWithData:HtmlData encoding:NSUTF8StringEncoding];
    NSArray *KeyArray = [NSArray arrayWithArray:[SearchDic allKeys]];
    NSRange TextRange1, TextRange2;
    
    for (NSString *KeyStr in KeyArray) {
        
        // Search for Key Str
        // HEAD location
        TextRange1 = [HtmlDataStr rangeOfString:KeyStr];
        if (TextRange1.length != 0) {
            // TAIL location
            BOOKS_SEARCH_LOG(@"Strong Intro KEY = %@", KeyStr);
            TextRange2 = [HtmlDataStr rangeOfString:[SearchDic objectForKey:KeyStr]];
            
            TextRange1.location = TextRange1.location + TextRange1.length;
            TextRange1.length = TextRange2.location - TextRange1.location;
            
            BookDescription = [NSString stringWithFormat:@"%@", [HtmlDataStr substringWithRange:TextRange1]];
            BookDescription = [self stringArrangeIntroString:BookDescription];
            break;
        }
        
    }
    
    return BookDescription;
}



//
// 封面旁邊那一塊
//
-(BOOL) BooksTW_ScrapingSingleBookSideColumnInfo:(NSData *)HtmlData ForBookinfoObj:(BookInfo *) BoonInfoObj
{
    BOOL Success = NO;
    
    if (HtmlData == nil) {
        BOOKS_ERROR_LOG(@"ERROR, BookInfoObj.HtmlData = nil");
        return NO;
    }
    
    TFHpple *HtmlParser = [TFHpple hppleWithHTMLData:HtmlData];
    NSString *SearchResultXpathQueryString = nil;
    NSArray *SearchResultNodes = nil;
    
    // Go through the column
    for (int Index = 1; Index <= 10; Index++) {
        //SearchResultXpathQueryString = @"/html/body/div[2]/div/div[1]/div[2]/div[2]/ul/li[1]/text()";
        SearchResultXpathQueryString = [NSString stringWithFormat:@"%@%i%@", @"/html/body/div[2]/div/div[1]/div[2]/div[2]/ul/li[", Index, @"]/text()"];
        SearchResultNodes = [NSArray arrayWithArray:[HtmlParser searchWithXPathQuery:SearchResultXpathQueryString]];
        if ((SearchResultNodes == nil) || ([SearchResultNodes count] == 0)) {
            BOOKS_ERROR_LOG(@"Node Not Found!!");
        
        } else {
        
            TFHppleElement *element = [SearchResultNodes objectAtIndex:0];
            NSLog(@"%@ - raw = %@ - content = %@ - text = %@", element, element.raw, element.content, element.text);
            
            // 作者
            // 譯者
        
        
        }

    }
    

    
    return Success;
}


// Used in detailed view
// Precondition : send connection with detailed URL
-(NSURL*) BooksTW_ScrapingSingleBookCoverURLInDetailedPage:(NSData *)HtmlData
{
    NSString *BookCoverStr = nil;
    
    if (HtmlData == nil) {
        BOOKS_ERROR_LOG(@"ERROR, BookInfoObj.HtmlData = nil");
        return nil;
    }
    
    TFHpple *HtmlParser = [TFHpple hppleWithHTMLData:HtmlData];
    NSString *SearchResultXpathQueryString = @"/html/body/div[2]/div/div[1]/div[1]/div[1]/div/img";
    //NSString *SearchResultXpathQueryString = @"//*[@id=\"main_img\"]";
    NSArray *SearchResultNodes = [HtmlParser searchWithXPathQuery:SearchResultXpathQueryString];
    
    if ((SearchResultNodes == nil) || ([SearchResultNodes count] == 0)) {
        BOOKS_ERROR_LOG(@"Node Not Found!!");
        return nil;
        
    } else {
        
        TFHppleElement *element = [SearchResultNodes objectAtIndex:0];
        element = [SearchResultNodes objectAtIndex:0];
        BOOKS_SEARCH_LOG(@"imgcoverurlstr = %@", [element objectForKey:@"src"]);
        BookCoverStr = [NSString stringWithFormat:@"%@", [element objectForKey:@"src"]];
    }
    
    return [NSURL URLWithString:BookCoverStr];
}




@end
