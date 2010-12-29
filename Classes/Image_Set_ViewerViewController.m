//
//  Image_Set_ViewerViewController.m
//  Image Set Viewer
//
//  Created by Ryan Baumann on 12/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Image_Set_ViewerViewController.h"

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
- (void)loadView {
    [self updateImageSetLibrary];
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
    [super dealloc];
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
    NSMutableArray *filePaths = [NSMutableArray arrayWithCapacity:[fileNames count]];
    for (NSString * fileName in fileNames) {
		if ([fileName rangeOfString:@"[_]\\d+\\.(tiff|tif|jpeg|jpg|png|gif|bmp)$" options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].length != 0) {
            [filePaths addObject:[directoryPath stringByAppendingPathComponent:fileName]];
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
    //[[MLMediaLibrary sharedMediaLibrary] addFilePaths:filePaths];
	//[self.movieListViewController reloadMedia];
}


@end
