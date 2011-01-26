#import "TestDateAdditions.h"
#import "NSDate+Relative.h"

#define HOURS_48    (60 * 60 * 48)


@implementation TestDateAdditions

- (void)setUp
{
    defaultDate = [[NSDate alloc] initWithString:@"2010-11-15 08:30:15 -0400"];
    sameDay = [[NSDate alloc] initWithString:@"2009-01-15 22:15:00 -0500"];
    future = [[NSDate distantFuture] retain];
    past = [[NSDate distantPast] retain];
}

- (void)testDayOfMonth
{
    STAssertEquals([defaultDate dayOfMonth], 15, @"Day of month is %d (should be 15).", [defaultDate dayOfMonth]);
    STAssertEquals([sameDay dayOfMonth], [defaultDate dayOfMonth], @"%@ is not equal to %@.", [sameDay dayOfMonth], [defaultDate dayOfMonth]);
}

- (void)testIsAfter
{
    STAssertTrue([defaultDate isAfter:past], @"%@ is not after %@.", defaultDate, past);
    STAssertTrue([defaultDate isAfter:sameDay], @"%@ is not after %@", defaultDate, sameDay);
    STAssertFalse([defaultDate isAfter:future], @"%@ is after %@.", defaultDate, future);
}

- (void)testIsBefore
{
    STAssertFalse([defaultDate isBefore:past], @"%@ is before %@.", defaultDate, past);
    STAssertTrue([sameDay isBefore:defaultDate], @"%@ is not before %@", sameDay, defaultDate);
    STAssertTrue([defaultDate isBefore:future], @"%@ is not before %@.", defaultDate, future);
}

- (void)testIsToday
{
    STAssertFalse([defaultDate isToday], @"%@ is today.", defaultDate);
    STAssertFalse([sameDay isToday], @"%@ is today.", sameDay);
    STAssertTrue([[NSDate date] isToday], @"%@ is not today.", [NSDate date]);
}

- (void)testIsTomorrowOrLater
{
    STAssertFalse([defaultDate isTomorrowOrLater], @"%@ is tomorrow or later.", defaultDate);
    STAssertTrue([future isTomorrowOrLater], @"%@ is not tomorrow or later.", future);
    STAssertFalse([past isTomorrowOrLater], @"%@ is tomorrow or later.", past);
}

- (void)testIsYesterdayOrEarlier
{
    STAssertTrue([defaultDate isYesterdayOrEarlier], @"%@ is not yesterday or earlier.", defaultDate);
    STAssertFalse([future isYesterdayOrEarlier], @"%@ is yesterday or earlier.", future);
    STAssertTrue([past isYesterdayOrEarlier], @"%@ is not yesterday or earlier.", past);
}

- (void)testDaysSinceToday
{
    NSDate *later = [[NSDate date] addTimeInterval:HOURS_48];
    NSDate *earlier = [[NSDate date] addTimeInterval:-HOURS_48];
    STAssertEquals([later daysSinceToday], 2, @"Number of days between now and %@ is %d.", later, [later daysSinceToday]);
    STAssertEquals([earlier daysSinceToday], -2, @"Number of days between now and %@ is %d.", earlier, [earlier daysSinceToday]);
    STAssertEquals([[NSDate date] daysSinceToday], 0, @"Number of days between now and %@ is %d.", [NSDate date], [[NSDate date] daysSinceToday]);
}

- (void)tearDown
{
    [defaultDate release]; defaultDate = nil;
    [sameDay release]; sameDay = nil;
    [future release]; future = nil;
    [past release]; past = nil;
}

@end
