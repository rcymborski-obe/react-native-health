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

@end
