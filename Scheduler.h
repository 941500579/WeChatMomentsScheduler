#import <Foundation/Foundation.h>
#import "Task.h"

@interface Scheduler : NSObject
@property (nonatomic, strong) NSMutableArray *tasks;
@property (nonatomic, strong) Task *currentTask;
@property (nonatomic, assign) BOOL isPosting;

+ (instancetype)sharedScheduler;
- (void)start;
- (void)addTask:(Task *)task;
- (void)deleteTask:(Task *)task;
- (void)markTaskAsCompleted;
- (void)markTaskAsFailedWithError:(int)error;
- (BOOL)postMomentWithTask:(Task *)task;
@end
