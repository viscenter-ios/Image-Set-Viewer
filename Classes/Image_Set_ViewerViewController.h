//
//  Image_Set_ViewerViewController.h
//  Image Set Viewer
//
//  Created by Ryan Baumann on 12/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Image_Set_ViewerViewController : UIViewController {
    NSMutableDictionary *imageSets;
}

- (void)updateImageSetLibrary;

@end

