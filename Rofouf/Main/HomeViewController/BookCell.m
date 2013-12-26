

#import "BookCell.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "UsageData.h"

@implementation BookCell
@synthesize progressView, downloadedImage, indicatorView, deleteButton, cellView, thumbnail, cellTitle, selectedFlag;

#pragma mark - View Lifecycle
- (NSString *)reuseIdentifier
{
    return @"BookCell";
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(IS_IPAD)
    {
        if(IS_LANDSCAPE_STATUSBAR)
            self.cellView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 152 , 206.6)] autorelease];
        else
            self.cellView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 162 , 216)] autorelease];
    }
    else
        self.cellView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 130 , 160)] autorelease];
    
    self.indicatorView  = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(71, 132, 20, 20)] autorelease];
    indicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
    indicatorView.color = [UIColor blackColor];
    [self.indicatorView stopAnimating];
    self.indicatorView.hidden = YES;
    
    
    if(IS_IPAD)
    {
        if(IS_LANDSCAPE_STATUSBAR)
        {
            self.thumbnail = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 152, 202.6)] autorelease];
            self.progressView=[[UIProgressView alloc] initWithFrame:CGRectMake(6, 191.6, 139, 9)];
            self.downloadedImage = [[[UIImageView alloc] initWithFrame:CGRectMake(5, 3, 32, 22)] autorelease];
             self.cellTitle = [[[UILabel alloc] initWithFrame:CGRectMake(6, 180, 150, 22)] autorelease];
        }
        else
        {
            self.thumbnail = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 162, 216)] autorelease];
            self.progressView=[[[UIProgressView alloc] initWithFrame:CGRectMake(12, 201, 139, 9)] autorelease];
            self.downloadedImage = [[[UIImageView alloc] initWithFrame:CGRectMake(5, 6, 32, 22)] autorelease];
            self.cellTitle = [[[UILabel alloc] initWithFrame:CGRectMake(6, 180, 160, 22)] autorelease];
        }
    }
    else
    {
        if(IS_LANDSCAPE_STATUSBAR)
            self.thumbnail = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 105, 129.2)] autorelease];
        else
            self.thumbnail = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 130, 160)] autorelease];
        
        self.cellTitle = [[[UILabel alloc] initWithFrame:CGRectMake(6, 130, 130, 22)] autorelease];
        self.downloadedImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 32, 22)] autorelease];
        self.progressView    = [[[UIProgressView alloc] initWithFrame:CGRectMake(12, 145, 107, 9)] autorelease];
    }
    
    self.cellTitle.backgroundColor = [UIColor clearColor];
    self.cellTitle.textColor = [UIColor blackColor];
    self.cellTitle.textAlignment = NSTextAlignmentCenter;
    
    self.thumbnail.opaque = YES;
  
    [self.downloadedImage setImage:[UIImage imageNamed:@"Cloud.png"]];
    self.downloadedImage.opaque = YES;
    self.downloadedImage.hidden=YES;
    self.downloadedImage.tag=1;
    
    if([UsageData getiOSVersion] >= 7)
    {
        [self.progressView setTintColor:[UIColor colorWithRed:73.0f/255.0f green:164.0f/255.0f blue:255.0f/255.0f alpha:1]];
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.44f);
        progressView.transform =  CGAffineTransformRotate(transform, 3.14);
    }
    else
        progressView.transform = CGAffineTransformMakeRotation(3.14);
    
    self.progressView.tag=2;
    self.progressView.hidden=YES;
    
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateHighlighted];
    if(IS_LANDSCAPE_STATUSBAR)
        deleteButton.frame = CGRectMake(-5, -5, 46, 46);
    else
        deleteButton.frame = CGRectMake(-1 , -5, 46, 46);
    
    self.deleteButton.tag = 4 ;
    [deleteButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
    deleteButton.hidden = YES ;
    
    [self.contentView addSubview:self.cellView];
    [self.cellView addSubview:self.indicatorView];
    [self.cellView addSubview:self.thumbnail];
    [self.cellView addSubview:self.progressView];
    [self.cellView addSubview:self.downloadedImage];
    [self.cellView addSubview:self.cellTitle];
    [self.cellView addSubview:self.indicatorView];
    
    
 
    
    [self.cellView addSubview:self.deleteButton];
    
    self.backgroundColor = [UIColor clearColor];
    self.selectedBackgroundView = [[[UIView alloc] initWithFrame:self.thumbnail.frame] autorelease];
    self.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];
    

    if(((AppDelegate *)[UIApplication sharedApplication].delegate).itunesFlag == 1 && !selectedFlag)
    {
        for(UIView *subview in [self.cellView subviews])
        {
            if([subview isKindOfClass:[UIImageView class]])
            {
                [[self.cellView viewWithTag:10]removeFromSuperview];
            }
        }
    }
    else if (((AppDelegate *)[UIApplication sharedApplication].delegate).itunesFlag == 1 && selectedFlag)
    {
        UIImageView *selectedImage = [[UIImageView alloc] initWithFrame:self.thumbnail.frame];
        selectedImage.tag = 10;
        selectedImage.image = [UIImage imageNamed:@"selected.png"];
        [self.cellView addSubview:selectedImage];
    }
   
    
    // Configure the view for the selected state
}
#pragma mark - Memory Management

- (void)dealloc
{
    [super dealloc];
}

@end
