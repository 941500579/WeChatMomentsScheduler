#import "TaskListViewController.h"
#import "Scheduler.h"
#import "Task.h"

@implementation TaskListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"定时发朋友圈";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTask:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
}

- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)addTask:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加定时任务" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"朋友圈内容";
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"发送时间 (yyyy-MM-dd HH:mm)";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
        textField.text = [formatter stringFromDate:[NSDate date]];
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"重复次数 (0=无限)";
        textField.text = @"1";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"重复间隔 (小时)";
        textField.text = @"24";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *content = alert.textFields[0].text;
        NSString *time = alert.textFields[1].text;
        NSInteger repeatCount = [alert.textFields[2].text integerValue];
        NSInteger repeatInterval = [alert.textFields[3].text integerValue];
        
        if (content.length == 0) {
            UIAlertController *error = [UIAlertController alertControllerWithTitle:@"错误" message:@"请输入朋友圈内容" preferredStyle:UIAlertControllerStyleAlert];
            [error addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:error animated:YES completion:nil];
            return;
        }
        
        Task *task = [[Task alloc] initWithContent:content
                                        imagePaths:nil
                                         videoPath:nil
                                           linkUrl:nil
                                         linkTitle:nil
                                       nextRunTime:time
                                       repeatCount:repeatCount
                                    repeatInterval:repeatInterval];
        
        [[Scheduler sharedScheduler] addTask:task];
        [self.tableView reloadData];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [Scheduler sharedScheduler].tasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Task *task = [Scheduler sharedScheduler].tasks[indexPath.row];
    
    cell.textLabel.text = task.content;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ | 已执行%ld/%ld次 | %@", 
                                 task.nextRunTime, 
                                 (long)task.executedCount, 
                                 task.repeatCount == 0 ? (long)999999 : (long)task.repeatCount,
                                 task.lastResult];
    
    cell.detailTextLabel.textColor = [task.lastResult isEqualToString:@"成功"] ? [UIColor systemGreenColor] : [UIColor systemRedColor];
    cell.accessoryType = task.enabled ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Task *task = [Scheduler sharedScheduler].tasks[indexPath.row];
        [[Scheduler sharedScheduler] deleteTask:task];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Task *task = [Scheduler sharedScheduler].tasks[indexPath.row];
    task.enabled = !task.enabled;
    [[Scheduler sharedScheduler] saveTasks];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
