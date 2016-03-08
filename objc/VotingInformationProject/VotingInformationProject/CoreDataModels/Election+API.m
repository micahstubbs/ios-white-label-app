//
//  Election+API.m
//  VotingInformationProject
//
//  Created by Andrew Fink on 6/24/14.
//

#import "Election+API.h"
#import "AppSettings.h"
#import "AFNetworking/AFNetworking.h"
#import "VIPError.h"

@implementation Election (API)

- (NSString *) getDateString
{
    NSString *electionDateString = nil;
    if (self.electionDay) {
        NSDateFormatter *yyyymmddFormatter = [[NSDateFormatter alloc] init];
        [yyyymmddFormatter setDateStyle:NSDateFormatterMediumStyle];
        [yyyymmddFormatter setTimeStyle:NSDateFormatterNoStyle];
        electionDateString = [yyyymmddFormatter stringFromDate:self.electionDay];
    }
    return electionDateString;
}

- (BOOL)isExpired
{
    if (!self.electionDay) {
        return YES;
    }
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 1;

    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *expireDate = [theCalendar dateByAddingComponents:dayComponent
                                                      toDate:self.electionDay
                                                     options:0];
    NSDate *now = [NSDate date];
    return [now compare:expireDate] == NSOrderedDescending;
}

+ (NSDateFormatter*)getElectionDateFormatter
{
    // setup date formatter
    static dispatch_once_t onceToken;
    static NSDateFormatter *yyyymmddFormatter = nil;
    dispatch_once(&onceToken, ^{
        yyyymmddFormatter = [[NSDateFormatter alloc] init];
        [yyyymmddFormatter setDateFormat:@"yyyy-MM-dd"];
    });
    return yyyymmddFormatter;
}

+ (NSDate*)today
{
    NSCalendarUnit units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:units fromDate:[NSDate date]];
    comps.day = comps.day - 1;
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

@end
