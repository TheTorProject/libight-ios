#import <Foundation/Foundation.h>

/**
 * ExperimentSettings is the interface that settings passed to this engine
 * must implement. It allows the engine to discover the name of the task
 * that we want to run and to obtain its serialization.
 */
@protocol ExperimentSettings

/** taskName returns the task name */
- (NSString*) taskName;

/**
 * serialization returns the JSON serialization of the task config, which
 * must be compatible with Measurement Kit v0.9.0 specification.
 */
- (NSString*) serialization;

@end
