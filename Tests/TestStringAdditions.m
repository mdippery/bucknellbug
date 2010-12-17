#import "TestStringAdditions.h"
#import "NSString+Numeric.h"


@implementation TestStringAdditions

- (void)setUp
{
    defaultString = [[NSString alloc] initWithFormat:@"%u", 1024];
}

- (void)testUnsignedIntValue
{
    STAssertEquals([defaultString unsignedIntValue], 1024U, @"%u is not equal to 1024.", [defaultString unsignedIntValue]);
}

- (void)tearDown
{
    [defaultString release]; defaultString = nil;
}

@end
