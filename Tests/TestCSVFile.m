#import "TestCSVFile.h"
#import "CSVFile.h"


@implementation TestCSVFile

- (void)setUp
{
    data = [[CSVFile alloc] initWithContentsOfString:@"1,2,3"];
}

- (void)testObjectAtIndex
{
    STAssertEqualObjects([data objectAtIndex:0], @"1", @"%@ is not equal to '1'", [data objectAtIndex:0]);
    STAssertEqualObjects([data objectAtIndex:1], @"2", @"%@ is not equal to '2'", [data objectAtIndex:1]);
    STAssertEqualObjects([data objectAtIndex:2], @"3", @"%@ is not equal to '3'", [data objectAtIndex:2]);
}

- (void)testCount
{
    STAssertEquals([data count], 3U, @"%u is not 3", [data count]);
}

- (void)tearDown
{
    [data release]; data = nil;
}

@end
