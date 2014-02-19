//
//  Candidate+API.m
//  VotingInformationProject
//
//  Created by Andrew Fink on 2/6/14.
//  
//

#import "Candidate+API.h"

@implementation Candidate (API)

- (void)getCandidatePhotoData
{
    if (!self.photoUrl) {
        return;
    }

    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig];
    NSURL *url = [NSURL URLWithString:self.photoUrl];

    // Create URL request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";

    // Create data task
    NSURLSessionDataTask *getPhotoDataTask =
    [session dataTaskWithRequest:request
               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error) {
            NSLog(@"Candidate %@ error getting photo: %@", self.name, error);
            return;
        }
        self.photo = data;
    }];

    // Execute request
    [getPhotoDataTask resume];
}

- (NSMutableArray*)getLinksDataArray
{
    NSMutableArray *links = [[NSMutableArray alloc] initWithCapacity:3];
    if (self.candidateUrl) {
        [links addObject:@{
                           @"buttonTitle": NSLocalizedString(@"Website", nil),
                           @"description": NSLocalizedString(@"Website", nil),
                           @"url": self.candidateUrl,
                           @"urlScheme": @(kCandidateLinkTypeWebsite)
                           }];
    }
    if (self.phone) {
        [links addObject:@{
                           @"buttonTitle": NSLocalizedString(@"Call", nil),
                           @"description": NSLocalizedString(@"Phone", nil),
                           @"url": self.phone,
                           @"urlScheme": @(kCandidateLinkTypePhone)
                           }];
    }
    if (self.email) {
        [links addObject:@{
                           @"buttonTitle": NSLocalizedString(@"Email", nil),
                           @"description": NSLocalizedString(@"Email", nil),
                           @"url": self.email,
                           @"urlScheme": @(kCandidateLinkTypeEmail)
                           }];
    }
    return links;
}

+ (Candidate*) setFromDictionary:(NSDictionary *)attributes
{
    NSMutableDictionary *mutableAttributes = [attributes mutableCopy];

    NSString *channelsKey = @"channels";
    NSArray* channels = attributes[channelsKey];
    [mutableAttributes removeObjectForKey:channelsKey];

    Candidate *candidate = [Candidate MR_createEntity];
    // Set attributes
    [candidate setValuesForKeysWithDictionary:mutableAttributes];

    // Set Social Channels
    for (NSDictionary* channel in channels) {
        [candidate addSocialChannelsObject:[SocialChannel setFromDictionary:channel]];
    }
    // FIXME: Remove on release
    [candidate stubCandidateData];

    // Download photo from url
    [candidate getCandidatePhotoData];

    return candidate;
}

/**
 *  Temporary method for stubbing a bit of candidate data for testing
 *  Sets social channels and an email/phone
 *  @warning Remove for final release
 */
- (void) stubCandidateData
{
#if DEBUG
        SocialChannel *twitter =
        (SocialChannel*)[SocialChannel setFromDictionary:@{@"type": @"Twitter", @"id": @"VotingInfo"}];
        [self addSocialChannelsObject:twitter];

        SocialChannel *facebook =
        (SocialChannel*)[SocialChannel setFromDictionary:@{@"type": @"Facebook", @"id": @"VotingInfo"}];
        [self addSocialChannelsObject:facebook];

        SocialChannel *youtube =
        (SocialChannel*)[SocialChannel setFromDictionary:@{@"type": @"YouTube", @"id": @"pew"}];
        [self addSocialChannelsObject:youtube];

        self.email = @"info@azavea.com";
        self.phone = @"(123)456-7890";
#endif
}

@end