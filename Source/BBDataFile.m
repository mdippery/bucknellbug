/*
 * Copyright (c) 2006-2011 Michael Dippery <mdippery@gmail.com>
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

#import "BBDataFile.h"

#import "CSVFile.h"
#import "NSDate+Relative.h"
#import "NSString+Numeric.h"

#ifndef CORRECT_TIMESTAMP
#define CORRECT_TIMESTAMP   0
#endif

#define SECONDS_IN_AN_HOUR  (60 * 60)

typedef enum {
    BBYearIndex        = 2-1,
    BBDateIndex        = 3-1,
    BBTimeIndex        = 4-1,
    BBPressureIndex    = 8-1,
    BBTemperatureIndex = 13-1,
    BBHumidityIndex    = 17-1,
    BBRainfallIndex    = 19-1
} BBDataFileIndex;

@interface BBDataFile (Private)
+ (NSDateFormatter *)dateFormatter;
- (void)resetData;
- (int)calculateTimestampOffset;
- (NSDate *)unmodifiedDate;
- (NSString *)dateString;
@end

@implementation BBDataFile

+ (NSURL *)defaultURL
{
    static NSURL *defaultURL = nil;
    if (!defaultURL) {
        NSString *url = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"BBWeatherDataURL"];
        defaultURL = [[NSURL alloc] initWithString:url];
        NSLog(@"Loaded weather data URL: %@", defaultURL);
    }
    return defaultURL;
}

+ (NSStringEncoding)defaultEncoding
{
    return NSWindowsCP1251StringEncoding;
}

+ (NSTimeZone *)defaultTimeZone
{
    return [NSTimeZone timeZoneWithName:@"US/Eastern"];
}

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *sharedFormatter = nil;
    if (!sharedFormatter) {
        sharedFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"%Y/%m/%d %H00" allowNaturalLanguage:NO];
        [sharedFormatter setTimeZone:[BBDataFile defaultTimeZone]];
    }
    return sharedFormatter;
}

- (id)init
{
    if ((self = [super init])) {
        [self resetData];
        if (!data) {
            [self autorelease];
            return nil;
        }
        timestampOffset = [self calculateTimestampOffset];
    }        
    return self;
}

- (void)dealloc
{
    [data release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> (data = %@)", [self class], self, data];
}

- (void)resetData
{
    [data release];
    data = [[CSVFile alloc] initWithContentsOfURL:[BBDataFile defaultURL] encoding:[BBDataFile defaultEncoding]];
}

#if CORRECT_TIMESTAMP
#warning Attempting to correct data file timestamp
- (int)calculateTimestampOffset
{
    // Try to correct the timestamp. It's really weird how it works,
    // and I haven't reverse-engineering the specifics. If the feed
    // was just updated, and the last update time was more than 1
    // hour but less than 2 hours before now, assume it's off
    // by an hour and correct it.
    // I'm sure this will break at some point, again.
    NSTimeInterval delta = -[[self unmodifiedDate] timeIntervalSinceNow];
    NSLog(@"Timestamp delta is %.2f = %.2f hours", delta, (delta / SECONDS_IN_AN_HOUR));
    if (delta < SECONDS_IN_AN_HOUR) {
        NSLog(@"Setting timestamp to 0 (delta is %.2f = %.2f hours)", delta, (delta / SECONDS_IN_AN_HOUR));
        return 0;
    }
    return -1;
}
#else
- (int)calculateTimestampOffset { return 0; }
#endif

- (BOOL)update
{
    // For parse documentation, see
    // http://www.departments.bucknell.edu/geography/Weather/output.htm
    // http://www.departments.bucknell.edu/geography/Weather/Data/raw_data.dat
    
    NSDate *lastDate = [[[self date] retain] autorelease];
    [self resetData];
    if (!data) return NO;
    timestampOffset = [self calculateTimestampOffset];
    return [[self date] isAfter:lastDate];
}

- (NSDate *)unmodifiedDate
{
    return [[BBDataFile dateFormatter] dateFromString:[self dateString]];
}

#if CORRECT_TIMESTAMP
#warning Attempting to correct data file timestamp
- (NSDate *)date
{
    // Fix an issue with an incorrect timestamp in the feed file
    return [[self unmodifiedDate] addTimeInterval:timestampOffset * SECONDS_IN_AN_HOUR];
}
#else
- (NSDate *)date { return [self unmodifiedDate]; }
#endif

- (NSString *)dateString
{
    NSString *year = [data objectAtIndex:BBYearIndex];
    NSString *date = [data objectAtIndex:BBDateIndex];
    NSString *time = [data objectAtIndex:BBTimeIndex];
    if (year && date && time) {
        return [NSString stringWithFormat:@"%@/%@ %@%@", year, date, [time length] == 3 ? @"0" : @"", time];
    } else {
        return nil;
    }
}

- (double)temperature
{
    return [[data objectAtIndex:BBTemperatureIndex] doubleValue];
}

- (double)humidity
{
    return [[data objectAtIndex:BBHumidityIndex] doubleValue];
}

- (unsigned int)pressure
{
    return [[data objectAtIndex:BBPressureIndex] unsignedIntValue];
}

- (unsigned int)rainfall
{
    return [[data objectAtIndex:BBRainfallIndex] unsignedIntValue];
}

@end
