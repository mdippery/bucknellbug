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
#import "NSDate+BucknellBug.h"

#define DATA_FILE_URL   @"http://www.departments.bucknell.edu/geography/Weather/Data/raw_data.dat"
#define DATA_FILE_ENC   NSWindowsCP1251StringEncoding

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
- (void)resetData;
@end

@implementation BBDataFile

+ (NSString *)rawData
{
    return [NSString stringWithContentsOfURL:[NSURL URLWithString:DATA_FILE_URL] encoding:DATA_FILE_ENC error:NULL];
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
    return [NSString stringWithFormat:@"<%@ %p> (data = %@)", [self class], self, data];
}

- (void)resetData
{
    [data release];
    data = [[CSVFile alloc] initWithContentsOfURL:[NSURL URLWithString:DATA_FILE_URL] encoding:DATA_FILE_ENC];
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
    NSString *y = [data objectAtIndex:BBYearIndex];
    NSString *d = [data objectAtIndex:BBDateIndex];
    NSString *t = [data objectAtIndex:BBTimeIndex];
    if (y && d && t) {
        return [NSDate dateWithYear:y month:[d substringToIndex:2] day:[d substringFromIndex:3] hour:t];
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
