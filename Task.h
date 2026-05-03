#import <Foundation/Foundation.h>

@interface Task : NSObject <NSCoding>
@property (nonatomic, copy) NSString *taskId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSArray *imagePaths;
@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, copy) NSString *linkUrl;
@property (nonatomic, copy) NSString *linkTitle;
@property (nonatomic, copy) NSString *nextRunTime;
@property (nonatomic, assign) NSInteger repeatCount; // 0=无限重复
@property (nonatomic, assign) NSInteger repeatInterval; // 小时
@property (nonatomic, assign) NSInteger executedCount;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, copy) NSString *lastResult;

- (instancetype)initWithContent:(NSString *)content
                      imagePaths:(NSArray *)imagePaths
                       videoPath:(NSString *)videoPath
                         linkUrl:(NSString *)linkUrl
                       linkTitle:(NSString *)linkTitle
                     nextRunTime:(NSString *)nextRunTime
                     repeatCount:(NSInteger)repeatCount
                  repeatInterval:(NSInteger)repeatInterval;
@end
