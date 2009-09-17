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

#import <Cocoa/Cocoa.h>

@class BugDataParser, BugHUDTextField, NFHUDWindow, YRKSpinningProgressIndicator;


@interface BugApplication : NSObject <GrowlApplicationBridgeDelegate>
{
    IBOutlet NSMenu *statusMenu;
    IBOutlet NFHUDWindow *window;
    IBOutlet YRKSpinningProgressIndicator *spinner;
    IBOutlet BugHUDTextField *dateField;
    IBOutlet BugHUDTextField *temperatureField;
    IBOutlet BugHUDTextField *humidityField;
    IBOutlet BugHUDTextField *sunshineField;
    IBOutlet BugHUDTextField *pressureField;
    IBOutlet BugHUDTextField *rainfallField;
    
    BugDataParser *dataFileParser;
    NSTimer *timer;
    NSStatusItem *statusItem;
}
@end


@interface BugApplication (GUI)

- (IBAction)openHomepage:(id)sender;
- (IBAction)openBugHomepage:(id)sender;
- (IBAction)refresh:(id)sender;

@end
