//
//  BackgroundApplication.h
//  Keyboard
//
//  Created by Matthias Ringwald on 12/7/09.
//  Copyright 2009 mnm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackgroundApplication : UIApplication {
	bool runInBackground;
}
+ (void) setRunInBackground:(bool) enable;
+ (bool) runInBackground;
@end
