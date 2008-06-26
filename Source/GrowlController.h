/*
 * GrowlController.h
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
 * @file GrowlController.h
 * Provides definitions for the implementation of the @c BBGrowlController class.
 * Also provides a listing of most of the Growl notifications recognized by the
 * application.
 */

@protocol GrowlApplicationBridgeDelegate;

/**
 * @defgroup growl BucknellBug Growl Notifications
 * @{
 */

/// A notification that the weather has been updated.
extern NSString * const kBBGrowlWeatherUpdated;

/** @} */

/**
 * Describes an object that handles BucknellBug Growl notifications.
 * 
 * @see http://growl.info/documentation/developer/implementing-growl.php?lang=cocoa
 */
@interface GrowlController : NSObject <GrowlApplicationBridgeDelegate>

/**
 * Returns the application-wide shared instance of @c BBGrowlController. This
 * should be used instead of any <code>-[init...]</code> methods, because none
 * of those will work.
 *
 * @return The application-wide shared instance of @c BBGrowlController. */
+ (GrowlController *)sharedController;

/**
 * Registers the application with the Growl notification system.
 */
- (void)registerWithGrowl;

@end
