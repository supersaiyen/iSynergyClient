//
//  BackgroundApplication.m
//
//  Created by Matthias Ringwald on 12/7/09.
//  Copyright 2009 mnm. All rights reserved.
//

#import "BackgroundApplication.h"
#import <Foundation/Foundation.h>

// private API of UIApplication
@interface UIApplication (privateAPI)
- (void)applicationWillSuspend;
- (void)applicationDidResume;
- (void)applicationSuspend:(void *)fp8;
- (void)applicationSuspend:(void *)fp8 settings:(id)settings;
- (void)setApplicationBadgeString:(NSString*)fp8; // 3.x
- (void)setApplicationBadge:(NSString*)fp8;       // 2.2
@end

@implementation BackgroundApplication

-(id) init {
	[super init];
	runInBackground = NO;
	return self;
}

#if 0
- (void)applicationWillSuspend {
	if (!runInBackground){
		[super applicationWillSuspend];
	} else {
		// NSLog(@"ignoring applicationWillSuspend");
	}
}

- (void)applicationDidResume{
	if (!runInBackground){
		[super applicationDidResume];
	} else {
		// NSLog(@"ignoring applicationDidResume");
	}
}
#endif

- (void)applicationSuspend:(void *)fp8{
	if (!runInBackground){
		[super applicationSuspend:fp8];
	} else {
		// NSLog(@"ignoring applicationSuspend %@", fp8);
	}
}

#if 0
// not needed yet
- (void)applicationSuspend:(void *)fp8 settings:(id)settings {
	if (!runInBackground){
		[super applicationSuspend:fp8];
	} else {
		NSLog(@"ignoring applicationSuspend %@ settings %@", fp8, settings);
	}
}
#endif

+ (void) setRunInBackground:(bool) enable {
	UIApplication *app = [UIApplication sharedApplication]; 
	if (enable) {
		// @TODO 2.0 <-> 3.x
		if ([app respondsToSelector:@selector(setApplicationBadgeString:)]){
			[app setApplicationBadgeString:@"On"];  // SDK 3.0
		} else if ([app respondsToSelector:@selector(setApplicationBadge:)]) {
			[app setApplicationBadge:@"On"];  // SDK 2.0
		} else {
			[app setApplicationIconBadgeNumber:1];  // SDK ?
		}
	} else {
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	}
	((BackgroundApplication *) [super sharedApplication])->runInBackground = enable;
}

+ (bool) runInBackground {
	return ((BackgroundApplication *) [super sharedApplication])->runInBackground;
}
@end
