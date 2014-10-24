/*
 * Copyright (c) 2006-2012 Michael Dippery <michael@monkey-robot.com>
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

#import "BBWeatherService.h"
#import "MDReachability.h"
#import "NSDate+Relative.h"
#import "NSMenuItem+BucknellBug.h"
#import "NSTimer+BucknellBug.h"

#define SECONDS_IN_AN_HOUR      (60 * 60)
#define UPDATE_INTERVAL         (15.0 * 60.0)       // Frequency at which weather is updated (once every 15 mins)
#define WAKE_DELAY              10.0                // Number of seconds to wait to update weather after wakeup

static NSString * const GROWL_WEATHER_UPDATED = @"Weather updated";
static NSString * const GROWL_NO_INTERNET     = @"Network error";

static NSString *_(NSString *string)
{
    return NSLocalizedString(string, nil);
}

static double millibars_to_inches(unsigned int mb)
{
    return mb * 0.0295301;
}

@interface BBApplication (Private)
+ (Class)weatherService;
- (void)activateStatusMenu;
- (NSImage *)statusMenuImage;
- (void)updateWeatherData:(NSTimer *)aTimer;
- (void)update;
- (NSDate *)fixDate:(NSDate *)theDate;
- (void)updateLastUpdatedItem;
- (void)updateNextUpdateItem;
- (void)alertNewData;
- (void)showReachabilityError;
- (void)sendNotificationWithTitle:(NSString *)title description:(NSString *)description name:(NSString *)name;
- (void)invalidateExistingTimer;
- (void)startTimer;
- (void)computerDidWake:(NSNotification *)notification;
@end

@implementation BBApplication

+ (Class)weatherService
{
    NSString *service = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"BBWeatherService"];
    return NSClassFromString(service);
}

- (id)init
{
    if ((self = [super init])) {
        weather = [[[BBApplication weatherService] alloc] init];
        timer = nil;
        [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateStyle:NSDateFormatterNoStyle];
        [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
        [timeFormatter setDoesRelativeDateFormatting:YES];
        host = [[MDReachability alloc] initWithHostname:@"www.bucknell.edu"];
    }
    return self;
}

- (void)awakeFromNib
{
    [self activateStatusMenu];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [weather release];
    [dateFormatter release];
    [timeFormatter release];
    [timer invalidate]; [timer release];
    [statusItem release];
    [host release];
    [super dealloc];
}

- (void)activateStatusMenu
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    statusItem = [[bar statusItemWithLength:NSSquareStatusItemLength] retain];
    [statusItem setImage:[self statusMenuImage]];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:statusMenu];
}

- (NSImage *)statusMenuImage
{
    return [NSImage imageNamed:@"statusmenu.png"];
}

- (void)update:(NSTimer *)aTimer;
{
    if ([host isReachable]) {
        [weather updateWithSuccess:^{
            [self updateLastUpdatedItem];

            [temperatureItem updateTitle:[NSString stringWithFormat:@"%.0f\u00b0 F", [weather temperature]]];
            [humidityItem updateTitle:[NSString stringWithFormat:@"%.0f%%", [weather humidity]]];
            [pressureItem updateTitle:[NSString stringWithFormat:@"%.2f in.", millibars_to_inches([weather pressure])]];
            [rainfallItem updateTitle:[NSString stringWithFormat:@"%.2f in.", [weather rainfall]]];

            [self alertNewData];
        } failure:^{
            NSLog(@"Failed to update weather data");
        }];
    } else {
        [self showReachabilityError];
    }
    
    [self updateNextUpdateItem];
}

- (NSDate *)fixDate:(NSDate *)theDate
{
    // Weather data is sometimes an hour ahead from clock time.
    // I don't think it's adjusted for daylight saving time, or
    // something like that. Fix the discrepancy by moving the
    // timestamp back by an hour if the timestamp is later than
    // the current time.

    if ([[NSDate date] isBefore:theDate]) {
        NSLog(@"%@ is ahead of now. Going back in time 1 hour.", theDate);
        return [NSDate dateWithTimeInterval:-SECONDS_IN_AN_HOUR sinceDate:theDate];
    }
    return theDate;
}

- (void)updateLastUpdatedItem
{
    NSDate *date = [self fixDate:[weather date]];
    if (!date) return;
    NSDateFormatter *formatter = [date isMoreThan:2U] ? dateFormatter : timeFormatter;
    NSString *update = [formatter stringFromDate:date];
    [lastUpdatedItem updateTitle:update];
}

- (void)updateNextUpdateItem
{
    if (timer && [timer isValid]) {
        NSDate *fire = [timer nextFireDate];
        NSString *fireStr = [timeFormatter stringFromDate:fire];
        if ([fire isTomorrowOrLater]) {
            fireStr = [NSString stringWithFormat:@"%@, %@", _(@"Tomorrow"), fireStr];
        }
        [nextUpdateItem updateTitle:fireStr];
    }
}

- (void)alertNewData
{
    [self sendNotificationWithTitle:@"Weather Updated" description:@"Weather data has been updated." name:GROWL_WEATHER_UPDATED];
}

- (void)showReachabilityError
{
    [self sendNotificationWithTitle:@"No Internet Connection" description:@"You do not have an Internet connection." name:GROWL_NO_INTERNET];
}

- (void)sendNotificationWithTitle:(NSString *)title description:(NSString *)description name:(NSString *)name
{
    Class NSUserNotification = NSClassFromString(@"NSUserNotification");
    Class NSUserNotificationCenter = NSClassFromString(@"NSUserNotificationCenter");
    if (NSUserNotification && NSUserNotificationCenter) {
        id note = [[[NSUserNotification alloc] init] autorelease];
        [note setTitle:_(title)];
        [note setInformativeText:_(description)];
        [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:note];
    } else {
        NSLog(@"Cannot send notification; NSUserNotification class not found");
    }
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
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
    timer = [[NSTimer alloc] initWithFireDate:fireDate
                                     interval:UPDATE_INTERVAL
                                       target:self
                                     selector:@selector(update:)
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
        [self update:nil];
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
    
    [self update:nil];
    [self startTimer];
}

#pragma mark NSMenu Delegate

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    NSAssert(menu == statusMenu, @"Received delegate message for unknown menu");
    [self updateLastUpdatedItem];
    [self updateNextUpdateItem];
}

@end
