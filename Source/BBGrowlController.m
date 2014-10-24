/*
 * BBGrowlController.m
 * Copyright (c) 2006-2007 Michael Dippery <mdippery@bucknell.edu>
 *
 * All rights reserved. This file is licensed under the Creative Commons
 * Attribution-NonCommercial-ShareAlike license, v2.5. You may use this file so
 * long as you follow the guidelines in the license. You may obtain a copy of the
 * license at
 *
 *     http://creativecommons.org/licenses/by-nc-sa/2.5/legalcode
 */

#import "BBGrowlController.h"

NSString * const kBBGrowlWeatherUpdated = @"Weather updated";

@interface BBGrowlController (Private)
- (void)registerWithGrowl;
@end

@implementation BBGrowlController

static BBGrowlController *sharedGrowlController = nil;

+ (BBGrowlController *)sharedController
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
	if ((self = [super init]) != nil) {
		[self registerWithGrowl];
	}
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
	[GrowlApplicationBridge setGrowlDelegate:self];
}

- (void)postGrowlNotificationWithTitle:(NSString *)title
						   description:(NSString *)description
					  notificationName:(NSString *)notificationName
							  iconData:(NSData *)iconData
							  priority:(float)priority
							  isSticky:(BOOL)isSticky
						  clickContext:(id <NSCoding>)clickContext
{
	[GrowlApplicationBridge notifyWithTitle:title
								description:description
						   notificationName:notificationName
								   iconData:iconData
								   priority:priority
								   isSticky:isSticky
							   clickContext:clickContext];
}

- (NSDictionary *)registrationDictionaryForGrowl
{
	NSArray			*notifications;
	NSArray			*keys;
	NSArray			*objects;
	NSDictionary	*growl;
	
	notifications = [[NSArray alloc] initWithObjects:kBBGrowlWeatherUpdated, nil];
	keys = [[NSArray alloc] initWithObjects:GROWL_NOTIFICATIONS_ALL, GROWL_NOTIFICATIONS_DEFAULT, nil];
	objects = [[NSArray alloc] initWithObjects:notifications, notifications, nil];
	
	growl = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	
	[notifications release];
	[keys release];
	[objects release];
	
	return growl;
}

- (NSString *)applicationNameForGrowl
{
	//return NSLocalizedString(@"BucknellBug", nil);
	return @"BucknellBug";		// Name should be static, don't localize
}

@end
