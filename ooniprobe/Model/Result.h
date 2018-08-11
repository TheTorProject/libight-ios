#import <Foundation/Foundation.h>
#import <SharkORM/SharkORM.h>
#import "JsonResult.h"

@interface Result : SRKObject

@property NSString *name;
@property NSDate *startTime;
@property float duration;
@property long dataUsageDown;
@property long dataUsageUp;
@property NSString *ip;
@property NSString *asn;
@property NSString *asnName;
@property NSString *country;
@property NSString *networkName;
@property NSString *networkType;
@property BOOL viewed;
@property BOOL done;

//- (long)failedMeasurements;
//- (long)okMeasurements;
//- (long)anomalousMeasurements;
-(NSString*)getAsn;
-(NSString*)getAsnName;
-(NSString*)getCountry;
-(NSString*)getFormattedDataUsageDown;
-(NSString*)getFormattedDataUsageUp;
-(NSString*)getLocalizedNetworkType;
//-(void)setStartTimeWithUTCstr:(NSString*)dateStr;
-(void)addDuration:(float)value;
-(void)save;
-(SRKResultSet*)measurements;
-(void)deleteObject;
@end
