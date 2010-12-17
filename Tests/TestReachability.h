#import <SenTestingKit/SenTestingKit.h>

@class MDReachability;


@interface TestReachability : SenTestCase
{
    MDReachability *goodReachability;
    MDReachability *badReachability;
}
@end
