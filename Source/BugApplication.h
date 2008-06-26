/*
 * BugApplication.h
 * Copyright (c) 2006-2007 Michael Dippery <mdippery@bucknell.edu>
 *
 * All rights reserved. This file is licensed under the Creative Commons
 * Attribution-NonCommercial-ShareAlike license, v2.5. You may use this file so
 * long as you follow the guidelines in the license. You may obtain a copy of the
 * license at
 *
 *     http://creativecommons.org/licenses/by-nc-sa/2.5/legalcode
 */

/**
 * @file BugApplication.h
 * The header file for the \c BugApplication class, which controls the behavior of
 * the BucknellBug application.
 */

#import <Cocoa/Cocoa.h>

@class BugDataParser, BugHUDTextField, NFHUDWindow;

/**
 * Describes an object that controls the entire application. This object provides
 * methods for controlling various aspects of the application.
 */
@interface BugApplication : NSObject
{
	/// The window used to display the weather data.
	IBOutlet NFHUDWindow *window;
	/// The last updated text field.
	IBOutlet BugHUDTextField *dateField;
	/// The temperature text field.
	IBOutlet BugHUDTextField *temperatureField;
	/// The humidity text field.
	IBOutlet BugHUDTextField *humidityField;
	/// The sunshine index text field.
	IBOutlet BugHUDTextField *sunshineField;
	/// The pressure text field.
	IBOutlet BugHUDTextField *pressureField;
	/// The rainfall text field.
	IBOutlet BugHUDTextField *rainfallField;
	
	/// The data file being parsed by the application.
	BugDataParser *dataFileParser;
	/// The timer responsible for periodically updating the weather feed.
	NSTimer *timer;
}
@end

/** Handles the GUI elements of the application. */
@interface BugApplication (GUI)

/**
 * Opens the Bucknell Weather Station homepage.
 *
 * @param sender The GUI element responsible for sending the message.
 */
- (IBAction)openHomepage:(id)sender;

/**
 * Opens the Bucknell Bug homepage. The BucknellBug homepage is a subpage of the
 * Bucknell Weather Station site.
 *
 * @param sender The GUI element responsible for sending the message.
 */
- (IBAction)openBugHomepage:(id)sender;

/**
 * Refreshes the weather feed via the GUI. Refreshing the weather feed through
 * the GUI does \e not reset the timer.
 *
 * @param sender The GUI element responsible for sending the message.
 */
- (IBAction)refresh:(id)sender;

@end

/**
 * Describes the messages to which an instance of @c BBApplication will
 * respond when acting as a delegate for @c NSApp.
 */
@interface BugApplication (NSAppDelegate)

/**
 * Alerts the application delegate that the application has finished launching.
 * This is called after <code>-[BBApplication init]</code>. This is where
 * applicaton setup code should go.
 *
 * @param notification The notification object associated with this notification.
 */
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

/**
 * Specifies whether the application should quit when the last window is closed.
 *
 * @param theApplication The \c NSApp instance.
 */
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication;

@end
