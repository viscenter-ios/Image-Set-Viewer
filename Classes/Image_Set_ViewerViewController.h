//
//  Image_Set_ViewerViewController.h
//  Image Set Viewer
//
//  Created by Ryan Baumann on 12/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageScrollView;

@interface Image_Set_ViewerViewController : UIViewController <UIScrollViewDelegate> {
    // UIView *containerView;
    UIScrollView *pagingScrollView;
    UILabel *noImagesLabel;
    
    NSMutableSet *recycledPages;
    NSMutableSet *visiblePages;
    
    NSMutableDictionary *imageSets;
    
    // these values are stored off before we start rotation so we adjust our content offset appropriately during rotation
    int           firstVisiblePageIndexBeforeRotation;
    CGFloat       percentScrolledIntoFirstVisiblePage;
}

@property (nonatomic, retain) IBOutlet UIView *containerView;

- (void)setupTransitionViews;

- (IBAction)nextTransition:(UITapGestureRecognizer *)gestureRecognizer;

- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;

- (void)updateImageSetLibrary;

@end

