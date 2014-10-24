/*
 * BBGrowlController.h
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
 * @file BBGrowlController.h
 * Provides definitions for the implementation of the @c BBGrowlController class.
 * Also provides a listing of most of the Growl notifications recognized by the
 * application.
 */

#import <Growl-WithInstaller/Growl.h>

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
@interface BBGrowlController : NSObject <GrowlApplicationBridgeDelegate>

/**
 * Returns the application-wide shared instance of @c BBGrowlController. This
 * should be used instead of any <code>-[init...]</code> methods, because none
 * of those will work.
 *
 * @return The application-wide shared instance of @c BBGrowlController. */
+ (BBGrowlController *)sharedController;

/**
 * Posts a Growl notification.
 *
 * @param title <strong>Required.</strong> A title for this notification.
 *   This is presented to the user, so make it something intelligible.
 * @param description <strong>Required.</strong> A description of the
 *   notification, with a bit more info than presented in the title. This is also
 *   presented to the user.
 * @param notificationName <strong>Required.</strong> The notification's
 *   name as it is known to Growl. Most available notification names are listed in
 *   this header file.
 * @param iconData An @c NSImage, represented as @c NSData, that is shown to the
 *   user along with the notification. Pass @c nil to just show the application icon.
 * @param priority The importance of the notification as a @c float from -2 (very low)
 *   to 2 (emergency). A "normal" notification as importance 0.
 * @param isSticky If set to @c YES, then the user must click the notification to make
 *   it disappear.
 * @param clickContext This object is passed back to the delegate when a user clicks
 *   a notification. Currently, BucknellBug does nothing with such objects. This object
 *   must be serializable according to @c NSCoding.
 *
 * @see http://growl.info/documentation/developer/implementing-growl.php?lang=cocoa
 */
- (void)postGrowlNotificationWithTitle:(NSString *)title
						   description:(NSString *)description
					  notificationName:(NSString *)notificationName
							  iconData:(NSData *)iconData
							  priority:(float)priority
							  isSticky:(BOOL)isSticky
						  clickContext:(id <NSCoding>)clickContext;

@end
