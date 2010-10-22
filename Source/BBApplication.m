/*
 * Copyright (c) 2006-2010 Michael Dippery <mdippery@gmail.com>
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

#import "BBApplication.h"

#import <stdarg.h>

#import <Growl/Growl.h>

#import "BBDataFile.h"
#import "MDReachability.h"
#import "NSDate+Relative.h"
#import "NSImage+Convenience.h"
#import "NSMenuItem+BucknellBug.h"
#import "NSTimer+BucknellBug.h"

#define UPDATE_INTERVAL         (15.0 * 60.0)       // Frequency at which weather is updated (once every 15 mins)
#define WAKE_DELAY              10.0                // Number of seconds to wait to update weather after wakeup

NSString * const GROWL_WEATHER_UPDATED = @"Weather updated";
NSString * const GROWL_NO_INTERNET = @"Network error";
NSString * const GROWL_PARSER_ERROR = @"Parser error";

static float millibars_to_inches(unsigned int mb)
{
    return mb * 0.0295301F;
}

@interface BBApplication (Private)
- (void)activateStatusMenu;
- (NSImage *)statusMenuImage;
- (void)updateWeatherData:(NSTimer *)aTimer;
- (void)update;
- (void)updateLastUpdatedItem;
- (void)updateNextUpdateItem;
- (void)alertNewData;
- (void)showReachabilityError;
- (void)invalidateExistingTimer;
- (void)startTimer;
- (void)computerDidWake:(NSNotification *)notification;
@end

@implementation BBApplication

- (id)init
{
    if ((self = [super init])) {
        weather = [[BBDataFile alloc] init];
        timer = nil;
        [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        host = [[MDReachability alloc] initWithHostname:@"www.bucknell.edu"];
    }
    return self;
}

- (void)awakeFromNib
{
    [self activateStatusMenu];
    [GrowlApplicationBridge setGrowlDelegate:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [weather release];
    [dateFormatter release];
    [timer invalidate]; [timer release];
    [statusItem release];
    [host release];
    [super dealloc];
}

- (void)activateStatusMenu
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    statusItem = [[bar statusItemWithLength:NSSquareStatusItemLength] retain];
    //[statusItem setTitle:@"BucknellBug"];
    [statusItem setImage:[self statusMenuImage]];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:statusMenu];
}

- (NSImage *)statusMenuImage
{
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"statusmenu" ofType:@"png"];
    return [NSImage imageWithContentsOfFile:imgPath];
}

- (void)updateWeatherData:(NSTimer *)aTimer
{
    if ([weather update]) [self update];
}

- (void)update
{
    if ([host isReachable]) {
        [self updateLastUpdatedItem];
        
        [temperatureItem updateTitle:[NSString stringWithFormat:@"%.0f\u00b0 F", [weather temperature]]];
        [humidityItem updateTitle:[NSString stringWithFormat:@"%.2f%%", [weather humidity]]];
        [pressureItem updateTitle:[NSString stringWithFormat:@"%.2f in.", millibars_to_inches([weather pressure])]];
        [rainfallItem updateTitle:[NSString stringWithFormat:@"%u in.", [weather rainfall]]];
        
        [self alertNewData];
    } else {
        [self showReachabilityError];
    }
    
    [self updateNextUpdateItem];
}

- (void)updateLastUpdatedItem
{
    NSDate *date = [weather date];
    if (date) {
        // See -[NSDateFormatter setDoesRelativeDateFormatting:] in v10.6
        NSString *update = [dateFormatter stringFromDate:date];
        if ([date isYesterdayOrEarlier]) {
            unsigned int days = -[date numberOfDaysSinceNow];
            if (days <= 1) {
                update = [NSString stringWithFormat:@"%@, %@", NSLocalizedString(@"Yesterday", nil), update];
            } else {
                update = [NSString stringWithFormat:NSLocalizedString(@"%u days ago", nil), days];
            }
        }
        [lastUpdatedItem updateTitle:update];
    }
}

- (void)updateNextUpdateItem
{
    if (timer && [timer isValid]) {
        NSDate *fire = [timer nextFireDate];
        NSString *fireStr = [dateFormatter stringFromDate:fire];
        if ([fire isTomorrowOrLater]) {
            fireStr = [NSString stringWithFormat:@"%@, %@", NSLocalizedString(@"Tomorrow", nil), fireStr];
        }
        [nextUpdateItem updateTitle:fireStr];
    }
}

- (void)alertNewData
{
    [GrowlApplicationBridge notifyWithTitle:NSLocalizedString(@"Weather Updated", nil)
                                description:NSLocalizedString(@"Weather data has been updated.", nil)
                           notificationName:GROWL_WEATHER_UPDATED
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:nil];
}

- (void)showReachabilityError
{
    [GrowlApplicationBridge notifyWithTitle:NSLocalizedString(@"No Internet Connection", nil)
                                description:NSLocalizedString(@"You do not have an Internet connection.", nil)
                           notificationName:GROWL_NO_INTERNET
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:nil];
}

- (void)invalidateExistingTimer
{
    if (!timer) return;
    [timer invalidate];
    [timer release];
    timer = nil;
}

- (void)startTimer
{
    [self invalidateExistingTimer];
    timer = [[NSTimer alloc] initWithFireDate:[[NSDate date] addTimeInterval:1.0]
                                     interval:UPDATE_INTERVAL
                                       target:self
                                     selector:@selector(updateWeatherData:)
                                     userInfo:nil
                                      repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)computerDidWake:(NSNotification *)notification
{
    // Pause to confirm network connection has been established.
    [self performSelector:@selector(startTimer) withObject:nil afterDelay:WAKE_DELAY];
}

#pragma mark IBActions

- (IBAction)orderFrontStandardAboutPanel:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:sender];
}

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
    if ([host isReachable]) {
        [self updateWeatherData:nil];
    } else {
        [self showReachabilityError];
    }
}

#pragma mark NSApplication Delegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(computerDidWake:)
                                                               name:NSWorkspaceDidWakeNotification
                                                             object:nil];
    
    [self update];
    [self startTimer];
}

#pragma mark NSMenu Delegate

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    NSAssert(menu == statusMenu, @"Received delegate message for unknown menu");
    [self updateLastUpdatedItem];
    [self updateNextUpdateItem];
}

#pragma mark Growl Delegate

- (NSDictionary *)registrationDictionaryForGrowl
{
    NSArray *notifications = [NSArray arrayWithObjects:GROWL_WEATHER_UPDATED, GROWL_NO_INTERNET, nil];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            notifications, GROWL_NOTIFICATIONS_ALL,
            notifications, GROWL_NOTIFICATIONS_DEFAULT,
            nil];
}

- (NSString *)applicationNameForGrowl
{
    return @"BucknellBug";
}

@end
