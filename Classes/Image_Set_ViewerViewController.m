//
//  Image_Set_ViewerViewController.m
//  Image Set Viewer
//
//  Created by Ryan Baumann on 12/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Image_Set_ViewerViewController.h"
#import "ImageScrollView.h"

#import <QuartzCore/QuartzCore.h>

@implementation Image_Set_ViewerViewController

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{    
    // From Apple PhotoScroller example
    // Step 1: make the outer paging scroll view
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
    pagingScrollView.pagingEnabled = YES;
    pagingScrollView.backgroundColor = [UIColor blackColor];
    pagingScrollView.showsVerticalScrollIndicator = NO;
    pagingScrollView.showsHorizontalScrollIndicator = YES;
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    pagingScrollView.delegate = self;
    
    //containerView = [[UIView alloc] initWithFrame:bounds];
    //containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //containerView.backgroundColor = [UIColor blackColor];
    
    self.view = pagingScrollView;
    
    // Step 2: prepare to tile content
    recycledPages = [[NSMutableSet alloc] init];
    visiblePages  = [[NSMutableSet alloc] init];
    
    [self tilePages];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

#pragma mark -
#pragma mark View controller rotation methods

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // here, our pagingScrollView bounds have not yet been updated for the new interface orientation. So this is a good
    // place to calculate the content offset that we will need in the new orientation
    CGFloat offset = pagingScrollView.contentOffset.x;
    CGFloat pageWidth = pagingScrollView.bounds.size.width;
    
    if (offset >= 0) {
        firstVisiblePageIndexBeforeRotation = floorf(offset / pageWidth);
        percentScrolledIntoFirstVisiblePage = (offset - (firstVisiblePageIndexBeforeRotation * pageWidth)) / pageWidth;
    } else {
        firstVisiblePageIndexBeforeRotation = 0;
        percentScrolledIntoFirstVisiblePage = offset / pageWidth;
    }    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // recalculate contentSize based on current orientation
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    
    // adjust frames and configuration of each visible page
    for (ImageScrollView *page in visiblePages) {
        CGPoint restorePoint = [page pointToCenterAfterRotation];
        CGFloat restoreScale = [page scaleToRestoreAfterRotation];
        page.frame = [self frameForPageAtIndex:page.index];
        [page setMaxMinZoomScalesForCurrentBounds];
        [page restoreCenterPoint:restorePoint scale:restoreScale];
        
    }
    
    // adjust contentOffset to preserve page location based on values collected prior to location
    CGFloat pageWidth = pagingScrollView.bounds.size.width;
    CGFloat newOffset = (firstVisiblePageIndexBeforeRotation * pageWidth) + (percentScrolledIntoFirstVisiblePage * pageWidth);
    pagingScrollView.contentOffset = CGPointMake(newOffset, 0);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    //[containerView release];
    [pagingScrollView release];
    //[view1 release];
	//[view2 release];
    [imageSets release];
    [super dealloc];
}

#pragma mark -
#pragma mark Tiling and page configuration

- (void)tilePages
{
    if (noImagesLabel != nil) {
        [noImagesLabel removeFromSuperview];
        [noImagesLabel release];
        noImagesLabel = nil;
    }
    
    CGRect visibleBounds = pagingScrollView.bounds;
    
    if (imageSets.count > 0) {
        // Calculate which pages are visible
        int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
        int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
        firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
        lastNeededPageIndex  = MIN(lastNeededPageIndex, imageSets.count - 1);
        
        //NSLog(@"Tiling pages %i to %i", firstNeededPageIndex, lastNeededPageIndex);
        
        // Recycle no-longer-visible pages
        for (ImageScrollView *page in visiblePages) {
            if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
                [recycledPages addObject:page];
                [page removeFromSuperview];
            }
        }
        [visiblePages minusSet:recycledPages];
        
        // add missing pages
        for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
            if (![self isDisplayingPageForIndex:index]) {
                ImageScrollView *page = [self dequeueRecycledPage];
                if (page == nil) {
                    page = [[[ImageScrollView alloc] init] autorelease];
                }
                [self configurePage:page forIndex:index];
                [pagingScrollView addSubview:page];
                [visiblePages addObject:page];
            }
        }
    }
    else {
        // no pages
        noImagesLabel = [[UILabel alloc] initWithFrame:CGRectMake(visibleBounds.size.width * 0.05, 0, visibleBounds.size.width * 0.9, visibleBounds.size.height)];
        noImagesLabel.text = @"No images found. To add images:\n - Connect your device to iTunes\n - In iTunes, select your device, and then click the Apps tab\n - Below File Sharing, select \"Image Set Viewer\" from the list, and then click Add.\n  - In the window that appears, select a file to transfer, and then click Choose.\nImages must have a filename ending with an underscore followed by digits, e.g. Image1_001.jpg, Image1_002.jpg, etc. Images with the same prefix are collected into a set.";
        noImagesLabel.backgroundColor = [UIColor clearColor];
        noImagesLabel.textColor = [UIColor whiteColor];
        noImagesLabel.shadowColor = [UIColor grayColor];
        noImagesLabel.shadowOffset = CGSizeMake(1,1);
        noImagesLabel.font = [UIFont systemFontOfSize:24];
        noImagesLabel.lineBreakMode = UILineBreakModeWordWrap;
        noImagesLabel.numberOfLines = 0;
        noImagesLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [pagingScrollView addSubview:noImagesLabel];
    }
}

- (ImageScrollView *)dequeueRecycledPage
{
    ImageScrollView *page = [recycledPages anyObject];
    if (page) {
        [[page retain] autorelease];
        [recycledPages removeObject:page];
    }
    return page;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    for (ImageScrollView *page in visiblePages) {
        if (page.index == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

- (void)configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index
{
    page.index = index;
    page.frame = [self frameForPageAtIndex:index];
    
    [page displayImageSet:[imageSets objectForKey:[[imageSets allKeys] objectAtIndex:index]]];
    
    // Use tiled images
    //[page displayTiledImageNamed:[self imageNameAtIndex:index]
    //                        size:[self imageSizeAtIndex:index]];
    
    // To use full images instead of tiled images, replace the "displayTiledImageNamed:" call
    // above by the following line:
    // [page displayImage:[self imageAtIndex:index]];
}

#pragma mark -
#pragma mark ScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self tilePages];
}

#pragma mark -
#pragma mark  Frame calculations
#define PADDING  10

- (CGRect)frameForPagingScrollView {
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * imageSets.count, bounds.size.height);
}

#pragma mark -
#pragma mark Image Wrangling

// skeleton taken from MobileVLC
- (void)updateImageSetLibrary {
#if TARGET_IPHONE_SIMULATOR
    NSString *directoryPath = @"/Users/ryan/work/dss/iOS";
#else
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directoryPath = [paths objectAtIndex:0];
#endif
    if (imageSets != nil) {
        [imageSets release];
    }
    imageSets = [[NSMutableDictionary alloc] init];
    
    NSLog(@"Scanning %@", directoryPath);
    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
    for (NSString * fileName in fileNames) {
		if ([fileName rangeOfString:@"[_]\\d+\\.(tiff|tif|jpeg|jpg|png|gif|bmp)$" options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].length != 0) {
            NSLog(@"Found %@", fileName);
            NSString *filePrefix = [fileName substringToIndex:([fileName rangeOfString:@"_" options:NSBackwardsSearch].location)];
            NSLog(@"Prefix %@", filePrefix);
            if ([imageSets objectForKey:filePrefix] == nil) {
                // dictionary doesn't have this prefix yet, alloc an array and set it
                [imageSets setObject:[NSMutableArray array] forKey:filePrefix];
            }
            // add the file path to the prefix's key
            NSMutableArray *fileArray = [imageSets objectForKey:filePrefix];
            [fileArray addObject:[directoryPath stringByAppendingPathComponent:fileName]];
        }
    }
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];

    [self tilePages];
}

@end
