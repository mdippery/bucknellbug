/*
 * BBApplication.m
 * Copyright (c) 2006-2007 Michael Dippery <mdippery@bucknell.edu>
 *
 * All rights reserved. This file is licensed under the Creative Commons
 * Attribution-NonCommercial-ShareAlike license, v2.5. You may use this file so
 * long as you follow the guidelines in the license. You may obtain a copy of the
 * license at
 *
 *     http://creativecommons.org/licenses/by-nc-sa/2.5/legalcode
 */

#import "BBApplication.h"

#import <stdarg.h>
#import "BBGrowlController.h"
#import "MDDataFileParser.h"
#import "MDPowerNotifications.h"

#define	UPDATE_INTERVAL		(15.0 * 60.0)		// Frequency at which weather is updated (once every 15 mins)
#define WAKE_DELAY			10.0				// Number of seconds to wait to update weather after wakeup
#define DEGREE_SYMBOL	    0x00b0				// Unicode codepoint for degree symbol

float
MillibarsToInches(int mb)
{
	return (mb * 0.0295301F);
}

NSMenuItem *
LocalizedMenuItem(NSString *key, NSString *fmt, ...)
{
	va_list ap;
	NSMutableString *menuTitle;
	NSString *formatted;
	NSMenuItem *item;
	
	va_start(ap, fmt);	// Point to first unnamed argument
	menuTitle = [[NSMutableString alloc] initWithFormat:@"%@: ", NSLocalizedString(key, nil)];
	formatted = [[NSString alloc] initWithFormat:fmt arguments:ap];
	[menuTitle appendString:formatted];
	
	item = [[NSMenuItem alloc] initWithTitle:menuTitle action:NULL keyEquivalent:@""];
	
	[menuTitle release];
	[formatted release];
	va_end(ap);			// Clean up when done
	
	return [item autorelease];
}

@interface BBApplication (Private)
- (void)updateWeatherData:(NSTimer *)aTimer;
- (void)alertNewData;
- (void)startTimer;
- (void)updateDockTimeLabel;
- (void)computerDidWake:(void *)userInfo;
@end

@implementation BBApplication

- (id)init
{
	if (self = [super init]) {
		dataFileParser = [[MDDataFileParser alloc] init];
		dockMenu = nil;
		timer = nil;
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[dataFileParser release]; dataFileParser = nil;
	[dockMenu release]; dockMenu = nil;
	//[timer invalidate]; timer = nil;		// Do not release -- not retained by object
	[timer invalidate]; [timer release]; timer = nil;
	[super dealloc];
}

- (void)updateWeatherData:(NSTimer *)aTimer
{
	NSDictionary *weatherData = nil;
	BOOL feedWasUpdated = NO;
	
	NSAssert(aTimer == nil || aTimer == timer, @"aTimer should be nil or instance variable timer");	
	NSLog(@"Checking weather data with timer date: %@", [aTimer fireDate]);
	
	weatherData = [[dataFileParser fetchWeatherData:&feedWasUpdated] retain];
	
	if (weatherData && [weatherData count] > 0 && feedWasUpdated) {
		NSDate *feedDate;
		
		NSLog(@"Feed updated, rebuilding Dock menu");
		
		[dockMenu release];
		dockMenu = [[NSMenu alloc] initWithTitle:@"DockMenu"];
		
		feedDate = [NSDate dateWithTimeIntervalSince1970:[[weatherData objectForKey:kMDKeyDate] doubleValue]];
		[dockMenu addItem:LocalizedMenuItem(kMDKeyDate,
											@"%@",
											[feedDate descriptionWithCalendarFormat:@"%a, %b %e, %Y %1I:%M %p"
																		   timeZone:nil
																			 locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]])];		
		[dockMenu addItem:LocalizedMenuItem(kMDKeyTemp,
											@"%.0f %CF",
											[[weatherData objectForKey:kMDKeyTemp] floatValue],
											DEGREE_SYMBOL)];		
		[dockMenu addItem:LocalizedMenuItem(kMDKeyHumidity,
											@"%.2f%%",
											[[weatherData objectForKey:kMDKeyHumidity] floatValue])];
		[dockMenu addItem:LocalizedMenuItem(kMDKeySun,
											@"%.2f%%",
											[[weatherData objectForKey:kMDKeySun] floatValue])];
		[dockMenu addItem:LocalizedMenuItem(kMDKeyPressure,
											@"%.2f in.",
											MillibarsToInches([[weatherData objectForKey:kMDKeyPressure] intValue]))];
		[dockMenu addItem:LocalizedMenuItem(kMDKeyRainfall,
											@"%d in.",
											[[weatherData objectForKey:kMDKeyRainfall] intValue])];
	} else {
		if (!weatherData || [weatherData count] == 0) {
			NSLog(@"No weather data returned");
		}
	}
	
	[weatherData release];
	
	[self updateDockTimeLabel];
	if (feedWasUpdated) [self alertNewData];
}

- (void)alertNewData
{
	[NSApp requestUserAttention:NSInformationalRequest];
	[[BBGrowlController sharedController] postGrowlNotificationWithTitle:NSLocalizedString(@"Weather Updated", nil)
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
		NSLog(@"Invalidating existing timer");
		[timer invalidate]; [timer release]; timer = nil;
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

- (void)updateDockTimeLabel
{
	if ([timer isValid]) {
		NSDate *nextUpdate;
		NSString *label;
		NSMenuItem *menuItem;
		unsigned int maxItems = [dataFileParser maxCount];
		
		if ([dockMenu numberOfItems] > maxItems) {			// Remove old "Next Update" label
			[dockMenu removeItemAtIndex:(maxItems + 1)];
		} else if ([dockMenu numberOfItems] == maxItems) {	// Add separator if necessary
			[dockMenu addItem:[NSMenuItem separatorItem]];
		}
		
		nextUpdate = [timer fireDate];
		//NSLog(@"Timer fire date: %@", nextUpdate);
		if ([nextUpdate compare:[NSDate date]] != NSOrderedDescending) {
			/*
			 * If a timer just fired, it will have the current time, not the time
			 * of the next update (which should be in the future), so increment
			 * to NEXT fire date. However, fire date is correct if the feed is
			 * manually updated (i.e. the user hit "Refresh").
			 */
			nextUpdate = [nextUpdate addTimeInterval:[timer timeInterval]];
		}
		
		label = [@"Next Update: " stringByAppendingString:[nextUpdate descriptionWithCalendarFormat:@"%1I:%M %p"
																						   timeZone:nil
																							 locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]];
		menuItem = [[NSMenuItem alloc] initWithTitle:label action:NULL keyEquivalent:@""];
		[dockMenu addItem:menuItem];
		[menuItem release];
	} else {
		NSLog(@"Could not set Dock time label: timer invalid");
	}
}

- (void)computerDidWake:(void *)userInfo
{
	NSLog(@"Received computerDidWake notification");
	
	[self performSelector:@selector(startTimer)
			   withObject:nil
			   afterDelay:WAKE_DELAY];		// Pause to ensure network connection is established
}

@end

@implementation BBApplication (GUI)

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

@implementation BBApplication (NSAppDelegate)

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{	
	//[self updateWeatherData:nil];
	[self startTimer];
	
	MDRegisterForPowerNotifications();
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(computerDidWake:)
												 name:(NSString *) kMDComputerDidWakeNotification
											   object:nil];
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender
{
	if (!dockMenu) [self updateWeatherData:nil];
	return dockMenu;
}

@end
