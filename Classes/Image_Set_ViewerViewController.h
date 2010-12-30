//
//  Image_Set_ViewerViewController.h
//  Image Set Viewer
//
//  Created by Ryan Baumann on 12/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Image_Set_ViewerViewController : UIViewController {
    UIView *containerView;
    UIScrollView *pagingScrollView;
    
	UIImageView *view1;
	UIImageView *view2;
	BOOL transitioning;
    
    NSMutableDictionary *imageSets;
}

@property (nonatomic, retain) IBOutlet UIView *containerView;

- (void)updateImageSetLibrary;
- (IBAction)nextTransition:(UITapGestureRecognizer *)gestureRecognizer;

- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;

@end

