//
//  CivicInfoAPI.m
//  VotingInformationProject
//
//  Created by Andrew Fink on 10/6/14.
//

#import "CivicInfoAPI.h"

#import "AFNetworking/AFNetworking.h"
#import "AppSettings.h"
#import "VIPError.h"

@implementation CivicInfoAPI

+ (void) getVotingInfo:(NSString*)address
           forElection:(Election*)election
              callback:(void (^) (UserElection* votingInfo, NSError *error)) statusBlock
{
    if ([address length] == 0) {
        NSError *error = [VIPError errorWithCode:VIPError.InvalidUserAddress];
        statusBlock(nil, error);
        return;
    }
  
    NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"CivicAPIKey" ofType:@"plist"];
    NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:settingsPath];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // Serializes the http body POST parameters as JSON, which is what the Civic Info API expects
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    NSString *url = @"https://www.googleapis.com/civicinfo/v2/voterinfo";
    NSString *apiKey = [settings objectForKey:@"GoogleCivicInfoAPIKey"];

#if DEBUG
    // Stoplight is an API modeling tool. See "Using Stoplight API modeling tool" in the read me file.
    NSString *stoplightAPIKey = [settings objectForKey:@"StoplightAPIKey"];
    if (stoplightAPIKey != nil && ![stoplightAPIKey isEqualToString:@""]) {
        url = [NSString stringWithFormat:@"https://%@.stoplight-proxy.io/civicinfo/v2/voterinfo", stoplightAPIKey];
    }
#endif
  
    id official = [[AppSettings settings] objectForKey:@"OfficialOnly"];
    BOOL officialOnly = official ? [official boolValue] : NO;
    id testData = [[AppSettings settings] objectForKey:@"UseTestData"];
    BOOL useTestData = testData ? [testData boolValue] : NO;
    NSString *officialOnlyString = officialOnly ? @"True" : @"False";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{
        @"address": address,
        @"key": apiKey,
        @"officialOnly": officialOnlyString
    }];
    if (useTestData) {
      [params setObject:@"2000" forKey:@"electionId"];
    } else if (election && [election.id length] != 0) {
      // Removing this parameter, it seems to be taking precendence over
      // the address search text.
//        [params setObject:election.id forKey:@"electionId"];
    }
    if ([[AppSettings settings] valueForKey:@"DEBUG"]) {
        [params setObject:@"False" forKey:@"productionDataOnly"];
    }

    NSLog(@"VoterInfo Query: %@", url);
    [manager GET:url
       parameters:params
          success:^(AFHTTPRequestOperation *operation, NSDictionary *json) {
              NSError *error = nil;
              UserElection *votingInfo = [[UserElection alloc] initWithDictionary:json error:&error];
              statusBlock(votingInfo, error);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSError *vipError = [VIPError vipResponseToError:operation.responseObject];
              NSLog(@"Response Error: %@", operation.responseObject);
              statusBlock(nil, vipError);
          }];
}

@end
