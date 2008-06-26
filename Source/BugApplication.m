/*
 * BugApplication.m
 * Copyright (c) 2006-2007 Michael Dippery <mdippery@bucknell.edu>
 *
 * All rights reserved. This file is licensed under the Creative Commons
 * Attribution-NonCommercial-ShareAlike license, v2.5. You may use this file so
 * long as you follow the guidelines in the license. You may obtain a copy of the
 * license at
 *
 *     http://creativecommons.org/licenses/by-nc-sa/2.5/legalcode
 */

#import <stdarg.h>
#import <Growl/Growl.h>
#import <iLifeControls/NFHUDWindow.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "BugApplication.h"
#import "BugDataParser.h"
#import "BugHUDTextField.h"
#import "GrowlController.h"
#import "MDPowerNotifications.h"

#define	UPDATE_INTERVAL		(15.0 * 60.0)		// Frequency at which weather is updated (once every 15 mins)
#define WAKE_DELAY			10.0				// Number of seconds to wait to update weather after wakeup
#define DEGREE_SYMBOL	   	0x00b0				// Unicode codepoint for degree symbol

#define MillibarsToInches(mb)	((float) (mb * 0.0295301F))

@interface BugApplication (Private)
- (void)updateWeatherData:(NSTimer *)aTimer;
- (void)alertNewData;
- (void)startTimer;
- (void)computerDidWake:(void *)userInfo;
- (void)showNoWeatherDataAlert;
@end

@implementation BugApplication

- (id)init
{
	if ([super init] == nil) return nil;
	
	dataFileParser = [[BugDataParser alloc] init];
	timer = nil;
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[dataFileParser release];
	[timer invalidate];
	[timer release];
	[super dealloc];
}

- (void)awakeFromNib
{
	[window makeKeyAndOrderFront:self];
}

- (void)updateWeatherData:(NSTimer *)aTimer
{
	NSDictionary *weatherData = nil;
	BOOL feedWasUpdated = NO;
	
	NSAssert(!aTimer || aTimer == timer, @"aTimer should be nil or instance variable timer");	
	NSLog(@"Checking weather data with timer date: %@", [aTimer fireDate]);
	
	weatherData = [[dataFileParser fetchWeatherData:&feedWasUpdated] retain];
	
	if (weatherData && [weatherData count] > 0 && feedWasUpdated) {
		static NSDateFormatter *dateFormatter = nil;
		NSDate *feedDate;
		
		NSLog(@"Feed updated");
		
		// Set the date (using a 10.4 formatter)
		if (dateFormatter == nil) {
			[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
			dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
			[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		}
		// If the date could not be parsed, it will be set to Dec. 31, 1969.
		if ([[weatherData objectForKey:kMDKeyDate] doubleValue] > 0.0) {
			feedDate = [NSDate dateWithTimeIntervalSince1970:[[weatherData objectForKey:kMDKeyDate] doubleValue]];
			[dateField setStringValue:[dateFormatter stringFromDate:feedDate]];
		} else {
			NSLog(@"Could not get date with value: %.4f", [[weatherData objectForKey:kMDKeyDate] doubleValue]);
			[dateField setStringValue:@"(unavailable)"];
		}
		
		// Set the temperature
		[temperatureField setStringValue:[NSString stringWithFormat:@"%.0f%C F", [[weatherData objectForKey:kMDKeyTemp] floatValue], DEGREE_SYMBOL]];
		
		// Set the humidity
		[humidityField setStringValue:[NSString stringWithFormat:@"%.2f %%", [[weatherData objectForKey:kMDKeyHumidity] floatValue]]];
		
		// Set the sunshine index
		[sunshineField setStringValue:[NSString stringWithFormat:@"%.2f %%", [[weatherData objectForKey:kMDKeySun] floatValue]]];
		
		// Set the pressure
		[pressureField setStringValue:[NSString stringWithFormat:@"%.2f in.", MillibarsToInches([[weatherData objectForKey:kMDKeyPressure] intValue])]];
		
		// Set the rainfall
		[rainfallField setStringValue:[NSString stringWithFormat:@"%d in.", [[weatherData objectForKey:kMDKeyRainfall] intValue]]];
	} else {
		if (!weatherData || [weatherData count] == 0) {
			[self showNoWeatherDataAlert];
		}
	}
	
	[weatherData release];
	
	if (feedWasUpdated) [self alertNewData];
}

- (void)alertNewData
{
	[NSApp requestUserAttention:NSInformationalRequest];
	[GrowlApplicationBridge notifyWithTitle:NSLocalizedString(@"Weather Updated", nil)
	                            description:NSLocalizedString(@"Weather data has been updated.", nil)
	                       notificationName:kBBGrowlWeatherUpdated
	                               iconData:nil
	                               priority:0
	                               isSticky:NO
	                           clickContext:nil];
}

- (void)startTimer
{
	if (timer) {
		//NSLog(@"Invalidating existing timer");
		[timer invalidate];
		[timer release];
		timer = nil;
	}
	
	timer = [[NSTimer alloc] initWithFireDate:[[NSDate date] addTimeInterval:1.0]
	                                 interval:UPDATE_INTERVAL
	                                   target:self
	                                 selector:@selector(updateWeatherData:)
	                                 userInfo:nil
	                                  repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	//NSLog(@"Added timer to current run loop");
}

- (void)computerDidWake:(void *)userInfo
{
	NSLog(@"Received computerDidWake notification");
	
	// Pause to confirm network connection has been established.
	[self performSelector:@selector(startTimer) withObject:nil afterDelay:WAKE_DELAY];
}

- (void)showNoWeatherDataAlert
{
	SCNetworkReachabilityRef netReachRef = NULL;
	SCNetworkConnectionFlags netReachFlags;
	NSString *dialogTitle = NSLocalizedString(@"No weather data was returned.", nil);
	NSString *dialogMsg = nil;
	NSString *logMsg = [NSString stringWithString:@"No weather data returned: "];
	
	// Detect whether there is a network connection or not and set dialog text
	netReachRef = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "www.bucknell.edu");
	if (SCNetworkReachabilityGetFlags(netReachRef, &netReachFlags)) {
		if ((netReachFlags & kSCNetworkFlagsReachable) == kSCNetworkFlagsReachable) {
			dialogMsg = NSLocalizedString(@"Weather data cannot be parsed at this time.", nil);
			logMsg = [logMsg stringByAppendingString:@"Host is reachable, but data cannot be parsed"];
		} else {
			dialogMsg = NSLocalizedString(@"You may not have an active Internet connection.", nil);
			logMsg = [logMsg stringByAppendingString:@"No active Internet connection"];
		}
	} else {
		dialogMsg = NSLocalizedString(@"Weather data cannot be parsed at this time.", nil);
		logMsg = [logMsg stringByAppendingString:@"SCNetworkReachabilityGetFlags() returned invalid flags"];
	}
	
	// Log and show alert panel with appropriate text
	NSLog(logMsg);
	NSRunAlertPanel(dialogTitle, dialogMsg, nil, nil, nil);
}

@end

@implementation BugApplication (GUI)

- (IBAction)openHomepage:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.bucknell.edu/weather/Index.html"]];
}

- (IBAction)openBugHomepage:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.bucknell.edu/weather/Bug.html"]];
}

- (IBAction)refresh:(id)sender
{
	[self updateWeatherData:nil];
}

@end

@implementation BugApplication (NSAppDelegate)

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{	
	//[self updateWeatherData:nil];
	[self startTimer];
	
	[[GrowlController sharedController] registerWithGrowl];
	MDRegisterForPowerNotifications();
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(computerDidWake:)
												 name:(NSString *) kMDComputerDidWakeNotification
											   object:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	// Don't close the application when the last window is closed; it should stay
	// open (in the status item area)
	return NO;
}

@end
