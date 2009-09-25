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

#import "BBApplication.h"

#import <stdarg.h>

#import <Growl/Growl.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "BBDataParser.h"
#import "MDPowerNotifications.h"
#import "NSDateAdditions.h"
#import "NSMenuItemAdditions.h"
#import "NSTimerAdditions.h"

#define UPDATE_INTERVAL         (15.0 * 60.0)       // Frequency at which weather is updated (once every 15 mins)
#define WAKE_DELAY              10.0                // Number of seconds to wait to update weather after wakeup
#define DEGREE_SYMBOL           0x00b0              // Unicode codepoint for degree symbol

#define MillibarsToInches(mb)   ((float) (mb * 0.0295301F))

NSString * const BBDidUpdateWeatherNotification = @"BugApplicationDidUpdateWeatherNotification";
NSString * const GROWL_WEATHER_UPDATED = @"Weather updated";
NSString * const GROWL_NO_INTERNET = @"Network error";

@interface BBApplication (Private)
- (void)activateStatusMenu;
- (NSImage *)statusMenuImage;
- (void)updateWeatherData:(NSTimer *)aTimer;
- (void)updateLastUpdatedItem;
- (void)updateNextUpdateItem;
- (void)alertNewData:(NSNotification *)notification;
- (void)startTimer;
- (void)computerDidWake:(NSNotification *)notification;
- (void)showNoWeatherDataAlert;
@end

@implementation BBApplication

- (id)init
{
    if ((self = [super init])) {
        dataFileParser = [[BBDataParser alloc] init];
        lastUpdate = nil;
        timer = nil;
        [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
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
    NSLog(@"Deallocating BBApplication (instance <%p>)", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [dataFileParser release];
    [lastUpdate release];
    [dateFormatter release];
    [timer invalidate];
    [timer release];
    [statusItem release];
    [super dealloc];
}

- (void)activateStatusMenu
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    statusItem = [[bar statusItemWithLength:NSSquareStatusItemLength] retain];
    // [statusItem setTitle:@"BucknellBug"];
    [statusItem setImage:[self statusMenuImage]];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:statusMenu];
}

- (NSImage *)statusMenuImage
{
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"statusmenu" ofType:@"png"];
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:imgPath];
    return [img autorelease];
}

- (void)updateWeatherData:(NSTimer *)aTimer
{
    NSDictionary *weatherData = nil;
    BOOL feedWasUpdated = NO;
    
    weatherData = [[dataFileParser fetchWeatherData:&feedWasUpdated] retain];
    NSLog(@"weatherData <%p> = %@", weatherData, weatherData);
    if (weatherData && [weatherData count] > 0 && feedWasUpdated) {
        NSDate *update = [weatherData objectForKey:kMDKeyDate];
        NSLog(@"update <%p> = %@", update, update);
        [lastUpdate release];
        if (update != (NSObject *) [NSNull null]) {
            lastUpdate = [update retain];
            NSLog(@"lastUpdate retain count is %d", [lastUpdate retainCount]);
        } else {
            NSLog(@"Cannot set lastUpdate, update is nil");
            lastUpdate = nil;
        }
        [self updateLastUpdatedItem];
        
        [temperatureItem updateTitle:[NSString stringWithFormat:@"%.0f%C F", [[weatherData objectForKey:kMDKeyTemp] floatValue], DEGREE_SYMBOL]];
        [humidityItem updateTitle:[NSString stringWithFormat:@"%.2f%%", [[weatherData objectForKey:kMDKeyHumidity] floatValue]]];
        [sunshineIndexItem updateTitle:[NSString stringWithFormat:@"%.2f%%", [[weatherData objectForKey:kMDKeySun] floatValue]]];
        [pressureItem updateTitle:[NSString stringWithFormat:@"%.2f in.", MillibarsToInches([[weatherData objectForKey:kMDKeyPressure] intValue])]];
        [rainfallItem updateTitle:[NSString stringWithFormat:@"%d in.", [[weatherData objectForKey:kMDKeyRainfall] intValue]]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:BBDidUpdateWeatherNotification object:self];
    } else {
        if (!weatherData || [weatherData count] == 0) {
            [self showNoWeatherDataAlert];
        }
    }
    [weatherData release];
    
    [self updateNextUpdateItem];
    NSLog(@"Finished updating weather data");
}

- (void)updateLastUpdatedItem
{
    if (lastUpdate) {
        NSString *update = [dateFormatter stringFromDate:lastUpdate];
        if ([lastUpdate isYesterdayOrEarlier]) {
            update = [@"Yesterday, " stringByAppendingString:update];
        }
        [lastUpdatedItem updateTitle:update];
    } else {
        NSLog(@"Could not get last updated date, lastUpdate is nil");
        [lastUpdatedItem updateTitle:NSLocalizedString(@"(unavailable)", nil)];
    }
}

- (void)updateNextUpdateItem
{
    if (timer && [timer isValid]) {
        NSDate *fire = [timer nextFireDate];
        NSString *fireStr = [dateFormatter stringFromDate:fire];
        if ([fire isTomorrowOrLater]) {
            fireStr = [@"Tomorrow, " stringByAppendingString:fireStr];
        }
        [nextUpdateItem updateTitle:fireStr];
    } else {
        NSLog(@"Cannot update nextUpdateItem - invalid timer %@", timer);
    }
}

- (void)alertNewData:(NSNotification *)notification
{
    // Not valid, since we're now a status menu item
    // [NSApp requestUserAttention:NSInformationalRequest];
    [GrowlApplicationBridge notifyWithTitle:NSLocalizedString(@"Weather Updated", nil)
                                description:NSLocalizedString(@"Weather data has been updated.", nil)
                           notificationName:GROWL_WEATHER_UPDATED
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:nil];
}

- (void)startTimer
{
    if (timer) {
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
}

- (void)computerDidWake:(NSNotification *)notification
{
    NSLog(@"Received computerDidWake notification");
    // Pause to confirm network connection has been established.
    [self performSelector:@selector(startTimer) withObject:nil afterDelay:WAKE_DELAY];
}

- (void)showNoWeatherDataAlert
{
    SCNetworkReachabilityRef netReachRef = NULL;
    SCNetworkConnectionFlags netReachFlags;
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
            [GrowlApplicationBridge notifyWithTitle:NSLocalizedString(@"Network Error", nil)
                                        description:NSLocalizedString(@"You do not have an active Internet connection.", nil)
                                   notificationName:GROWL_NO_INTERNET
                                           iconData:nil
                                           priority:1
                                           isSticky:NO
                                       clickContext:nil];
        }
    } else {
        dialogMsg = NSLocalizedString(@"Weather data cannot be parsed at this time.", nil);
        logMsg = [logMsg stringByAppendingString:@"SCNetworkReachabilityGetFlags() returned invalid flags"];
    }
    
    // Log and show alert panel with appropriate text
    NSLog(logMsg);
    //NSRunAlertPanel(dialogTitle, dialogMsg, nil, nil, nil);
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
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    //[self updateWeatherData:nil];
    [self startTimer];
    
    MDRegisterForPowerNotifications();
    [nc addObserver:self
           selector:@selector(computerDidWake:)
               name:(NSString *) kMDComputerDidWakeNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(alertNewData:)
               name:BBDidUpdateWeatherNotification
             object:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    // Don't close the application when the last window is closed; it should stay
    // open (in the status item area)
    return NO;
}

@end


@implementation BBApplication (NSMenuDelegate)

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    NSAssert(menu == statusMenu, @"Received delegate message for unknown menu");
    [self updateLastUpdatedItem];
    [self updateNextUpdateItem];
}

@end


@implementation BBApplication (GrowlDelegate)

- (NSDictionary *)registrationDictionaryForGrowl
{
    NSArray *notifications;
    NSDictionary *growl;
    
    notifications = [[NSArray alloc] initWithObjects:GROWL_WEATHER_UPDATED, GROWL_NO_INTERNET, nil];
    
    growl = [NSDictionary dictionaryWithObjectsAndKeys:
                notifications, GROWL_NOTIFICATIONS_ALL,
                notifications, GROWL_NOTIFICATIONS_DEFAULT,
                nil];
    
    [notifications release];
    return growl;
}

- (NSString *)applicationNameForGrowl
{
    return @"BucknellBug";
}

@end
