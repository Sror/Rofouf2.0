//
//  AddBooksViewController.m
//  Rofouf
//
//  Created by mohamed.alaa on 12/25/13.
//  Copyright (c) 2013 Mohamed Alaa El-Din. All rights reserved.
//

#import "AddBooksViewController.h"
#import "Constants.h"
#import "ArabicConverter.h"
#import "UserDefaults.h"
#import <CommonCrypto/CommonDigest.h>
#import "HorizontalTableView.h"
#import "AppDelegate.h"

@interface AddBooksViewController () <MyComicCellDelegate, UIGestureRecognizerDelegate>

@end

@implementation AddBooksViewController
@synthesize reusableCells, booksArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ((AppDelegate *)[UIApplication sharedApplication].delegate).itunesFlag = 1;
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.indicatorView startAnimating];
    [self.rofoufTableView setBackgroundColor:[UIColor clearColor]];
    
    ArabicConverter *converter = [[[ArabicConverter alloc] init] autorelease] ;
    self.rofoufLbl.text        = [converter convertArabic:@"رفوف"];
    self.rofoufLbl.font        = [UIFont fontWithName:Font size:75];
    
    [NSThread detachNewThreadSelector:@selector(getBooks) toTarget:self withObject:nil];
    
    if(IS_IPAD)
    {
        self.rofoufTableView.pagingEnabled = YES;
        [self initializeSwipewGestureInTableView];
        
        pageControl = [[UIPageControl alloc] init];
        pageControl.pageIndicatorTintColor        = [UIColor lightGrayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        [self.view addSubview:pageControl];
        [self.view bringSubviewToFront:pageControl];
    }
    
    [self initializeOrientation];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (NSString*)dataMD5:(NSData*)data {
    CC_MD5_CTX md5;
    
    CC_MD5_Init(&md5);
    
    CC_MD5_Update(&md5, [data bytes], (unsigned int)[data length]);
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    return s;
}


-(UIImage *)imageFromPDFWithDocumentRef:(CGPDFDocumentRef)documentRef {
    CGPDFPageRef pageRef = CGPDFDocumentGetPage(documentRef, 1);
    CGRect pageRect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
    
    UIGraphicsBeginImageContext(pageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, CGRectGetMinX(pageRect),CGRectGetMaxY(pageRect));
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, -(pageRect.origin.x), -(pageRect.origin.y));
    CGContextDrawPDFPage(context, pageRef);
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}

-(void) getFilesFromItunes
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSArray *pdfs = [[NSBundle bundleWithPath:[paths objectAtIndex:0]] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    
    self.booksArray = [NSMutableArray array];
    for(int i = 0 ; i < pdfs.count ; i++)
    {
        NSArray *bookNameArray = [[pdfs objectAtIndex:i] componentsSeparatedByString:@"/"];
        NSString *bookName = [bookNameArray lastObject];
        
        
        NSData *pdfData   = [NSData dataWithContentsOfFile:[pdfs objectAtIndex:i]];
        NSString *bookMD5 = [self dataMD5:pdfData];
        
        if([UserDefaults isBookExistWithMD5:bookMD5])
            continue;
        
        
        NSURL *fileURL = [NSURL fileURLWithPath:[pdfs objectAtIndex:i]];
        NSNumber *fileSizeValue = nil;
        NSError *fileSizeError  = nil;
        [fileURL getResourceValue:&fileSizeValue
                           forKey:NSURLFileSizeKey
                            error:&fileSizeError];
        
        NSURL* pdfFileUrl = [NSURL fileURLWithPath:[pdfs objectAtIndex:i]];
        CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfFileUrl);
        UIImage *bookThumbinal = [self imageFromPDFWithDocumentRef:pdf];
        
        NSData *bookImageData = UIImageJPEGRepresentation(bookThumbinal,0.0);
        
        NSDictionary *bookMetadata = [NSDictionary dictionaryWithObjectsAndKeys:bookMD5,@"bMD5",bookName,@"bName",fileSizeValue,@"bSize",bookImageData,@"bThumbinal", nil];
        NSMutableArray *book = [[NSMutableArray alloc] init];
        [book addObject:bookMetadata];
        
        [self.booksArray addObject:book];
        [book release];
    }
}

#pragma mark Orientation

-(void)initializeOrientation
{
    lastOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if(IS_LANDSCAPE_STATUSBAR)
    {
        if(IS_IPAD)
            sectionSize = 6 ;
        else
        {
            sectionSize = 4 ;
            self.rofoufLbl.frame = CGRectMake(0, 0, 480, self.rofoufLbl.frame.size.height);
        }
        currentOrientation = @"landscape";
        [self landscape];
    }
    else
    {
        if(IS_IPAD)
            sectionSize = 4 ;
        else
        {
            sectionSize = 2 ;
            self.rofoufLbl.frame = CGRectMake(0, 0, 320, self.rofoufLbl.frame.size.height);
        }
        currentOrientation = @"portrait";
        [self portrait];
    }
}


-(void)landscape
{
    if(IS_IPAD)
    {
        [pageControl setFrame:CGRectMake(((self.view.frame.size.width / 2) - 50), 768 -100, 100, 100)];
        [self.chooseLbl setFrame:CGRectMake(801, self.chooseLbl.frame.origin.y, self.chooseLbl.frame.size.width, self.chooseLbl.frame.size.height)];
        maxBooksPerView = 12;
        rowHeight   = 272;
        sectionSize = 6 ;
        self.rofoufTableView.frame = CGRectMake(self.rofoufTableView.frame.origin.x, self.rofoufTableView.frame.origin.y, 1024, 768 - 131);
        self.rofoufLbl.frame = CGRectMake(self.rofoufLbl.frame.origin.x, self.rofoufLbl.frame.origin.y, 1024, self.rofoufLbl.frame.size.height);
        self.bgImg.frame = CGRectMake(0, 0, 1024, 768);
    }
    else
    {
        if(IS_IPHONE_5)
        {
            rowHeight   = 159.5;
            sectionSize = 4;
            self.rofoufTableView.frame = CGRectMake( 44, self.rofoufTableView.frame.origin.y,  480, 320 - 95);
            self.bgImg.frame  = CGRectMake(0, 0, 480, 320);
            self.bgImg.hidden = YES;
            self.rofoufLbl.frame = CGRectMake(44, 0, 480, self.rofoufLbl.frame.size.height);
        }
        else
        {
            rowHeight   = 159.5;
            sectionSize = 4 ;
            self.rofoufTableView.frame = CGRectMake(0, self.rofoufTableView.frame.origin.y,  480, 320 - 95);
            self.bgImg.frame  = CGRectMake(0, 0, 480, 320);
            self.bgImg.hidden = YES;
            self.rofoufLbl.frame = CGRectMake(0, 0, 480, self.rofoufLbl.frame.size.height);
        }
    }
    
    self.indicatorView.frame = CGRectMake(self.indicatorView.frame.origin.y, self.indicatorView.frame.origin.x, self.indicatorView.frame.size.width, self.indicatorView.frame.size.height);
    
    if(IS_RETINA)
        self.bgImg.image = [UIImage imageNamed:@"bgLandscape@2x.png"];
    else
        self.bgImg.image = [UIImage imageNamed:@"bgLandscape.png"];
}

-(void)portrait
{
    if(IS_IPAD)
    {
        [pageControl setFrame:CGRectMake( ((768 / 2) - 50), 1024 -100, 100, 100)];
        
        [self.chooseLbl setFrame:CGRectMake(545, self.chooseLbl.frame.origin.y, self.chooseLbl.frame.size.width, self.chooseLbl.frame.size.height)];
        maxBooksPerView = 12;
        rowHeight   = 264;
        sectionSize = 4 ;
        self.rofoufTableView.frame = CGRectMake(self.rofoufTableView.frame.origin.x, self.rofoufTableView.frame.origin.y, 768, 929);
        self.rofoufLbl.frame = CGRectMake(self.rofoufLbl.frame.origin.x, self.rofoufLbl.frame.origin.y, 768, self.rofoufLbl.frame.size.height);
        self.bgImg.frame = CGRectMake(0, 0, 768, 1024);
    }
    else
    {
        sectionSize = 2 ;
        rowHeight   = 180;
        if(IS_IPHONE_5)
        {
            self.rofoufTableView.frame = CGRectMake(0, self.rofoufTableView.frame.origin.y,320, 465);
            self.bgImg.frame  = CGRectMake(0, 0, 320, 465);
            self.bgImg.hidden = YES;
            self.rofoufLbl.frame = CGRectMake(0, 0, 320, self.rofoufLbl.frame.size.height);
        }
        else
        {
            self.rofoufTableView.frame = CGRectMake(self.rofoufTableView.frame.origin.x, self.rofoufTableView.frame.origin.y,320, 377);
            self.bgImg.frame  = CGRectMake(0, 0, 320, 480);
            self.bgImg.hidden = YES;
            self.rofoufLbl.frame = CGRectMake(0, 0, 320, self.rofoufLbl.frame.size.height);
        }
    }
    
    self.indicatorView.frame = CGRectMake(self.indicatorView.frame.origin.x, self.indicatorView.frame.origin.y, self.indicatorView.frame.size.width, self.indicatorView.frame.size.height);
    if(IS_RETINA)
        self.bgImg.image = [UIImage imageNamed:@"bg.png"];
    else
        self.bgImg.image = [UIImage imageNamed:@"bg.png"];
}

-(void) orientationChanged:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resetRequests" object:nil userInfo:nil];
    
    if(IS_LANDSCAPE)
    {
        lastOrientation = [[UIDevice currentDevice] orientation];
        if([currentOrientation isEqualToString:@"portrait"])
        {
            [self landscape];
            currentOrientation = @"landscape";
            
            [self.reusableCells removeAllObjects];
            if(IS_IPAD)
                [self loadComicsInCells:(currentView * maxBooksPerView)];
            else
                [self loadComicsInCells];
        }
    }
    else if(IS_PORTRAIT)
    {
        lastOrientation = [[UIDevice currentDevice] orientation];
        if([currentOrientation isEqualToString:@"landscape"])
        {
            [self portrait];
            currentOrientation = @"portrait";
            
            [self.reusableCells removeAllObjects];
            if(IS_IPAD)
                [self loadComicsInCells:(currentView * maxBooksPerView)];
            else
                [self loadComicsInCells];
        }
    }
    else
        return;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark load Books


-(void)getBooks
{
    self.reusableCells = [NSMutableArray array];
    
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self getFilesFromItunes];
            
          
            
            //[UserDefaults addBook:book];
            //[UserDefaults addUploadingBook:book];
            if(IS_IPAD)
            {
                booksViewsCount = self.booksArray.count / maxBooksPerView;
                if(self.booksArray.count % maxBooksPerView != 0)
                    booksViewsCount++;
                
                if(booksViewsCount == 1)
                    pageControl.numberOfPages = 0;
                else
                    pageControl.numberOfPages = booksViewsCount;
                
                pageControl.currentPage = booksViewsCount - 1;
            }
            
            [self loadComicsInCells:(currentView * maxBooksPerView)];
        });
    });
}

-(void)loadComicsInCells
{
    if ([booksArray count] == 1)
    {
        HorizontalTableView *cell = [[HorizontalTableView alloc] initWithIsLastCategory:NO withBook: self.booksArray];
        cell.viewController = self;
        cell.delegate       = self;
        [self.reusableCells addObject:cell];
        [cell release];
    }
    else
    {
        for (int i = 1; i <= [self.booksArray count]; i++)
        {
            i--;
            BOOL isStart = YES;
            NSMutableArray *rowBooks = [NSMutableArray array];
            while (i % sectionSize != 0 || isStart)
            {
                isStart = NO;
                if (i < [self.booksArray count])
                {
                    [rowBooks addObject:[self.booksArray objectAtIndex:i]];
                    i++;
                }
                else
                    break;
            }
            
            HorizontalTableView *cell = [[HorizontalTableView alloc] initWithIsLastCategory:NO withBook:rowBooks];
            cell.viewController=self;
            cell.delegate=self;
            [self.reusableCells addObject:cell];
            [cell release];
        }
    }
    [self.rofoufTableView reloadData];
    [self.indicatorView setHidden:YES];
    [self.indicatorView stopAnimating];
}

-(void)loadComicsInCells:(int)index
{
    int lastCount = index + maxBooksPerView;
    if(self.booksArray.count < (index + maxBooksPerView))
        lastCount = self.booksArray.count;
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    for(int i = index ; i < lastCount ; i++)
        [tmpArray addObject:[self.booksArray objectAtIndex:i]];
    
    if ([tmpArray count] == 1)
    {
        HorizontalTableView *cell = [[HorizontalTableView alloc] initWithIsLastCategory:NO withBook:tmpArray];
        cell.viewController = self;
        cell.delegate       = self;
        [self.reusableCells addObject:cell];
        [cell release];
    }
    else
    {
        for (int i = 1; i <= [tmpArray count]; i++)
        {
            i--;
            BOOL isStart = YES;
            NSMutableArray *rowBooks = [NSMutableArray array];
            while (i % sectionSize != 0 || isStart)
            {
                isStart = NO;
                if (i < [tmpArray count])
                {
                    [rowBooks addObject:[tmpArray objectAtIndex:i]];
                    i++;
                }
                else
                    break;
            }
            
            HorizontalTableView *cell = [[HorizontalTableView alloc] initWithIsLastCategory:NO withBook:rowBooks];
            cell.viewController=self;
            cell.delegate=self;
            [self.reusableCells addObject:cell];
            [cell release];
        }
    }
    [self.rofoufTableView reloadData];
    [self.indicatorView setHidden:YES];
    [self.indicatorView stopAnimating];
}


#pragma mark Gesture

-(void)initializeSwipewGestureInTableView
{
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGesture];
    [swipeGesture release];
    
    UISwipeGestureRecognizer *swipeGesture2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    swipeGesture2.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeGesture2];
    [swipeGesture2 release];
}

-(void)rightSwipe:(UISwipeGestureRecognizer *)swipe
{
    if(currentView == 0)
        return;
    
    TRAN_PUSH_RIGHT
    
    currentView--;
    booksViewsCount++;
    pageControl.currentPage = booksViewsCount - 1;
    
    [self.reusableCells removeAllObjects];
    [self loadComicsInCells:(currentView * maxBooksPerView)];
}

-(void)leftSwipe:(UISwipeGestureRecognizer *)swipe
{
    if(currentView >= pageControl.numberOfPages - 1 )
        return;
    
    TRAN_PUSH_LEFT
    
    currentView++;
    booksViewsCount--;
    pageControl.currentPage = booksViewsCount - 1;
    
    [self.reusableCells removeAllObjects];
    [self loadComicsInCells:(currentView * maxBooksPerView)];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark TableView delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)theTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HorizontalTableView *cell = [self.reusableCells objectAtIndex:indexPath.section];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [self.reusableCells count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark alerts

-(void)showAlert
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"معذرة، تأكد من إتصالك بالإنترنت" delegate:nil cancelButtonTitle:@"إلغاء" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

#pragma dealloc


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_chooseLbl release];
    [super dealloc];
}
@end
