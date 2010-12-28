//
//  Image_Set_ViewerAppDelegate.h
//  Image Set Viewer
//
//  Created by Ryan Baumann on 12/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Image_Set_ViewerViewController;

@interface Image_Set_ViewerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    Image_Set_ViewerViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet Image_Set_ViewerViewController *viewController;

@end

