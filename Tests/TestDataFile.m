#import "TestDataFile.h"
#import "BBDataFile.h"


@implementation BBDataFile (Testing)

+ (NSURL *)defaultURL
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.monkey-robot.BucknellBug.unittests"];
    NSString *path = [bundle pathForResource:@"raw_data" ofType:@"dat"];
    return [NSURL fileURLWithPath:path];
}

@end


@implementation TestDataFile

- (void)setUp
{
    data = [[BBDataFile alloc] init];
}

- (void)testInit
{
    STAssertNotNil(data, @"BBDataFile instance could not be created.");
}

- (void)testUpdate
{
    STAssertFalse([data update], @"Data was updated.");
}

- (void)testDate
{
    NSDate *shouldBe = [NSDate dateWithString:@"2010-12-20 14:00:00 -0500"];
    STAssertEqualObjects(shouldBe, [data date], @"Date is %@.", [data date]);
}

- (void)testTemperature
{
    STAssertEqualsWithAccuracy(31.03, [data temperature], 0.0001, @"Temperature is %.2f.", [data temperature]);
}

- (void)testHumidity
{
    STAssertEqualsWithAccuracy(52.46, [data humidity], 0.0001, @"Humdity is %.2f.", [data humidity]);
}

- (void)testPressure
{
    STAssertEquals(1008U, [data pressure], @"Pressure is %u.", [data pressure]);
}

- (void)testRainfall
{
    STAssertEquals(0U, [data rainfall], @"Rainfall is %u.", [data rainfall]);
}

- (void)tearDown
{
    [data release]; data = nil;
}

@end
