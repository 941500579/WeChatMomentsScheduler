#import "Scheduler.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation Scheduler

+ (instancetype)sharedScheduler {
    static Scheduler *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadTasks];
        self.isPosting = NO;
    }
    return self;
}

- (void)start {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 60 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [self checkTasks];
    });
    dispatch_resume(timer);
}

- (void)checkTasks {
    if (self.isPosting) return;
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN_POSIX"];
    NSString *nowStr = [formatter stringFromDate:now];
    
    for (Task *task in self.tasks) {
        if (!task.enabled || (task.repeatCount != 0 && task.executedCount >= task.repeatCount)) {
            continue;
        }
        
        if ([task.nextRunTime isEqualToString:nowStr]) {
            self.currentTask = task;
            self.isPosting = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self postMomentWithTask:task];
            });
            break;
        }
    }
}

- (BOOL)postMomentWithTask:(Task *)task {
    NSLog(@"开始发布朋友圈任务：%@", task.content);
    
    id wechat = [objc_getClass("MMServiceCenter") getService:objc_getClass("CMessageMgr")];
    if (!wechat) {
        NSLog(@"错误：无法获取微信消息管理器");
        self.isPosting = NO;
        return NO;
    }
    
    id moment = [[objc_getClass("CMoment") alloc] init];
    if (!moment) {
        NSLog(@"错误：无法创建朋友圈对象");
        self.isPosting = NO;
        return NO;
    }
    
    if (task.content) [moment setValue:task.content forKey:@"content"];
    
    if (task.imagePaths.count > 0) {
        NSMutableArray *mediaItems = [NSMutableArray array];
        for (NSString *path in task.imagePaths) {
            id mediaItem = [[objc_getClass("CMediaItem") alloc] init];
            [mediaItem setValue:path forKey:@"localPath"];
            [mediaItem setValue:@(1) forKey:@"type"];
            [mediaItems addObject:mediaItem];
        }
        [moment setValue:mediaItems forKey:@"mediaList"];
    }
    
    if (task.videoPath) {
        id mediaItem = [[objc_getClass("CMediaItem") alloc] init];
        [mediaItem setValue:task.videoPath forKey:@"localPath"];
        [mediaItem setValue:@(2) forKey:@"type"];
        [moment setValue:@[mediaItem] forKey:@"mediaList"];
    }
    
    if (task.linkUrl) {
        id linkInfo = [[objc_getClass("CLinkInfo") alloc] init];
        [linkInfo setValue:task.linkUrl forKey:@"url"];
        [linkInfo setValue:task.linkTitle forKey:@"title"];
        [moment setValue:linkInfo forKey:@"linkInfo"];
    }
    
    [wechat performSelector:@selector(sendMoment:) withObject:moment];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isPosting) {
            NSLog(@"发布超时，重置状态");
            self.isPosting = NO;
            self.currentTask.lastResult = @"超时";
            [self saveTasks];
        }
    });
    
    return YES;
}

- (void)updateNextRunTimeForTask:(Task *)task {
    if (task.repeatCount != 0 && task.executedCount >= task.repeatCount) {
        task.enabled = NO;
        return;
    }
    
    NSDate *nextDate = [NSDate dateWithTimeInterval:task.repeatInterval * 3600 sinceDate:[NSDate date]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN_POSIX"];
    task.nextRunTime = [formatter stringFromDate:nextDate];
}

- (void)markTaskAsCompleted {
    if (!self.currentTask) return;
    
    self.currentTask.lastResult = @"成功";
    self.currentTask.executedCount++;
    [self updateNextRunTimeForTask:self.currentTask];
    [self saveTasks];
    
    self.currentTask = nil;
    self.isPosting = NO;
    
    NSLog(@"朋友圈发布成功");
}

- (void)markTaskAsFailedWithError:(int)error {
    if (!self.currentTask) return;
    
    self.currentTask.lastResult = [NSString stringWithFormat:@"失败(%d)", error];
    [self saveTasks];
    
    self.currentTask = nil;
    self.isPosting = NO;
    
    NSLog(@"朋友圈发布失败，错误码：%d", error);
}

- (void)addTask:(Task *)task {
    [self.tasks addObject:task];
    [self saveTasks];
}

- (void)deleteTask:(Task *)task {
    [self.tasks removeObject:task];
    [self saveTasks];
}

- (void)loadTasks {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"moments_tasks.plist"];
    self.tasks = [NSMutableArray arrayWithContentsOfFile:path] ?: [NSMutableArray array];
}

- (void)saveTasks {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"moments_tasks.plist"];
    [self.tasks writeToFile:path atomically:YES];
}

@end
