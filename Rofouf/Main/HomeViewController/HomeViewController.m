//
//  HomeViewController.m
//  Rofouf
//
//  Created by Mohamed Alaa El-Din on 12/22/13.
//  Copyright (c) 2013 Mohamed Alaa El-Din. All rights reserved.
//

#import "HomeViewController.h"
#import "ArabicConverter.h"
#import "Constants.h"
#import "UserDefaults.h"
#import "HorizontalTableView.h"
#import "NetworkService.h"
#import "AddBooksViewController.h"

@interface HomeViewController () <MyComicCellDelegate, UIGestureRecognizerDelegate>

@end

@implementation HomeViewController
@synthesize reusableCells, booksArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBooks) name:@"getBooks" object:nil];
    
    bookUploadingName = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)] autorelease];
    [bookUploadingName setBackgroundColor:[UIColor clearColor]];
    [bookUploadingName setTextColor:[UIColor darkGrayColor]];
    [bookUploadingName setFont:[UIFont systemFontOfSize:10]];
    [bookUploadingName setHidden:YES];
    [self.view addSubview:bookUploadingName];
    
    progressView = [[[UIProgressView alloc] initWithFrame:CGRectMake(10.0f, 40.0f, 200, 9.0f)] autorelease];
    [progressView setProgressViewStyle: UIProgressViewStyleDefault];
    [progressView setHidden:YES];
    [self.view addSubview:progressView];
    
    currentView = 0;
    
    [self.indicatorView setHidden:NO];
    [self.indicatorView startAnimating];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.indicatorView startAnimating];
    [self.rofoufTableView setBackgroundColor:[UIColor clearColor]];
    
    ArabicConverter *converter = [[[ArabicConverter alloc] init] autorelease] ;
    self.rofoufLbl.text        = [converter convertArabic:@"رفوف"];
    self.rofoufLbl.font        = [UIFont fontWithName:Font size:75];
   
    [NSThread detachNewThreadSelector:@selector(getBooks) toTarget:self withObject:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateList) name:UPDATE_LIST object:nil];
    
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
    
    [self initializeStopShakingGesture];
    
    [self initializeOrientation];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if (!networkQueue)
        networkQueue = [[ASINetworkQueue alloc] init];
    
    [networkQueue reset];
    [networkQueue setRequestDidFinishSelector:@selector(finished:)];
    [networkQueue setRequestDidFailSelector:@selector(failed:)];
    [networkQueue setShowAccurateProgress: YES];
    [networkQueue setDelegate:self];
    [networkQueue go];
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

-(void) checkNewFilesInItunes
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSArray *pdfs = [[NSBundle bundleWithPath:[paths objectAtIndex:0]] pathsForResourcesOfType:@"pdf" inDirectory:nil];

    for(int i = 0 ; i < pdfs.count ; i++)
    {
        
        NSData *pdfData   = [NSData dataWithContentsOfFile:[pdfs objectAtIndex:i]];
        NSString *bookMD5 = [self dataMD5:pdfData];
        
        if([UserDefaults isBookExistWithMD5:bookMD5])
            continue;
         else
         {
             AddBooksViewController *addBooksViewController = [[AddBooksViewController alloc] init];
             [self presentViewController:addBooksViewController animated:YES completion:NULL];
             break;
         }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self stopShaking];
}

-(void)viewWillAppear:(BOOL)animated
{
    if ([[UserDefaults getStringWithKey:NEW_COMIC] integerValue] == 1)
        [self UpdateList];
}

-(void)UpdateList
{
    [UserDefaults addObject:@"1" withKey:NEW_COMIC ifKeyNotExists:NO];
    
    if([[UserDefaults getStringWithKey:Downlaod_Count] integerValue ] == 0)
    {
        [self.indicatorView setHidden:NO];
        [self.indicatorView startAnimating];
        [self.booksArray removeAllObjects];
        [self getBooks];
        [UserDefaults addObject:nil withKey:NEW_COMIC ifKeyNotExists:NO];
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
        [self.logout setFrame:CGRectMake(950, self.logout.frame.origin.y, self.logout.frame.size.width, self.logout.frame.size.height)];
        
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
        [self.logout setFrame:CGRectMake(694, self.logout.frame.origin.y, self.logout.frame.size.width, self.logout.frame.size.height)];
        
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
            
           // [self checkNewFilesInItunes];
            self.booksArray = [NSMutableArray array];
            self.booksArray = [UserDefaults getArrayWithKey:BOOKS_METADATA_LIST];

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

- (IBAction)logout:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"logged"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:loginViewController animated:YES];
}


-(void)upload
{
    uploadingBooksList = [NSMutableArray array];
    uploadingBooksList = [UserDefaults getArrayWithKey:stillUploading];
    
    if(uploadingBooksList.count > 0)
    {
        if(!uploading)
        {
            if ([[NetworkService getObject] checkInternetWithData])
                [NSThread detachNewThreadSelector:@selector(upLoadFilesToServer) toTarget:self withObject:nil];
            else
                [self showAlert];
        }
    }

}

-(void)upLoadFilesToServer
{
    uploading = TRUE;
    if(uploadingBooksList.count <= 0)
        return;
    
    NSString *bookName = [[[uploadingBooksList objectAtIndex:0] valueForKey:@"bName"] objectAtIndex:0];
    
    [bookUploadingName setHidden:NO];
    [bookUploadingName setText:[NSString stringWithFormat:@"uploading %@ to server",bookName]];
    
    [progressView setHidden:NO];
   
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Inbox"] stringByAppendingPathComponent:bookName];
    NSData *myData = [NSData dataWithContentsOfFile:filePath];
    
    NSString *userAgent = @"AKIAJ3P4BMg8i71rMSmaslyiS2OvoBrS/nZVI4qgtzzJC5TvTtRPPBKXLTOA";
    NSString *urlString = [NSString stringWithFormat:@"http://files.rofouf.org.s3.amazonaws.com/pdf-documents/%@",bookName];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addRequestHeader:@"User-Agent" value:userAgent];
    [request shouldContinueWhenAppEntersBackground];
    [request setUploadProgressDelegate:progressView];
    [request appendPostData:myData];
    [request setRequestMethod:@"PUT"];
    [request setDidFinishSelector:@selector(finished:)];
    [networkQueue addOperation:request];
}

- (void)finished:(ASIHTTPRequest *)request
{
    NSLog(@"finished");
    [UserDefaults removeUploadingBookWithMD5:[[[uploadingBooksList objectAtIndex:0] valueForKey:@"bMD5"] objectAtIndex:0]];
    uploadingBooksList = [UserDefaults getArrayWithKey:stillUploading];
    
    if(uploadingBooksList.count > 0)
        [self upLoadFilesToServer];
    else
    {
        uploading = FALSE;
        [progressView setProgress:0];
        [bookUploadingName setHidden:YES];
        [progressView setHidden:YES];
    }
}

-(void)failed:(ASIHTTPRequest *)request
{
    NSLog(@"failed");
    [bookUploadingName setHidden:YES];
    [progressView setHidden:YES];
    [self showAlert];
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
    [self performSelector:@selector(upload) withObject:nil afterDelay:1.0];
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
    [self performSelector:@selector(upload) withObject:nil afterDelay:1.0];
}


#pragma mark Gesture

-(void)initializeStopShakingGesture
{
    UITapGestureRecognizer *Tapped = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stopShaking)];
    Tapped.numberOfTapsRequired = 2;
    Tapped.delegate = self;
    [self.view addGestureRecognizer:Tapped];
}

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

#pragma mark Shake Cell delegate

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if(shaking)
        [self shakeCell];
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if(shaking)
        [self shakeCell];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(shaking)
        [self shakeCell];
}

-(void)shakeCell
{
    shaking = YES ;
    for (int section = 0 ; section < reusableCells.count ; section ++)
    {
        [(HorizontalTableView *)[self.reusableCells  objectAtIndex:section] shakeAnimation];
    }
}

-(void)stopShake
{
    [self stopShaking];
}

-(void)deleteCell
{
    [self performSelector:@selector(shakeCell) withObject:nil afterDelay:0.05];
}

-(void)updateListDelegate
{
    if([[UserDefaults getStringWithKey:NEW_COMIC] integerValue]==1)
        [self UpdateList];
}

-(void)stopShaking
{
    shaking = NO ;
    for (int section = 0 ; section < reusableCells.count ; section ++)
    {
        [(HorizontalTableView *)[self.reusableCells  objectAtIndex:section] stopShaking];
    }
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
    [_logout release];
    [super dealloc];
}
@end
