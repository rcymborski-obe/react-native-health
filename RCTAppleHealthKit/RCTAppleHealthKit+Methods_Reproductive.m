//
//  RCTAppleHealthKit+Methods_Reproductive.m
//  RCTAppleHealthKit
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.

#import "RCTAppleHealthKit+Methods_Reproductive.h"
#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"

@implementation RCTAppleHealthKit (Methods_Reproductive)

- (void)reproductive_getSexualActivity:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
    double limit = [RCTAppleHealthKit doubleFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];

    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc]
                                            initWithKey:HKSampleSortIdentifierEndDate
                                            ascending:NO
    ];

    HKCategoryType *type = [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSexualActivity];
    NSPredicate *predicate = [RCTAppleHealthKit predicateForSamplesBetweenDates:startDate endDate:endDate];

    HKSampleQuery *query = [[HKSampleQuery alloc]
                            initWithSampleType:type
                            predicate:predicate
                            limit: limit
                            sortDescriptors:@[timeSortDescriptor]
                            resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {

        if (error != nil) {
            NSLog(@"error with fetchCumulativeSumStatisticsCollection: %@", error);
            callback(@[RCTMakeError(@"error with fetchCumulativeSumStatisticsCollection", error, nil)]);
            return;
        }

        NSMutableArray *data = [NSMutableArray arrayWithCapacity:(10)];

        for (HKCategorySample *sample in results) {
            NSLog(@"sample for sexual activity %@", sample);
            NSString *startDateString = [RCTAppleHealthKit buildISO8601StringFromDate:sample.startDate];
            NSString *endDateString = [RCTAppleHealthKit buildISO8601StringFromDate:sample.endDate];

            NSDictionary *elem = @{
                @"startDate" : startDateString,
                @"endDate" : endDateString,
                @"metadata": sample.metadata == nil ? [NSNull null] : sample.metadata,
            };

            [data addObject:elem];
        }
        callback(@[[NSNull null], data]);
    }
    ];
    [self.healthStore executeQuery:query];
}

- (void)reproductive_getBasalBodyTemperatureSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *basalBodyTemperatureType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBasalBodyTemperature];
    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:[HKUnit degreeCelsiusUnit]];
    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    BOOL ascending = [RCTAppleHealthKit boolFromOptions:input key:@"ascending" withDefault:false];
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    NSPredicate * predicate = [RCTAppleHealthKit predicateForSamplesBetweenDates:startDate endDate:endDate];

    [self fetchQuantitySamplesOfType:basalBodyTemperatureType
                                unit:unit
                           predicate:predicate
                           ascending:ascending
                               limit:limit
                          completion:^(NSArray *results, NSError *error) {
        if(results){
            callback(@[[NSNull null], results]);
            return;
        } else {
            NSLog(@"An error occured while retrieving the basal body temperature sample %@. The error was: ", error);
            callback(@[RCTMakeError(@"An error occured while retrieving the basal body temperature sample", error, nil)]);
            return;
        }
    }];
}


- (void)reproductive_getMenstrualFlowSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }

    NSPredicate *predicate = [RCTAppleHealthKit predicateForSamplesBetweenDates:startDate endDate:endDate];
    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];


    [self fetchMenstrualFlowSamplesForPredicate:predicate
                                          limit:limit
                                     completion:^(NSArray *results, NSError *error) {
                                         if(results){
                                             callback(@[[NSNull null], results]);
                                             return;
                                         } else {
                                             callback(@[RCTJSErrorFromNSError(error)]);
                                             return;
                                         }
                                     }];

}

@end
