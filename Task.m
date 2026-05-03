#import "Task.h"

@implementation Task

- (instancetype)initWithContent:(NSString *)content
                      imagePaths:(NSArray *)imagePaths
                       videoPath:(NSString *)videoPath
                         linkUrl:(NSString *)linkUrl
                       linkTitle:(NSString *)linkTitle
                     nextRunTime:(NSString *)nextRunTime
                     repeatCount:(NSInteger)repeatCount
                  repeatInterval:(NSInteger)repeatInterval {
    self = [super init];
    if (self) {
        _taskId = [[NSUUID UUID] UUIDString];
        _content = content;
        _imagePaths = imagePaths;
        _videoPath = videoPath;
        _linkUrl = linkUrl;
        _linkTitle = linkTitle;
        _nextRunTime = nextRunTime;
        _repeatCount = repeatCount;
        _repeatInterval = repeatInterval;
        _executedCount = 0;
        _enabled = YES;
        _lastResult = @"未执行";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.taskId forKey:@"taskId"];
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeObject:self.imagePaths forKey:@"imagePaths"];
    [coder encodeObject:self.videoPath forKey:@"videoPath"];
    [coder encodeObject:self.linkUrl forKey:@"linkUrl"];
    [coder encodeObject:self.linkTitle forKey:@"linkTitle"];
    [coder encodeObject:self.nextRunTime forKey:@"nextRunTime"];
    [coder encodeInteger:self.repeatCount forKey:@"repeatCount"];
    [coder encodeInteger:self.repeatInterval forKey:@"repeatInterval"];
    [coder encodeInteger:self.executedCount forKey:@"executedCount"];
    [coder encodeBool:self.enabled forKey:@"enabled"];
    [coder encodeObject:self.lastResult forKey:@"lastResult"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _taskId = [decoder decodeObjectForKey:@"taskId"];
        _content = [decoder decodeObjectForKey:@"content"];
        _imagePaths = [decoder decodeObjectForKey:@"imagePaths"];
        _videoPath = [decoder decodeObjectForKey:@"videoPath"];
        _linkUrl = [decoder decodeObjectForKey:@"linkUrl"];
        _linkTitle = [decoder decodeObjectForKey:@"linkTitle"];
        _nextRunTime = [decoder decodeObjectForKey:@"nextRunTime"];
        _repeatCount = [decoder decodeIntegerForKey:@"repeatCount"];
        _repeatInterval = [decoder decodeIntegerForKey:@"repeatInterval"];
        _executedCount = [decoder decodeIntegerForKey:@"executedCount"];
        _enabled = [decoder decodeBoolForKey:@"enabled"];
        _lastResult = [decoder decodeObjectForKey:@"lastResult"];
    }
    return self;
}

@end
