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

#import "BBDataFile.h"

#import "CSVFile.h"
#import "NSDate+Relative.h"

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
- (NSString *)dateString;
@end

@implementation BBDataFile

+ (NSURL *)defaultURL
{
    return [NSURL URLWithString:@"http://www.departments.bucknell.edu/geography/Weather/Data/raw_data.dat"];
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
        sharedFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"%Y/%m/%d %H00 %z" allowNaturalLanguage:NO];
        //int offset = [[BBDataFile defaultTimeZone] isDaylightSavingTime] ? -3 : -4;
        //offset *= SECONDS_IN_AN_HOUR;
        //[sharedFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:offset]];
    }
    return sharedFormatter;
}

- (id)init
{
    if ((self == [super init])) {
        [self resetData];
        if (!data) {
            [self autorelease];
            return nil;
        }
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

- (BOOL)update
{
    // For parse documentation, see
    // http://www.departments.bucknell.edu/geography/Weather/output.htm
    // http://www.departments.bucknell.edu/geography/Weather/Data/raw_data.dat
    
    NSDate *lastDate = [[[self date] retain] autorelease];
    [self resetData];
    if (!data) return NO;
    return [[self date] isAfter:lastDate];
}

- (NSDate *)date
{
    NSString *dateStr = [self dateString];
    //NSLog(@"Got date string: %@", dateStr);
    return [[BBDataFile dateFormatter] dateFromString:dateStr];
}

- (NSString *)dateString
{
    NSString *year = [data objectAtIndex:BBYearIndex];
    NSString *date = [data objectAtIndex:BBDateIndex];
    NSString *time = [data objectAtIndex:BBTimeIndex];
    if (year && date && time) {
        NSString *tz = [[BBDataFile defaultTimeZone] isDaylightSavingTime] ? @"-0300" : @"-0400";
        return [NSString stringWithFormat:@"%@/%@ %@%@ %@", year, date, [time length] == 3 ? @"0" : @"", time, tz];
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
    return (unsigned int) [[data objectAtIndex:BBPressureIndex] intValue];
}

- (unsigned int)rainfall
{
    return (unsigned int) [[data objectAtIndex:BBRainfallIndex] intValue];
}

@end
