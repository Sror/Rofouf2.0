//
//  HomeViewController.h
//  Rofouf
//
//  Created by Mohamed Alaa El-Din on 12/22/13.
//  Copyright (c) 2013 Mohamed Alaa El-Din. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASINetworkQueue.h"
#import <CommonCrypto/CommonDigest.h>

@interface HomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,ASIHTTPRequestDelegate>
{
    int sectionSize, rowHeight, booksViewsCount, maxBooksPerView, currentView, lastOrientation;
    BOOL shaking, uploading;
    UIPageControl *pageControl;
    NSString *currentOrientation;
    UIProgressView *progressView;
    UILabel *bookUploadingName;
    NSMutableArray *uploadingBooksList;
    ASINetworkQueue *networkQueue;
}
@property (strong, nonatomic) IBOutlet UILabel *rofoufLbl;
@property (strong, nonatomic) IBOutlet UIImageView *bgImg;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (strong, nonatomic) IBOutlet UITableView *rofoufTableView;

@property (strong, nonatomic) NSMutableArray *reusableCells;
@property (strong, nonatomic) NSMutableArray *booksArray;

-(void)getBooks;
@end
