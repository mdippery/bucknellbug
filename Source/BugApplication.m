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

#import "BugApplication.h"

#import <stdarg.h>

#import <Growl/Growl.h>
#import <iLifeControls/NFHUDWindow.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "BugDataParser.h"
#import "BugHUDTextField.h"
#import "MDPowerNotifications.h"
#import "YRKSpinningProgressIndicator.h"

#define UPDATE_INTERVAL         (15.0 * 60.0)       // Frequency at which weather is updated (once every 15 mins)
#define WAKE_DELAY              10.0                // Number of seconds to wait to update weather after wakeup
#define DEGREE_SYMBOL           0x00b0              // Unicode codepoint for degree symbol
#define GROWL_WEATHER_UPDATED   @"Weather updated"  // Growl update name

#define MillibarsToInches(mb)   ((float) (mb * 0.0295301F))

@interface BugApplication (Private)
- (void)activateStatusMenu;
- (NSImage *)statusMenuImage;
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

- (void)awakeFromNib
{
    [self activateStatusMenu];
    [window makeKeyAndOrderFront:self];
    [GrowlApplicationBridge setGrowlDelegate:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [dataFileParser release];
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
    
    [spinner startAnimation:self];
    
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
        
        [temperatureField setStringValue:[NSString stringWithFormat:@"%.0f%C F", [[weatherData objectForKey:kMDKeyTemp] floatValue], DEGREE_SYMBOL]];
        [humidityField setStringValue:[NSString stringWithFormat:@"%.2f %%", [[weatherData objectForKey:kMDKeyHumidity] floatValue]]];
        [sunshineField setStringValue:[NSString stringWithFormat:@"%.2f %%", [[weatherData objectForKey:kMDKeySun] floatValue]]];
        [pressureField setStringValue:[NSString stringWithFormat:@"%.2f in.", MillibarsToInches([[weatherData objectForKey:kMDKeyPressure] intValue])]];
        [rainfallField setStringValue:[NSString stringWithFormat:@"%d in.", [[weatherData objectForKey:kMDKeyRainfall] intValue]]];
    } else {
        if (!weatherData || [weatherData count] == 0) {
            [self showNoWeatherDataAlert];
        }
    }
    
    [weatherData release];
    
    [spinner stopAnimation:self];
    if (feedWasUpdated) [self alertNewData];
}

- (void)alertNewData
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


@implementation BugApplication (GrowlDelegate)

- (NSDictionary *)registrationDictionaryForGrowl
{
    NSArray *notifications;
    NSDictionary *growl;
    
    notifications = [[NSArray alloc] initWithObjects:GROWL_WEATHER_UPDATED, nil];
    
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
