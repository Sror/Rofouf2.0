

#import <UIKit/UIKit.h>

@class ArticleTitleLabel;

@interface BookCell : UITableViewCell
{
    UIImageView *thumbnail, *downloadedImage;
    
    UIProgressView *progressView;
    
    UIButton *deleteButton ; 
    
    UIActivityIndicatorView *indicatorView;
}

@property (nonatomic, retain) UILabel *cellTitle;
@property (nonatomic, retain) UIImageView *thumbnail;
@property (nonatomic, retain) UIImageView *downloadedImage;

@property (nonatomic, retain) UIProgressView *progressView;

@property (nonatomic, retain) UIButton *deleteButton ;

@property (nonatomic, retain) UIActivityIndicatorView *indicatorView;

@property (nonatomic, retain) UIView *cellView ;
@end
