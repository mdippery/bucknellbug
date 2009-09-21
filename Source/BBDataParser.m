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

#import "BBDataParser.h"

#define NUM_DATA_ITEMS	6U

#define IDX_BASE		-1
#define IDX_YEAR        (IDX_BASE + 2)
#define IDX_DATE        (IDX_BASE + 3)
#define IDX_TIME        (IDX_BASE + 4)
#define IDX_PRESSURE	(IDX_BASE + 8)
#define IDX_TEMP		(IDX_BASE + 13)
#define IDX_HUMIDITY	(IDX_BASE + 17)
#define IDX_RAINFALL	(IDX_BASE + 19)
#define IDX_SUN			(IDX_BASE + 31)

#define VAL_BLANK       [NSNull null]

NSString * const kMDKeyDate 	= @"Last Updated";
NSString * const kMDKeyTemp 	= @"Temperature";
NSString * const kMDKeyHumidity	= @"Humidity";
NSString * const kMDKeySun 		= @"Sunshine Index";
NSString * const kMDKeyPressure = @"Pressure";
NSString * const kMDKeyRainfall = @"Rainfall";
NSString * const kDataFileURL 	= @"http://www.departments.bucknell.edu/geography/Weather/Data/raw_data.dat";

static NSDate *
MakeDateWithStrings(NSString *year, NSString *month, NSString *day, NSString *hour)
{
	NSMutableString *dateStr;
	NSDate *date;
	
	dateStr = [[NSMutableString alloc] initWithFormat:@"%@-", year];
	[dateStr appendFormat:@"%@-%@ ", month, day];
    // NSLog(@"Got date: %@", dateStr);
	
	// Apparently the data stream isn't adjusted for Daylight Savings Time, so
	// if it IS Daylight Saving Time, we have to adjust the string manually,
	// as well as set the time zone
	if ([[NSTimeZone timeZoneWithName:@"US/Eastern"] isDaylightSavingTime]) {
		[dateStr appendFormat:@"%d:00:00 ", ([hour intValue] / 100) - 1];
		[dateStr appendString:@"-0400"];
	} else {
		[dateStr appendFormat:@"%d:00:00 ", [hour intValue] / 100];
		[dateStr appendString:@"-0500"];
	}
	
    NSLog(@"Making date with str: %@", dateStr);
	date = [[NSDate alloc] initWithString:dateStr];
	[dateStr release];
	
	return [date autorelease];
}

@interface BBDataParser (Private)
- (void)setURL:(NSString *)url;
@end

@implementation BBDataParser

- (id)init
{
	return [self initWithURL:kDataFileURL];
}

- (id)initWithURL:(NSString *)url
{
	if ([super init] == nil) return nil;
	
	[self setURL:url];
	if (dataFileURL == nil) {	// A valid URL was not passed, so return nil
		[self autorelease];
		return nil;
	}
	
	lastUpdate = nil;
	//dataCache = nil;
	dataCache = [[NSMutableDictionary alloc] initWithCapacity:NUM_DATA_ITEMS];
		
	return self;
}

- (void)dealloc
{
	[dataFileURL release];
	[lastUpdate release];
	[super dealloc];
}

- (NSString *)description
{
	// A description for debugging purposes
	// It looks something like this:
	//   <MDDataFileParser 0x12345678> (
	//       host = www.host.com
	//       date = (null)
	//       data = <NSCFDictionary 0x12345679>
	//   )
	
	NSMutableString *description = [NSMutableString string];
	
	[description appendFormat:@"<%@: %p> (\n", [self class], self];
	[description appendFormat:@"\thost = %@\n", [dataFileURL host]];
	[description appendFormat:@"\tdate = %@\n", [lastUpdate description]];
	[description appendFormat:@"\tdata = <%@: %p>\n)", [dataCache class], dataCache];
	
	return [[description copy] autorelease];
}

- (void)setURL:(NSString *)url
{
	[dataFileURL release];
	dataFileURL = [[NSURL alloc] initWithString:url];
}

- (NSDictionary *)fetchWeatherData:(BOOL *)hasNewData
{
	// For parse documentation, see
	// http://www.departments.bucknell.edu/geography/Weather/output.htm
	// http://www.departments.bucknell.edu/geography/Weather/Data/raw_data.dat
	
	NSDate		*lastDate;
	NSString	*feedData;
	NSArray		*dataComp;
	
	//NSLog(@"Fetching weather data");
	
	lastDate = nil;
	if (lastUpdate) lastDate = [lastUpdate copy];
	[lastUpdate release]; lastUpdate = nil;
	//NSLog(@"lastDate: %@", lastDate);
	
	feedData = [[NSString alloc] initWithContentsOfURL:dataFileURL
											  encoding:NSWindowsCP1251StringEncoding
												 error:NULL];
	//NSLog(@"feedData: %@", feedData);
	
	/*
	 * Note: -[NSString initWithContentsOfUrl: encoding: error:] should return nil if the
	 * network location cannot be reached, and set an error object, but in my experience, it
	 * does neither; rather, it returns an empty string. Check for both.
	 */
	if (feedData == nil || [feedData length] == 0) {   // Feed URL could not be processed
		//NSLog(@"Weather feed returned no data");
		*hasNewData = NO;
	} else {
		dataComp = [feedData componentsSeparatedByString:@","];
		
		lastUpdate = MakeDateWithStrings([dataComp objectAtIndex:IDX_YEAR],
										 [[dataComp objectAtIndex:IDX_DATE] substringToIndex:2],
										 [[dataComp objectAtIndex:IDX_DATE] substringFromIndex:3],
										 [dataComp objectAtIndex:IDX_TIME]);
		[lastUpdate retain];
		//NSLog(@"lastUpdate: %@", lastUpdate);
		
		/*
		 * Check the dates. If the feed has not changed, just return the cache.
		 * The feed is always updated if lastUpdate == nil; however, nil is not a
		 * valid argument for -[NSDate isEqualToDate:], so check before calling
		 * -[NSDate isEqualToDate].
		 */
		if (lastUpdate == nil || (lastUpdate != nil && ![lastUpdate isEqualToDate:lastDate])) {
			*hasNewData = YES;
			
			//if (!dataCache) dataCache = [[NSMutableDictionary alloc] initWithCapacity:NUM_DATA_ITEMS];
			
			// Set date as seconds since 1970
			[dataCache setObject:[NSNumber numberWithDouble:[lastUpdate timeIntervalSince1970]]
						  forKey:kMDKeyDate];
			[dataCache setObject:[NSNumber numberWithInt:[[dataComp objectAtIndex:IDX_PRESSURE] intValue]]
						  forKey:kMDKeyPressure];
			[dataCache setObject:[NSNumber numberWithFloat:[[dataComp objectAtIndex:IDX_TEMP] floatValue]]
						  forKey:kMDKeyTemp];
			[dataCache setObject:[NSNumber numberWithFloat:[[dataComp objectAtIndex:IDX_HUMIDITY] floatValue]]
						  forKey:kMDKeyHumidity];
			[dataCache setObject:[NSNumber numberWithInt:[[dataComp objectAtIndex:IDX_RAINFALL] intValue]]
						  forKey:kMDKeyRainfall];
			[dataCache setObject:[NSNumber numberWithFloat:[[dataComp objectAtIndex:IDX_SUN] floatValue]]
						  forKey:kMDKeySun];
		} else {
			*hasNewData = NO;
		}
	}
	
	[lastDate release];
	[feedData release];
	
	//return [NSDictionary dictionaryWithDictionary:dataCache];		// Return non-mutable dictionary
	return [[dataCache copy] autorelease];							// Return non-mutable dictionary
}

- (unsigned int)maxCount
{
	return NUM_DATA_ITEMS;
}

@end