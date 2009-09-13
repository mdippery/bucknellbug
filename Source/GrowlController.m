/*
 * Copyright (c) 2006-2009 Michael Dippery <mdippery@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
