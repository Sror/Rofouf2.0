//
//  AddBooksViewController.h
//  Rofouf
//
//  Created by mohamed.alaa on 12/25/13.
//  Copyright (c) 2013 Mohamed Alaa El-Din. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddBooksViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    int sectionSize, rowHeight, booksViewsCount, maxBooksPerView, currentView, lastOrientation;
    BOOL shaking, uploading;
    UIPageControl *pageControl;
    NSString *currentOrientation;
    UIProgressView *progressView;
    UILabel *bookUploadingName;
    NSMutableArray *uploadingBooksList;
}
@property (strong, nonatomic) IBOutlet UILabel *rofoufLbl;
@property (strong, nonatomic) IBOutlet UIImageView *bgImg;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (strong, nonatomic) IBOutlet UITableView *rofoufTableView;

@property (strong, nonatomic) NSMutableArray *reusableCells;
@property (strong, nonatomic) NSMutableArray *booksArray;

@property (retain, nonatomic) IBOutlet UILabel *chooseLbl;
@end
