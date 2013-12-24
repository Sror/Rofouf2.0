//
//  FourBooksCell.m
//  Kalimat
//
//  Created by Staff on 4/21/13.
//  Copyright (c) 2013 Staff. All rights reserved.
//

#import "HorizontalTableView.h"


#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define kAnimationRotateDeg 0.5
#define kAnimationTranslateX 1
#define kAnimationTranslateY 1

@implementation HorizontalTableView
@synthesize horizontalTableView, comicsArray, viewController, delegate, networkQueue;

#pragma mark initialize TableView

- (NSString *) reuseIdentifier
{
    return @"HorizontalCell";
}


- (id)initWithIsLastCategory:(BOOL)isLastCategory withBook:(NSArray *)books
{
    if ((self = [super init]))
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetRequests:) name:@"resetRequests" object:nil];
        self.comicsArray = [NSArray arrayWithArray:books];
        
        [self initializeTableViewOrientation];
        
        self.horizontalTableView.showsVerticalScrollIndicator   = NO;
        self.horizontalTableView.showsHorizontalScrollIndicator = NO;
        
        self.horizontalTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.horizontalTableView.separatorColor = [UIColor clearColor];
        
        self.horizontalTableView.backgroundColor = [UIColor clearColor];
        self.horizontalTableView.dataSource      = self;
        self.horizontalTableView.delegate        = self;
        self.horizontalTableView.scrollEnabled   = NO;
        
        [self addSubview:self.horizontalTableView];
        
        if (!networkQueue)
            networkQueue = [[ASINetworkQueue alloc] init];
        
        [networkQueue reset];
        [networkQueue setRequestDidFinishSelector:@selector(imageFetchComplete:)];
        [networkQueue setRequestDidFailSelector:@selector(imageFetchFailed:)];
        [networkQueue setShowAccurateProgress: YES];
        [networkQueue setDelegate:self];
        [networkQueue go];
     }
        return self;
}

-(void)initializeTableViewOrientation
{
    if(IS_IPAD)
    {
        if(IS_LANDSCAPE_STATUSBAR)
        {
            sectionSize = 6;
            rowheight = 168;
            self.horizontalTableView           = [[[UITableView alloc] initWithFrame:CGRectMake(16, 48, 206.6, 1024 - 16)] autorelease];
            self.horizontalTableView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
            self.horizontalTableView.frame     = CGRectMake(16, 61.4, 1024 - 16, 206.6);
            self.horizontalTableView.rowHeight = rowheight;
        }
        else
        {
            sectionSize = 4;
            rowheight = 186;
            self.horizontalTableView           = [[[UITableView alloc] initWithFrame:CGRectMake(24, 48, 216, 768 - 24)] autorelease];
            self.horizontalTableView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
            self.horizontalTableView.frame     = CGRectMake(24, 48, 768 - 24, 216);
            self.horizontalTableView.rowHeight = rowheight;
        }
    }
    else
    {
        if(IS_LANDSCAPE_STATUSBAR)
        {
            sectionSize = 4;
            rowheight   = 117;
            rowWidth    = 129.2;
            self.horizontalTableView           = [[[UITableView alloc] initWithFrame:CGRectMake(12, 0, 129.2, 480 - 12)] autorelease];
            self.horizontalTableView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
            self.horizontalTableView.frame     = CGRectMake(12, 0, 480  -12, 129.2);
            self.horizontalTableView.rowHeight = rowheight;
        }
        else
        {
            sectionSize = 2;
            rowheight   = 150;
            rowWidth    = 160;
            self.horizontalTableView           = [[[UITableView alloc] initWithFrame:CGRectMake(20, 0, 160, 320)] autorelease];
            self.horizontalTableView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
            self.horizontalTableView.frame     = CGRectMake(20, 0, 320, 160);
            self.horizontalTableView.rowHeight = rowheight;
        }
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(IBAction)resetRequests:(id)sender
{
    for(ASIHTTPRequest *req in networkQueue.operations)
        [req clearDelegatesAndCancel];
}

#pragma mark gesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)longPressAction:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        [self.delegate shakeCell];
    }
}

#pragma mark Shake cell delegate

-(void)shakeAnimation
{
    shaking = YES ;
    
    NSArray *cellArray = [self.horizontalTableView visibleCells] ;
    for(int i = 0 ; i < cellArray.count ; i++ )
    {
        BookCell *cell = [cellArray objectAtIndex:i];
        if(cell.downloadedImage.hidden && cell.progressView.hidden)
        {
            int count = 1;
            [cell.deleteButton setHidden:NO];
            [cell.deleteButton setSelected:NO];
            [cell bringSubviewToFront:cell.deleteButton];
            
            cell.transform = CGAffineTransformMakeRotation(M_PI * 0.5 );
            
            CGAffineTransform leftWobble =  CGAffineTransformMakeRotation(degreesToRadians( kAnimationRotateDeg * (count%2 ? 1 :-1 ) ));
            CGAffineTransform rightWobble = CGAffineTransformMakeRotation(degreesToRadians( kAnimationRotateDeg * (count%2 ? -1 : 1 ) ));
            CGAffineTransform moveTransform =  CGAffineTransformTranslate(rightWobble, -kAnimationTranslateX, -kAnimationTranslateY);
            CGAffineTransform conCatTransform =  CGAffineTransformConcat(rightWobble,moveTransform);
            
            cell.cellView.transform = CGAffineTransformIdentity ;
            [cell.cellView.layer removeAllAnimations];
            cell.cellView.transform = leftWobble  ;
            
            [UIView animateWithDuration:0.13
                                  delay:(count*i * 0.04)
                                options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat |UIViewAnimationOptionAutoreverse
                             animations:^{
                                 cell.cellView.transform = conCatTransform ;
                             }
                             completion:nil];
        }
    }
}

-(void)stopShaking
{
    shaking = NO ;
    NSArray *cellArray =[self.horizontalTableView visibleCells] ;
    
    for(int i = 0 ; i < cellArray.count ; i++ )
    {
        BookCell *cell = [cellArray objectAtIndex:i];
        [cell.cellView.layer removeAllAnimations];
        cell.cellView.transform = CGAffineTransformIdentity;
        cell.deleteButton.hidden = YES ;
    }
}

-(IBAction)askForDeleteBook:(UISwipeGestureRecognizer *)sender
{
    [self.delegate shakeCell];
}

-(void)deleteButtonPressed:(UIButton *)sender
{
    BookCell *cell = nil;
    if( [[UIDevice currentDevice] systemVersion].intValue  < 7)
        cell = (BookCell *)[[[sender superview] superview] superview];
    else
        cell = (BookCell *)[[[[sender superview] superview] superview] superview];
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"هل ترغب في حذف هذا الكرتون؟" delegate:self cancelButtonTitle:@"لا" otherButtonTitles:@"نعم",nil];
    NSIndexPath *indexPath = [self.horizontalTableView indexPathForCell:cell ];
    alertView.tag = indexPath.row;
    [alertView show];
    [alertView release];
}

#pragma mark Horizontal Table delgate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowheight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    if ([self.comicsArray count] < sectionSize)
    {
        isLessThan4 = YES;
        tableView.scrollEnabled = NO;
        return sectionSize;
    }
    return [self.comicsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookCell";
    __block BookCell *cell   = (BookCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    __block int currentIndex = sectionSize - 1 - indexPath.row;
    
    if (cell == nil)
        cell = [[[BookCell alloc] init] autorelease];
    
    if (!isLessThan4 || (sectionSize - indexPath.row <= [self.comicsArray count]))
    {
        [self loadCellsContents:cell:currentIndex];
    }
    else
        cell.hidden=YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(shaking)
    {
        shaking = NO ;
        [self.delegate stopShake];
        return ;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSDictionary *currentComic=nil;
    currentComic = [self.comicsArray objectAtIndex:sectionSize-1-indexPath.row];
    
    [self read:indexPath];
    
    /*if (![UserDefaults isComicDwonloadedWithID:[currentComic objectForKey:@"ComicId"]] && ![UserDefaults isCommicDownloadingWithID:[currentComic objectForKey:@"ComicId"]])
    {
        int rowIndex = indexPath.row;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"هل ترغب في تحميل كرتون %@؟",[currentComic objectForKey:@"title"]] delegate:self cancelButtonTitle:@"لا" otherButtonTitles:@"نعم",nil];
        alertView.tag = rowIndex;
        [alertView show];
        [alertView release];
    }
    else
    {
        ReaderViewController *readerViewController;
        if(IS_IPAD)
            readerViewController = [[ReaderViewController alloc] initWithNibName:@"ReaderViewController~ipad" bundle:nil];
        else
            readerViewController = [[ReaderViewController alloc] initWithNibName:@"ReaderViewController~iphone" bundle:nil];
        
        readerViewController.IDString = [currentComic objectForKey:@"ComicId"];
        [self.viewController.navigationController pushViewController:readerViewController animated:YES];
        [readerViewController release];
    }*/
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] systemVersion].intValue == 7)
        [cell setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundColor:[UIColor clearColor]];
}

-(void)loadCellsContents:(BookCell *)cell :(int)currentIndex
{
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(concurrentQueue, ^
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          __block NSDictionary *currentComic = [self.comicsArray objectAtIndex:currentIndex];
                                          
                                         /* if([UserDefaults isCommicDownloadingWithID:[currentComic objectForKey:@"ComicId"]])
                                          {
                                              cell.progressView.hidden    = NO;
                                              cell.userInteractionEnabled = NO;
                                              
                                              NSString * bname = [NSString stringWithFormat:@"%@.zip",[currentComic objectForKey:@"ComicId"]];
                                              
                                              ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[currentComic objectForKey:@"Url"]]];
                                              [request setDelegate:self];
                                              [request setDownloadDestinationPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:bname]];
                                              [request setTemporaryFileDownloadPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.download",bname]]];
                                              [request setDownloadProgressDelegate:cell.progressView];
                                             // [request setShowAccurateProgress:YES];
                                              [request setAllowResumeForFileDownloads:YES];
                                              [request setShouldContinueWhenAppEntersBackground:YES];
                                              [request setUserInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",currentIndex] forKey:@"name"]];
                                              [networkQueue addOperation:request];
                                          }
                                          else
                                          {
                                              cell.progressView.hidden    = YES;
                                              cell.userInteractionEnabled = YES;
                                          }
                                          
                                          if ([UserDefaults isComicDwonloadedWithID:[currentComic objectForKey:@"ComicId"]] && ![UserDefaults isCommicDownloadingWithID:[currentComic objectForKey:@"ComicId"]])
                                          {
                                              UISwipeGestureRecognizer* rightSwipeRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(askForDeleteBook:)] autorelease];
                                              [rightSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
                                              
                                              UISwipeGestureRecognizer* leftSwipeRecognizer  = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(askForDeleteBook:)] autorelease];
                                              [leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
                                              
                                              UILongPressGestureRecognizer *tapRecognizer    = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
                                              tapRecognizer.delegate = self;
                                              
                                              [cell addGestureRecognizer:rightSwipeRecognizer];
                                              [cell addGestureRecognizer:leftSwipeRecognizer];`
                                              [cell addGestureRecognizer:tapRecognizer];
                                              [cell.deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                                              [cell.downloadedImage setHidden:YES];
                                          
                                          }
                                          else
                                              cell.downloadedImage.hidden = NO;
                                          
                                          NSString *thumbName = [NSString stringWithFormat:@"%@",[currentComic objectForKey:@"thumb"]];
                                          NSData *thumbImg    = [UserDefaults getDataWithName:[NSString stringWithFormat:@"%@t%@",[currentComic objectForKey:@"LastModifiedDate"],[[thumbName componentsSeparatedByString:@"/"] lastObject]] inRelativePath:@"Thumbnail"];
                                          
                                          if (thumbImg)
                                              [cell.thumbnail setImage:[UIImage imageWithData:thumbImg]];
                                          else
                                              [cell.thumbnail setImageWithURL:[NSURL URLWithString:[thumbName stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]] Date:[currentComic objectForKey:@"LastModifiedDate"]];*/
                                          
                                           [cell.thumbnail setImage:[UIImage imageWithData:[[currentComic valueForKey:@"bThumbinal"] objectAtIndex:0]]];
                                          //[cell.thumbnail setImage:[UIImage imageNamed:@"sample.png"]];
                                          NSString *bookName = [[currentComic valueForKey:@"bName"] objectAtIndex:0];
                                          [cell.cellTitle setText:bookName];
                                          
                                      });
                   });
}


#pragma mark alerts

-(void)showAlert
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"معذرة، حدث خطأ في تحميل الكرتون، برجاء إعادة التحميل في وقت أخر" delegate:self cancelButtonTitle:@"إلغاء" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    
    int downloadCountNO = [[UserDefaults getStringWithKey:Downlaod_Count ]  integerValue ];
    downloadCountNO --;
    [UserDefaults  addObject:[NSString stringWithFormat:@"%d",downloadCountNO] withKey:Downlaod_Count ifKeyNotExists:NO];
    
    if(downloadCountNO == 0 )
        [self.delegate updateListDelegate];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (!shaking)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:alertView.tag inSection:0];
            [self read:indexPath];
            /* if ([[NetworkService getObject] checkInternetWithData])
             {
             
             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:alertView.tag inSection:0];
             BookCell *cell = (BookCell *)[self.horizontalTableView cellForRowAtIndexPath:indexPath];
             cell.userInteractionEnabled = NO;
             cell.progressView.hidden    = NO;
             int rowIndex = sectionSize-1-indexPath.row;
             
             NSDictionary *currentBook = [self.comicsArray objectAtIndex:rowIndex];
             ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[currentBook objectForKey:@"Url"]]];  //
             request.delegate = self;
             NSString * bname = [NSString stringWithFormat:@"%@.zip",[currentBook objectForKey:@"ComicId"]];
             [request setDownloadDestinationPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:bname]];
             [request setTemporaryFileDownloadPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.download",bname]]];
             [request setDownloadProgressDelegate:cell.progressView];
             [request setAllowResumeForFileDownloads:YES];
             [request setShouldContinueWhenAppEntersBackground:YES];
             [request setUserInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",rowIndex] forKey:@"name"]];
             [networkQueue addOperation:request];
             
             [UserDefaults addDownloadingComicWithID:[[self.comicsArray objectAtIndex:rowIndex] objectForKey:@"ComicId"]];
             
             NSString *downloadCount = [UserDefaults getStringWithKey:Downlaod_Count] ;
             int downloadCountNO = [downloadCount integerValue ];
             downloadCountNO ++;
             [UserDefaults  addObject:[NSString stringWithFormat:@"%d",downloadCountNO] withKey:Downlaod_Count ifKeyNotExists:NO];
             }
             else
             {
             UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"معذرة لا يمكنك تحميل الكرتون في الوقت الحالي؛ نظرًا لتعذر الاتصال بالإنترنت" delegate:self cancelButtonTitle:@"إلغاء" otherButtonTitles:nil];
             [alertView show];
             [alertView release];
             }*/
        }
        else
        {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:alertView.tag inSection:0];
            BookCell *cell = (BookCell *)[self.horizontalTableView cellForRowAtIndexPath:indexPath];
            int rowIndex   = sectionSize-1-indexPath.row;
            
            [UserDefaults deleteItemsAtPath:[NSString stringWithFormat:@"%@.zip",[[self.comicsArray objectAtIndex:rowIndex]objectForKey:@"ComicId"]]];
            [UserDefaults deleteItemsAtPath:[NSString stringWithFormat:@"%@",[[self.comicsArray objectAtIndex:rowIndex]objectForKey:@"ComicId"]]];
            [UserDefaults removeComicWithID:[[self.comicsArray objectAtIndex:rowIndex]objectForKey:@"ComicId"]];
            [UserDefaults addObject:nil withKey:[[self.comicsArray objectAtIndex:rowIndex]objectForKey:@"ComicId"] ifKeyNotExists:NO];
            
            cell.deleteButton.hidden    = YES ;
            cell.downloadedImage.hidden = NO ;
            
            [cell.cellView.layer removeAllAnimations];
            cell.cellView.transform = CGAffineTransformIdentity;
        }
    }
}


#pragma mark reader
- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
    
    [self.navigationController popViewControllerAnimated:YES];
    
#else // dismiss the modal view controller
    
    [self.viewController dismissViewControllerAnimated:YES completion:NULL];
    
#endif // DEMO_VIEW_CONTROLLER_PUSH
}


-(void)read:(NSIndexPath *)indexPath
{
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
	unsigned long cellIndex = sectionSize-1-indexPath.row ;
    
	NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Inbox"] stringByAppendingPathComponent:[[[self.comicsArray objectAtIndex:cellIndex] valueForKey:@"bName"] objectAtIndex:0]];
    
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];
    
	if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
	{
		ReaderViewController *readerViewController = [[[ReaderViewController alloc] initWithReaderDocument:document] autorelease];
        
		readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        
#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
        
        [self.navigationController pushViewController:readerViewController animated:YES];
        
#else // present in a modal view controller
        
        readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self.viewController presentViewController:readerViewController animated:YES completion:NULL];
        
#endif // DEMO_VIEW_CONTROLLER_PUSH
	}
}



#pragma mark In App Purshace
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    NSArray *myProduct = response.products;
    //Since only one product, we do not need to choose from the array. Proceed directly to payment.
    SKPayment *newPayment = [SKPayment paymentWithProduct:[myProduct objectAtIndex:0]];
    [[SKPaymentQueue defaultQueue] addPayment:newPayment];
    [request autorelease];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Unsuccessful"
                                                        message:@"Your purchase failed. Please try again."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

#pragma mark ASIHTTPREQUEST delegate

- (void)imageFetchComplete:(ASIHTTPRequest *)request
{
    NSString *index       = [request.userInfo objectForKey:@"name"];
    int indexInArray      = index.intValue;
    int currentIndexInRow = sectionSize-1-indexInArray;
    
    NSDictionary *recordDict = [self.comicsArray objectAtIndex:indexInArray];

    NSArray  *paths              = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *outputPath         = [documentsDirectory stringByAppendingPathComponent:@""];
    
    NSString * bname  = [NSString stringWithFormat:@"%@.zip",[recordDict objectForKey:@"ComicId"]];
    NSString *zipPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:bname];
    [SSZipArchive unzipFileAtPath:zipPath toDestination:outputPath];
    
    [UserDefaults removeDownloadingComicWithID:[recordDict objectForKey:@"ComicId"]];
    [UserDefaults addComicWithID:[recordDict objectForKey:@"ComicId"]];
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentIndexInRow inSection:0];
    BookCell *cell = (BookCell *)[self.horizontalTableView cellForRowAtIndexPath:indexPath];
    cell.userInteractionEnabled = YES;
    cell.progressView.hidden    = YES;
    cell.downloadedImage.hidden = YES;
    
    UISwipeGestureRecognizer* rightSwipeRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(askForDeleteBook:)] autorelease];
    [rightSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    UISwipeGestureRecognizer* leftSwipeRecognizer  = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(askForDeleteBook:)] autorelease];
    [leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    
    UILongPressGestureRecognizer *tapRecognizer    = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    tapRecognizer.delegate = self;
    
    [cell.deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [cell addGestureRecognizer:rightSwipeRecognizer];
    [cell addGestureRecognizer:leftSwipeRecognizer];
    [cell addGestureRecognizer:tapRecognizer];
    
    int downloadCountNO = [[UserDefaults getStringWithKey:Downlaod_Count ]  integerValue ];
    downloadCountNO --;
    [UserDefaults  addObject:[NSString stringWithFormat:@"%d",downloadCountNO] withKey:Downlaod_Count ifKeyNotExists:NO];
    
    if(downloadCountNO == 0 )
        [self.delegate updateListDelegate];
}


- (void)imageFetchFailed:(ASIHTTPRequest *)request
{
    int indexInArray      = [[request.userInfo objectForKey:@"name"] intValue];
    int currentIndexInRow = sectionSize-1-indexInArray;
    
    NSDictionary *recordDict = [self.comicsArray objectAtIndex:indexInArray];
    NSIndexPath  *indexPath  = [NSIndexPath indexPathForRow:currentIndexInRow inSection:0];
    BookCell *cell = (BookCell *)[self.horizontalTableView cellForRowAtIndexPath:indexPath];
    cell.userInteractionEnabled = YES;
    cell.progressView.hidden    = YES;
    cell.downloadedImage.hidden = NO;
    
    [UserDefaults removeDownloadingComicWithID:[recordDict objectForKey:@"ComicId"]];
    [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
}




@end
