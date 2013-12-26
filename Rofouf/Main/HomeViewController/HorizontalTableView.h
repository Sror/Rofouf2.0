//
//  FourBooksCell.h
//  Kalimat
//
//  Created by Staff on 4/21/13.
//  Copyright (c) 2013 Staff. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import <StoreKit/StoreKit.h>
#import "BookCell.h"
#import "UserDefaults.h"
#import "Constants.h"
#import "UIImageView+AFNetworking.h"
#import "NetworkService.h"
#import "SSZipArchive.h"
#import "ReaderViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TBXML+Compression.h"
#import "TBXML.h"
#import "AppDelegate.h"

@protocol MyComicCellDelegate <NSObject, UIScrollViewDelegate>
@required
-(void) deleteCell;
-(void) shakeCell;
-(void) stopShake ;
-(void)updateListDelegate;
@end

@interface HorizontalTableView : UITableViewCell <UITableViewDelegate, UITableViewDataSource,ASIHTTPRequestDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver, ReaderViewControllerDelegate>
{
    UITableView *horizontalTableView;
    
    NSArray *comicsArray;
        
    BOOL isLessThan4, shaking;
    
    ASINetworkQueue *networkQueue;
   
    UIViewController *viewController;
    
    id<MyComicCellDelegate> delegate;
    
    int sectionSize ,rowheight, rowWidth, currentSection;
}

@property (nonatomic, retain)  ASINetworkQueue *networkQueue;

@property (nonatomic, assign) id<MyComicCellDelegate> delegate;

@property (nonatomic, retain) UITableView *horizontalTableView;

@property (nonatomic, retain) NSArray *comicsArray;

@property (nonatomic, retain) UIViewController *viewController;


- (id)initWithIsLastCategory:(BOOL)isLastCategory withBook:(NSArray *)books;

- (void)shakeAnimation ;
- (void)stopShaking ;

- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;

@end
