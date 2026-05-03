#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Scheduler.h"
#import "TaskListViewController.h"

%hook MMTableViewInfo

- (void)reloadData {
    %orig;
    
    Class moreVCClass = NSClassFromString(@"MoreViewController");
    if (!moreVCClass) moreVCClass = NSClassFromString(@"WCAccountMoreViewController");
    
    if ([self.viewController isKindOfClass:moreVCClass]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            MMTableViewSectionInfo *section = [self getSectionInfoAt:0];
            if (section && section.rows.count >= 3) {
                MMTableViewCellInfo *cell;
                if ([MMTableViewCellInfo respondsToSelector:@selector(defaultCellInfoWithText:detailText:image:target:action:)]) {
                    cell = [MMTableViewCellInfo defaultCellInfoWithText:@"定时发朋友圈"
                                                                detailText:nil
                                                                 image:nil
                                                                target:self
                                                                action:@selector(openScheduler:)];
                } else {
                    cell = [MMTableViewCellInfo cellForNormalWithText:@"定时发朋友圈"
                                                           detailText:nil
                                                            image:nil
                                                           target:self
                                                           action:@selector(openScheduler:)];
                }
                [section insertCell:cell atIndex:3];
                [self reloadData];
            }
        });
    }
}

- (void)openScheduler:(id)sender {
    TaskListViewController *vc = [[TaskListViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.viewController presentViewController:nav animated:YES completion:nil];
}

%end

%hook CMessageMgr

- (void)onSendMomentComplete:(id)moment error:(int)error {
    %orig;
    if (error == 0) {
        [[Scheduler sharedScheduler] markTaskAsCompleted];
    } else {
        [[Scheduler sharedScheduler] markTaskAsFailedWithError:error];
    }
}

%end

%ctor {
    [[Scheduler sharedScheduler] start];
}
