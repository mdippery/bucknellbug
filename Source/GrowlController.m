/*
 * GrowlController.m
 * Copyright (c) 2006-2007 Michael Dippery <mdippery@bucknell.edu>
 *
 * All rights reserved. This file is licensed under the Creative Commons
 * Attribution-NonCommercial-ShareAlike license, v2.5. You may use this file so
 * long as you follow the guidelines in the license. You may obtain a copy of the
 * license at
 *
 *     http://creativecommons.org/licenses/by-nc-sa/2.5/legalcode
 */

#import <Growl/Growl.h>
#import "GrowlController.h"


NSString * const kBBGrowlWeatherUpdated = @"Weather updated";

@interface GrowlController (Private)
- (void)registerWithGrowl;
@end

@implementation GrowlController

static GrowlController *sharedGrowlController = nil;

+ (GrowlController *)sharedController
{
	if (!sharedGrowlController) sharedGrowlController = [[self alloc] init];
	return sharedGrowlController;
}

+ (id)allocWithZone:(NSZone *)zone
{
	// Overriden to prevent instance from being manually created
	if (!sharedGrowlController) {
		sharedGrowlController = [super allocWithZone:zone];
		return sharedGrowlController;	// Return on first allocation
	}
	
	return nil;		// On subsequent allocation attempts return nil
}

- (id)init
{
	if ([super init] == nil) return nil;
	
	//NSLog(@"Initializing BBGrowlController instance");
	[self registerWithGrowl];
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (unsigned int)retainCount
{
	return UINT_MAX;	// Denotes an object that should be not released
}

- (oneway void)release {}

- (id)autorelease
{
	return self;
}

- (void)registerWithGrowl
{
	static BOOL registered = NO;
	
	if (!registered) {
		[GrowlApplicationBridge setGrowlDelegate:self];
		//NSLog(@"Registering with Growl");
		registered = YES;
	}
}

- (NSDictionary *)registrationDictionaryForGrowl
{
	NSArray			*notifications;
	NSDictionary	*growl;
	
	notifications = [[NSArray alloc] initWithObjects:kBBGrowlWeatherUpdated, nil];
	
	growl = [NSDictionary dictionaryWithObjectsAndKeys:
		notifications, GROWL_NOTIFICATIONS_ALL,
		notifications, GROWL_NOTIFICATIONS_DEFAULT,
		nil];
	
	[notifications release];
	
	//NSLog(@"Returning Growl registration dictionary:\n%@", growl);
	
	return growl;
}

- (NSString *)applicationNameForGrowl
{
	//return NSLocalizedString(@"BucknellBug", nil);
	return @"BucknellBug";		// Name should be static, don't localize
}

@end
