//
//  Image_Set_ViewerViewController.m
//  Image Set Viewer
//
//  Created by Ryan Baumann on 12/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Image_Set_ViewerViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation Image_Set_ViewerViewController

@synthesize containerView;

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
- (void)loadView {
    [self updateImageSetLibrary];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    containerView = [[UIView alloc] initWithFrame:bounds];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    NSString *filePath = [[imageSets objectForKey:[[imageSets allKeys] objectAtIndex:1]] objectAtIndex:0];
    NSLog(@"Loading %@", filePath);
    
    view1 = [[UIImageView alloc] initWithFrame:bounds];
    view1.contentMode = UIViewContentModeScaleAspectFit;
    view1.backgroundColor = [UIColor blackColor];
    view1.image = [UIImage imageWithContentsOfFile:filePath];
    view1.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [containerView addSubview:view1];
    
    filePath = [[imageSets objectForKey:[[imageSets allKeys] objectAtIndex:1]] objectAtIndex:1];
    NSLog(@"Loading %@", filePath);
    
    view2 = [[UIImageView alloc] initWithFrame:bounds];
    view2.contentMode = UIViewContentModeScaleAspectFit;
    view2.backgroundColor = [UIColor blackColor];
    view2.image = [UIImage imageWithContentsOfFile:filePath];
    view2.hidden = YES;
    view2.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [containerView addSubview:view2];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(nextTransition:)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    [containerView addGestureRecognizer: tapGesture];
    [tapGesture release];
    
    transitioning = NO;
    
    self.view = containerView;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
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
    [containerView release];
    [view1 release];
	[view2 release];
    [imageSets release];
    [super dealloc];
}

-(void)performTransition
{
    NSLog(@"Transitioning");
	// First create a CATransition object to describe the transition
	CATransition *transition = [CATransition animation];
	// Animate over 3/4 of a second
	transition.duration = 0.75;
	// using the ease in/out timing function
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

	transition.type = kCATransitionFade;
	
	// Finally, to avoid overlapping transitions we assign ourselves as the delegate for the animation and wait for the
	// -animationDidStop:finished: message. When it comes in, we will flag that we are no longer transitioning.
	transitioning = YES;
	transition.delegate = self;
	
	// Next add it to the containerView's layer. This will perform the transition based on how we change its contents.
	[containerView.layer addAnimation:transition forKey:nil];
	
	// Here we hide view1, and show view2, which will cause Core Animation to animate view1 away and view2 in.
	view1.hidden = YES;
	view2.hidden = NO;
	
	// And so that we will continue to swap between our two images, we swap the instance variables referencing them.
	UIImageView *tmp = view2;
	view2 = view1;
	view1 = tmp;
}

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	transitioning = NO;
}

-(IBAction)nextTransition:(UITapGestureRecognizer *)gestureRecognizer
{
    NSLog(@"Tapped");
	if(!transitioning)
	{
		[self performTransition];
	}
}

// skeleton taken from MobileVLC
- (void)updateImageSetLibrary {
#if TARGET_IPHONE_SIMULATOR
    NSString *directoryPath = @"/Users/ryan/work/dss/iOS";
#else
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directoryPath = [paths objectAtIndex:0];
#endif
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
}


@end
