#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "NSDate+Mock.h"
#import "WPRatingsHelper.h"



@interface WPRatingsHelperTests : XCTestCase

@end

@implementation WPRatingsHelperTests

- (void)setUp
{
    [super setUp];
    
    // Nuke previous defaults
    NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    
    for (NSString *key in defaults.allKeys) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    
    // Swizzle NSDate Mock Methods
    [NSDate swizzleMock];
    
    // Initialize WPRatingsHelper
    [[WPRatingsHelper sharedInstance] initializeForVersion:@"1.0"];
    [[WPRatingsHelper sharedInstance] setSignificantEventsCount:1];
    [[WPRatingsHelper sharedInstance] setRatingsDisabled:NO];
}

- (void)tearDown
{
    [super tearDown];
    
    // Unswizzle NSDate
    [NSDate swizzleMock];
}

- (void)testCheckForPromptReturnsFalseWithoutEnoughSignificantEvents
{
    [[WPRatingsHelper sharedInstance] setSignificantEventsCount:1];
    XCTAssertFalse([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
}

- (void)testCheckForPromptReturnsTrueWithEnoughSignificantEvents
{
    NSInteger const requiredEvents = 5;
    [[WPRatingsHelper sharedInstance] setSignificantEventsCount:requiredEvents];
    
    for (NSInteger i = 0; ++i < requiredEvents;) {
        [[WPRatingsHelper sharedInstance] incrementSignificantEvent];
        XCTAssertFalse([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
    }
    
    [[WPRatingsHelper sharedInstance] incrementSignificantEvent];
    XCTAssertTrue([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
}

- (void)testCheckForPromptReturnsFalseIfUserHasRatedCurrentVersion
{
    [self createConditionsForPositiveAppReviewPrompt];
    XCTAssertTrue([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
    [[WPRatingsHelper sharedInstance] ratedCurrentVersion];
    XCTAssertFalse([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
}

- (void)testCheckForPromptReturnsFalseIfUserHasGivenFeedbackForCurrentVersion
{
    [self createConditionsForPositiveAppReviewPrompt];
    XCTAssertTrue([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
    [[WPRatingsHelper sharedInstance] gaveFeedbackForCurrentVersion];
    XCTAssertFalse([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
}

- (void)testCheckForPromptReturnsFalseIfUserHasDeclinedToRateCurrentVersion
{
    [self createConditionsForPositiveAppReviewPrompt];
    XCTAssertTrue([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
    [[WPRatingsHelper sharedInstance] declinedToRateCurrentVersion];
    XCTAssertFalse([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
}

- (void)testCheckForPromptShouldResetForNewVersion
{
    [self createConditionsForPositiveAppReviewPrompt];
    XCTAssertTrue([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
    [[WPRatingsHelper sharedInstance] initializeForVersion:@"2.0"];
    XCTAssertFalse([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
}

- (void)testCheckForPromptShouldTriggerWithNewVersion
{
    [self createConditionsForPositiveAppReviewPrompt];
    XCTAssertTrue([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
    
    [[WPRatingsHelper sharedInstance] initializeForVersion:@"2.0"];
    XCTAssertFalse([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
    
    [self createConditionsForPositiveAppReviewPrompt];
    XCTAssertTrue([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
}

- (void)testRatingsDisabledPreventsPopupEvenWhenConditionsAreMet
{
    [self createConditionsForPositiveAppReviewPrompt];
    XCTAssertTrue([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
    [[WPRatingsHelper sharedInstance] setRatingsDisabled:YES];
    XCTAssertFalse([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
}

- (void)testUserIsNotPromptedForAReviewForTheNumberOfSpecifiedVersionsIfTheyLikedTheApp;
{
    NSInteger const likeSkipsVersions = 4;
    
    [[WPRatingsHelper sharedInstance] initializeForVersion:@"0"];
    XCTAssertFalse([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
    
    [self createConditionsForPositiveAppReviewPrompt];
    XCTAssertTrue([[WPRatingsHelper sharedInstance] shouldPromptForAppReview], @"Prompt should be displayed");
    
    [[WPRatingsHelper sharedInstance] setLikeSkipVersions:likeSkipsVersions];
    [[WPRatingsHelper sharedInstance] likedCurrentVersion];
    
    XCTAssertTrue([self verifyVersionsAreSkipped:likeSkipsVersions], @"An incorrect number of versions was skipped");
}

- (void)testUserIsNotPromptedForAReviewForTheNumberOfSpecifiedVersionsIfTheyDislikedTheApp
{
    NSInteger const dislikeSkipsVersions = 8;
    
    [[WPRatingsHelper sharedInstance] initializeForVersion:@"0"];
    XCTAssertFalse([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
    
    [self createConditionsForPositiveAppReviewPrompt];
    XCTAssertTrue([[WPRatingsHelper sharedInstance] shouldPromptForAppReview], @"Prompt should be displayed");
    
    [[WPRatingsHelper sharedInstance] setDislikeSkipVersions:dislikeSkipsVersions];
    [[WPRatingsHelper sharedInstance] dislikedCurrentVersion];
    
    XCTAssertTrue([self verifyVersionsAreSkipped:dislikeSkipsVersions], @"An incorrect number of versions was skipped");
}

- (void)testUserIsNotPromptedForAReviewForTheNumberOfSpecifiedVersionsIfTheyDeclineToRate
{
    NSInteger const declineSkipsVersions = 6;
    
    [[WPRatingsHelper sharedInstance] initializeForVersion:@"0"];
    XCTAssertFalse([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]);
    
    [self createConditionsForPositiveAppReviewPrompt];
    XCTAssertTrue([[WPRatingsHelper sharedInstance] shouldPromptForAppReview], @"Prompt should be displayed");
    
    [[WPRatingsHelper sharedInstance] setDeclineSkipVersions:declineSkipsVersions];
    [[WPRatingsHelper sharedInstance] declinedToRateCurrentVersion];
    
    XCTAssertTrue([self verifyVersionsAreSkipped:declineSkipsVersions], @"An incorrect number of versions was skipped");
}

- (void)testUserIsAskedToRateMultipleTimesInTheSameVersion
{
    [[WPRatingsHelper sharedInstance] initializeForVersion:@"0"];
    
    [self createConditionsForPositiveAppReviewPrompt];
    
    for (NSInteger i = 0; ++i < 10; ) {
        XCTAssertTrue([[WPRatingsHelper sharedInstance] shouldPromptForAppReview], @"User should be prompted");
    }
}

- (void)testUserIsAskedToRateOnlyAfterEnoughDaysHaveElapsed
{
    NSInteger minimumElapsedDays = [[WPRatingsHelper sharedInstance] minimumIntervalDays];
    
    [[WPRatingsHelper sharedInstance] initializeForVersion:@"0"];
    
    [self createConditionsForPositiveAppReviewPrompt];
    XCTAssertTrue([[WPRatingsHelper sharedInstance] shouldPromptForAppReview], @"User should be prompted");
    
    [[WPRatingsHelper sharedInstance] initializeForVersion:@"1"];
    XCTAssertFalse([[WPRatingsHelper sharedInstance] shouldPromptForAppReview], @"User should NOT be prompted");
    
    NSDate *date = [[NSDate date] dateByAddingDays:minimumElapsedDays];
    [NSDate setMockDate:date];
    
    XCTAssertFalse([[WPRatingsHelper sharedInstance] shouldPromptForAppReview], @"User should NOT be prompted");
    [[WPRatingsHelper sharedInstance] incrementSignificantEvent];
    XCTAssertTrue([[WPRatingsHelper sharedInstance] shouldPromptForAppReview], @"User should be prompted");
}

- (void)testHasUserEverLikedApp
{
    [[WPRatingsHelper sharedInstance] initializeForVersion:@"4.7"];
    XCTAssertFalse([[WPRatingsHelper sharedInstance] hasUserEverLikedApp]);
    [[WPRatingsHelper sharedInstance] declinedToRateCurrentVersion];
    
    [[WPRatingsHelper sharedInstance] initializeForVersion:@"4.8"];
    XCTAssertFalse([[WPRatingsHelper sharedInstance] hasUserEverLikedApp]);
    [[WPRatingsHelper sharedInstance] likedCurrentVersion];
    XCTAssertTrue([[WPRatingsHelper sharedInstance] hasUserEverLikedApp]);
    
    [[WPRatingsHelper sharedInstance] initializeForVersion:@"4.9"];
    [[WPRatingsHelper sharedInstance] dislikedCurrentVersion];
    XCTAssertTrue([[WPRatingsHelper sharedInstance] hasUserEverLikedApp]);
}

- (void)testHasUserEverDislikedTheApp
{
    [[WPRatingsHelper sharedInstance] initializeForVersion:@"4.7"];
    XCTAssertFalse([[WPRatingsHelper sharedInstance] hasUserEverDislikedApp]);
    [[WPRatingsHelper sharedInstance] declinedToRateCurrentVersion];
    
    [[WPRatingsHelper sharedInstance] initializeForVersion:@"4.8"];
    XCTAssertFalse([[WPRatingsHelper sharedInstance] hasUserEverDislikedApp]);
    [[WPRatingsHelper sharedInstance] dislikedCurrentVersion];
    XCTAssertTrue([[WPRatingsHelper sharedInstance] hasUserEverDislikedApp]);
    
    [[WPRatingsHelper sharedInstance] initializeForVersion:@"4.9"];
    [[WPRatingsHelper sharedInstance] likedCurrentVersion];
    XCTAssertTrue([[WPRatingsHelper sharedInstance] hasUserEverDislikedApp]);
}


#pragma mark - Private Helpers

- (void)createConditionsForPositiveAppReviewPrompt
{
    WPRatingsHelper *ratings = [WPRatingsHelper sharedInstance];
    [ratings setSignificantEventsCount:1];
    [ratings incrementSignificantEvent];
    
    NSDate *newDate = [[NSDate date] dateByAddingDays:ratings.minimumIntervalDays];
    [NSDate setMockDate:newDate];
}

- (BOOL)verifyVersionsAreSkipped:(NSInteger)count
{
    for (NSInteger i = 0; ++i <= count; ) {
        [[WPRatingsHelper sharedInstance] initializeForVersion:[@(i) stringValue]];
        [[WPRatingsHelper sharedInstance] incrementSignificantEvent];
        
        if ([[WPRatingsHelper sharedInstance] shouldPromptForAppReview]) {
            return false;
        }
    }
    
    [[WPRatingsHelper sharedInstance] initializeForVersion:[@(count + 1) stringValue]];
    [self createConditionsForPositiveAppReviewPrompt];
    
    return [[WPRatingsHelper sharedInstance] shouldPromptForAppReview];
}

@end
