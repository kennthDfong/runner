//
//  WCSportViewController.m
//  WeiChat
//
//  Created by guoaj on 15/10/19.
//  Copyright © 2015年 Strom. All rights reserved.
//
#import "WCSportViewController.h"
#import "BMapKit.h"
#import "AFNetworking.h"
#import "KRUserInfo.h"
#import "KRSport.h"
#import "MBProgressHUD+KR.h"
typedef enum : NSUInteger {
    TrailStart=1,
    TrailEnd
} Trail;

@interface WCSportViewController () <BMKMapViewDelegate, BMKLocationServiceDelegate>
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (weak, nonatomic) IBOutlet UIView *panelView;
/* 隐藏的选择运动模式的试图  */
@property (weak, nonatomic) IBOutlet UIView *hiddenView;
/** 获得地图截图 */
@property (strong, nonatomic)  UIImageView *imageView;
/* 运动完成的视图 */
@property (weak, nonatomic) IBOutlet UIView *sportComlete;

@property (weak, nonatomic) IBOutlet UIButton *startSportBtn;
/* 暂停和继续的视图 */
@property (weak, nonatomic) IBOutlet UIView *pauseView;
/**  选择运动模式 */
- (IBAction)selectSport:(id)sender;

/** 百度定位地图服务 */
@property (nonatomic, strong) BMKLocationService *bmkLocationService;

/** 百度地图View */
@property (nonatomic,strong) BMKMapView *mapView;


/** 记录上一次的位置 */
@property (nonatomic, strong) CLLocation *preLocation;

/** 位置数组 */
@property (nonatomic, strong) NSMutableArray *locationArrayM;

/** 轨迹线 */
@property (nonatomic, strong) BMKPolyline *polyLine;

/** 轨迹记录状态 */
@property (nonatomic, assign) Trail trail;

/** 起点大头针 */
@property (nonatomic, strong) BMKPointAnnotation *startPoint;

/** 终点大头针 */
@property (nonatomic, strong) BMKPointAnnotation *endPoint;

/** 累计运动时间 */
@property (nonatomic,assign) NSTimeInterval sumTime;
/** 累计运动距离 */
@property (nonatomic,assign) CGFloat sumDistance;
/** 累计运动距离 */
@property (nonatomic,assign) CGFloat sumHeat;

@property (weak, nonatomic) IBOutlet UIView *choseSportView;


- (IBAction)sportContinue:(id)sender;
- (IBAction)sportComplete:(id)sender;

- (IBAction)choseSport:(UIButton *)sender;
@property  (nonatomic,assign) SportModel choseSportModel;

#define  BMKCSPAN   0.001f
@property (weak, nonatomic) IBOutlet UIButton *currentSportModel;
/* 默认选中的按钮 */
@property (weak, nonatomic) IBOutlet UIButton *chosedSport;

@end

@implementation WCSportViewController

#pragma mark - Lifecycle Method

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sumDistance = 0.0;
    self.sumHeat = 0.0;
    self.sumTime  = 0.0;
    self.chosedSport.selected = YES;
    self.choseSportModel = SportModelWalk;
    // 对暂停按钮增加手势识别器
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(pauseSport)];
    gesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.pauseBtn addGestureRecognizer:gesture];
    // 初始化百度位置服务
    [self initBMLocationService];
    // 初始化导航栏的一些属性
    //[self setupNavigationProperty];
    // 初始化地图窗口
    self.mapView = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    // 设置MapView的一些属性
    [self setMapViewProperty];
    
    // [self.view addSubview:self.mapView];
    [self.view insertSubview:self.mapView atIndex:0];
    /* 地图加载直接定位到用户位置 */
    // 1.清理上次遗留的轨迹路线以及状态的残留显示
     [self clean];
   
    // 2.打开定位服务
    [self.bmkLocationService startUserLocationService];
    self.trail = TrailEnd;
  
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
   
    [self.mapView viewWillAppear];
    self.mapView.delegate = self;
    self.bmkLocationService.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil;
    self.bmkLocationService.delegate = nil;
}

/**
 *  初始化百度位置服务
 */
- (void)initBMLocationService
{
    // 初始化位置百度位置服务
    self.bmkLocationService = [[BMKLocationService alloc] init];
    
    //设置更新位置频率(单位：米;必须要在开始定位之前设置)
    [BMKLocationService setLocationDistanceFilter:5];
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyBest];
}

/**
 *  设置 百度MapView的一些属性
 */
- (void)setMapViewProperty
{
    // 显示定位图层
    self.mapView.showsUserLocation = YES;
    // 设置定位模式
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    // 允许旋转地图
    self.mapView.rotateEnabled = YES;
    // 显示比例尺 和比例尺位置 
        self.mapView.showMapScaleBar = YES;
        self.mapView.mapScaleBarPosition = CGPointMake(self.view.frame.size.width - 50, self.view.frame.size.height - 50);
    // 定位图层自定义样式参数
    BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc]init];
    displayParam.isRotateAngleValid = NO;//跟随态旋转角度是否生效
    displayParam.isAccuracyCircleShow = NO;//精度圈是否显示
    displayParam.locationViewOffsetX = 0;//定位偏移量(经度)
    displayParam.locationViewOffsetY = 0;//定位偏移量（纬度）

   [self.mapView updateLocationViewWithParam:displayParam];
}
/*** 下拉暂停函数  */
#pragma mark - "IBAction" Method

- (void) pauseSport
{
    MYLog(@"pauseSport swip");
    [UIImageView animateWithDuration:0.1 animations:^{
        self.pauseBtn.hidden = YES;
        self.pauseView.hidden = NO;
        [self.bmkLocationService stopUserLocationService];
    }];
    
    
}
/** 运动继续 */
- (IBAction)sportContinue:(id)sender {
    [self.bmkLocationService startUserLocationService];
    self.pauseView.hidden = YES;
    self.pauseBtn.hidden = NO;
}
/** 运动完成 */
- (IBAction)sportComplete:(id)sender {
    [self stopTrack];
    [self  mapViewFitPolyLineNew:self.polyLine];
    // 隐藏暂停视图
    self.pauseView.hidden = YES;
    // 显示选择处理当前运动信息的方式
    self.sportComlete.hidden = NO;
    /* 计算本次运动的数据 */
    CLLocation  *firstLoc = self.locationArrayM.firstObject;
    CLLocation  *lastLoc = self.locationArrayM.lastObject;
    /* 运动时间  秒 */
    double st = ([lastLoc.timestamp timeIntervalSince1970] - [firstLoc.timestamp timeIntervalSince1970]);
    self.sumTime = st;
    self.sumHeat = (st/3600.0)*600.0;
}
/* 取消本次运动 */
- (IBAction)cancelSport:(UIButton *)sender {
    NSLog(@" cancel Sport");
    /* 回到初始状态 */
    [self clean];
    self.sportComlete.hidden = YES;
    self.startSportBtn.hidden = NO;
    BMKCoordinateRegion adjustRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(self.bmkLocationService.userLocation.location.coordinate, BMKCoordinateSpanMake(BMKCSPAN,BMKCSPAN))];
    [self.mapView setRegion:adjustRegion animated:NO];
    
}

/* 保存形成运动数据  */
- (IBAction)saveMapImageToPhoto:(UIButton *)sender {
    NSLog(@" save Sport to photo");
    /* 把数据存入web服务器  */
    [self saveSportDataToServer];
    /* 完成之后结束本次运动 */
    [self  cancelSport:nil];
}
/* 生成图片缩略图 */
- (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize

{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }else{
        UIGraphicsBeginImageContext(asize);
        [image drawInRect:CGRectMake(0, 0, asize.width, asize.height)];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}
/* 分享默认到朋友圈 如果是新浪分享本地和新浪都会分享 */
- (IBAction)shareToSportCircleAndSina:(UIButton *)sender {
     NSLog(@" share Sport ");
    /* 获得地图截图  */
    UIImage *image = [self.mapView takeSnapshot];
    double s = 200.0/image.size.width;
    MYLog(@"scale=%lf,image.size=%lf",s,image.size.height);
    UIImage *newimage = [self thumbnailWithImage:image size:CGSizeMake(200, s*image.size.height)];
    MYLog(@"after width=%lf,image.size=%lf",newimage.size.width,newimage.size.height);
    /* 直接发到朋友圈 */
    if (3 == sender.tag) {
        [self saveSportTopicToServer:newimage];
    }
    /* 先发朋友圈 再发新浪微博 */
    if (2 == sender.tag) {
        [self saveSportTopicToServer:newimage];
        [self saveSportTopicToSina:image];
    }
    /* 完成之后结束本次运动  保存本地运动数据*/
    [self saveSportDataToServer];
    [self  cancelSport:nil];
}
/* 发表微博到新浪 */
- (void) saveSportTopicToSina:(UIImage *) image
{
     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
     NSString *url =
     @"https://upload.api.weibo.com/2/statuses/upload.json";
     NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
     parameters[@"access_token"] =
       [KRUserInfo sharedKRUserInfo].sinaToken;
    
    NSString *statusStr = [NSString stringWithFormat:@"本次运动总距离:%.1lf米,运动时间为:%.1lf@秒,消耗热量%.4lf卡",self.sumDistance,
        self.sumTime,self.sumHeat];
     parameters[@"status"] = statusStr;
    
     if ([KRUserInfo sharedKRUserInfo].sinaLogin) {
         [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
             [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"pic" fileName:@"运动记录.png" mimeType:@"image/jpeg"];
         } success:^(AFHTTPRequestOperation *operation, id responseObject) {
             MYLog(@"发布微博成功");
             [MBProgressHUD showError:@"发布微博成功"];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MYLog(@"发布微博失败");
             [MBProgressHUD showError:@"发布微博失败"];
         }];
     }else{
         [MBProgressHUD showError:@"请使用新浪第三方方式登录"];
     }
}

/* 发表运动圈话题 */
- (void) saveSportTopicToServer:(UIImage *) image
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.responseSerializer.acceptableContentTypes = [NSSet
    //        setWithObject:@"text/html"];
//    NSString *url =
//    @"http://localhost:8080/allRunServer/addTopic.jsp";
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServerNew/addTopic.jsp",KRXMPPHOSTNAME];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    KRUserInfo *userInfo = [KRUserInfo sharedKRUserInfo];
    /* content:  address: latitude: longitude:*/
    parameters[@"username"] = userInfo.userName;
    parameters[@"md5password"] = userInfo.userPwd;
    if (self.sumDistance <= 0.0) {
        return;
    }
    NSString *statusStr = [NSString stringWithFormat:@"本次运动总距离:%.1lf米,运动时间为:%.1lf@秒,消耗热量%.4lf卡",self.sumDistance,self.sumTime,self.sumHeat];

    parameters[@"content"] = statusStr;
    parameters[@"address"] = @"北京潘家园";
    CLLocation  *lastLoc = self.locationArrayM.lastObject;
    parameters[@"latitude"] = @(lastLoc.coordinate.latitude);
    parameters[@"longitude"] = @(lastLoc.coordinate.longitude);
  
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        /* 按照日期生成文件名 */
        NSDate  *date = [NSDate date];
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"yyyyMMddHHmmss"];
        NSString *dateName = [format stringFromDate:date];
        NSString *picName = [dateName stringByAppendingFormat:@"%@.png",[KRUserInfo sharedKRUserInfo].userName];
        [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"pic" fileName:picName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MYLog(@"%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"%@",error);
    }];
}
/** 选择具体的运动方式  */
- (IBAction)choseSport:(UIButton *)sender {
    for (id button in self.choseSportView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            UIButton *b = button;
            switch (sender.tag) {
                case SportModelBike:
                    [self.currentSportModel setImage:[UIImage imageNamed:@"mbike"] forState:UIControlStateNormal];
                    break;
                case SportModelWalk:
                    [self.currentSportModel setImage:[UIImage imageNamed:@"mwalk"] forState:UIControlStateNormal];
                    break;
                case SportModelSkiing:
                    [self.currentSportModel setImage:[UIImage imageNamed:@"mskiing"] forState:UIControlStateNormal];
                    break;
                case SportModelFree:
                    [self.currentSportModel setImage:[UIImage imageNamed:@"mfree"] forState:UIControlStateNormal];
                    break;
            }
            if (b.tag == sender.tag) {
                b.selected = YES;
                UIButton *button = (UIButton*)sender;
                switch (button.tag) {
                    case SportModelBike:
                        self.choseSportModel = SportModelBike;
                        break;
                    case SportModelFree:
                        self.choseSportModel = SportModelFree;
                        break;
                    case SportModelSkiing:
                        self.choseSportModel = SportModelSkiing;
                        break;
                    case SportModelWalk:
                        self.choseSportModel = SportModelWalk;
                        break;
                    default:
                        break;
                }
            }else{
                b.selected = NO;
            }
        }
    }
}
/* 把运动数据存入web服务器  */
- (void) saveSportDataToServer
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet
//        setWithObject:@"text/html"];
//   NSString *url =
//       @"http://localhost:8080/allRunServer/addSportData.jsp";
    NSString *url =[NSString stringWithFormat:@"http://%@:8080/allRunServerNew/addSportData.jsp",KRXMPPHOSTNAME];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    KRUserInfo *userInfo = [KRUserInfo sharedKRUserInfo];
    parameters[@"username"] = userInfo.userName;
    parameters[@"md5password"] = userInfo.userPwd;
    parameters[@"sportType"] = @(self.choseSportModel);
   
    /* data:数据格式  运动时间|经度|纬度@运动时间|经度|纬度   @"211|39.666666|218.128128@222|240.666666|219.128128" */
    // NSTimeInterval timeSecs = [[NSDate date]timeIntervalSince1970];
    CLLocation  *firstLoc = self.locationArrayM.firstObject;
    CLLocation  *lastLoc = self.locationArrayM.lastObject;
    NSString  *dataStr = [NSString stringWithFormat:
        @"%lf|%lf|%lf@%lf|%lf|%lf",
        firstLoc.timestamp.timeIntervalSince1970,
        firstLoc.coordinate.latitude,firstLoc.coordinate.longitude,lastLoc.timestamp.timeIntervalSince1970,lastLoc.coordinate.latitude,lastLoc.coordinate.longitude];
    parameters[@"data"] = dataStr;
    /* 计算总共的距离 热量  总运动时间 
     爬楼梯1500级（不计时） 250卡
     快走（一小时8公里） 　　 555卡
     快跑(一小时12公里） 700卡
     单车(一小时9公里) 245卡
     单车(一小时16公里) 415卡
     单车(一小时21公里) 655卡
     舞池跳舞 300卡
     健身操 300卡
     骑马 350卡
     网球 425卡
     爬梯机 680卡
     手球 600卡
     桌球 300卡
     慢走(一小时4公里) 255卡
     慢跑(一小时9公里) 655卡
     游泳(一小时3公里) 550卡
     有氧运动(轻度) 275卡
     有氧运动(中度) 350卡
     高尔夫球(走路自背球杆) 270卡
     锯木 400卡 
     体能训练 300卡 
     走步机(一小时6公里) 345卡 
     轮式溜冰 350卡 
     跳绳 660卡 
     郊外滑雪(一小时8公里) 600卡 
     练武术 790 */
    parameters[@"sportDistance"] = @(self.sumDistance);
    /* 运动时间  秒 */
    double st = ([lastLoc.timestamp timeIntervalSince1970] - [firstLoc.timestamp timeIntervalSince1970]);
    
    parameters[@"sportHeat"] = @(self.sumHeat);
    parameters[@"sportTimeLen"] = @(st);
    parameters[@"sportStartTime"] = @([firstLoc.timestamp timeIntervalSince1970]);
    MYLog(@"%@",dataStr);
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MYLog(@"sport---%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"sport error---%@",error);
    }];
    
}




/* 开始运动 */
- (IBAction)startTrack
{
    NSLog(@"--------startTrack-----------");
    // 1.清理上次遗留的轨迹路线以及状态的残留显示
    // [self clean];
    
    // 2.打开定位服务
    [self.bmkLocationService startUserLocationService];
    
    self.pauseBtn.hidden = NO;
    self.startSportBtn.hidden = YES;
    // 3.设置当前地图的显示范围，直接显示到用户位置
    BMKCoordinateRegion adjustRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(self.bmkLocationService.userLocation.location.coordinate, BMKCoordinateSpanMake(BMKCSPAN,BMKCSPAN))];
    [self.mapView setRegion:adjustRegion animated:NO];
    
    // 4.设置轨迹记录状态为：开始
    self.trail = TrailStart;
}

/**
 *  停止百度地图定位服务
 */
- (void)stopTrack
{
    // 1.设置轨迹记录状态为：结束
    self.trail = TrailEnd;
    // 2.关闭定位服务
    [self.bmkLocationService stopUserLocationService];
    // 3.添加终点旗帜
    if (self.startPoint) {
        self.endPoint = [self creatPointWithLocaiton:self.preLocation title:@"终点"];
        
    }
}

#pragma mark - BMKLocationServiceDelegate
/**
 *  定位失败会调用该方法
 *
 *  @param error 错误信息
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"did failed locate,error is %@",[error localizedDescription]);
//    UIAlertView *gpsWeaknessWarning = [[UIAlertView alloc]initWithTitle:@"Positioning Failed" message:@"Please allow to use your Location via Setting->Privacy->Location" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
   // [gpsWeaknessWarning show];
}

/**
 *  用户位置更新后，会调用此函数
 *  @param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    if (TrailEnd == self.trail) {
        BMKCoordinateRegion adjustRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(self.bmkLocationService.userLocation.location.coordinate, BMKCoordinateSpanMake(BMKCSPAN,BMKCSPAN))];
        [self.mapView setRegion:adjustRegion animated:YES];
    }
    // 1. 动态更新我的位置数据
    [self.mapView updateLocationData:userLocation];
    // 2. 如果精准度不在10米范围内
    if (userLocation.location.horizontalAccuracy > kCLLocationAccuracyNearestTenMeters) {
        return;
    }//else if (TrailStart == self.trail) { // 开始记录轨迹
    if (TrailStart == self.trail) {
        [self startTrailRouteWithUserLocation:userLocation];
        [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:NO];
    }
   
    //}
}

/**
 *  用户方向更新后，会调用此函数
 *  @param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    // 动态更新我的位置数据
    [self.mapView updateLocationData:userLocation];
    
}


#pragma mark - Selector for didUpdateBMKUserLocation:
/**
 *  开始记录轨迹
 *
 *  @param userLocation 实时更新的位置信息
 */
- (void)startTrailRouteWithUserLocation:(BMKUserLocation *)userLocation
{
    if (self.trail != TrailStart) {
        return;
    }
    if (self.preLocation) {
        // 计算本次定位数据与上次定位数据之间的时间差
        NSTimeInterval dtime = [userLocation.location.timestamp timeIntervalSinceDate:self.preLocation.timestamp];
        
        // 计算本次定位数据与上次定位数据之间的距离
        CGFloat distance = [userLocation.location distanceFromLocation:self.preLocation];
        // NSLog(@"与上一位置点的距离为:%f",distance);
        
        // (5米门限值，存储数组划线) 如果距离少于 5 米，则忽略本次数据直接返回该方法
        if (distance < 5) {
           //  NSLog(@"与前一更新点距离小于5m，直接返回该方法");
            return;
        }
        
        // 累加步行距离
        self.sumDistance += distance;
        
        // NSLog(@"步行总距离为:%f",self.sumDistance);
    }
    
    // 2. 将符合的位置点存储到数组中
    [self.locationArrayM addObject:userLocation.location];
    self.preLocation = userLocation.location;
    
    // 3. 绘图
    [self drawWalkPolyline];
   
    
}

/**
 *  绘制步行轨迹路线
 */
- (void)drawWalkPolyline
{
    //轨迹点个数
    NSUInteger count = self.locationArrayM.count;
    
    // 手动分配存储空间，结构体：地理坐标点，用直角地理坐标表示 X：横坐标 Y：纵坐标
    BMKMapPoint *tempPoints = new BMKMapPoint[count];
    
    [self.locationArrayM enumerateObjectsUsingBlock:^(CLLocation *location, NSUInteger idx, BOOL *stop) {
        BMKMapPoint locationPoint = BMKMapPointForCoordinate(location.coordinate);
        tempPoints[idx] = locationPoint;
        //NSLog(@"idx = %ld,tempPoints X = %f Y = %f",idx,tempPoints[idx].x,tempPoints[idx].y);
        
        // 放置起点旗帜
        if (0 == idx && TrailStart == self.trail && self.startPoint == nil) {
            self.startPoint = [self creatPointWithLocaiton:location title:@"起点"];
        }
    }];
    
    //移除原有的绘图
    if (self.polyLine) {
        [self.mapView removeOverlay:self.polyLine];
    }
    
    // 通过points构建BMKPolyline
    self.polyLine = [BMKPolyline polylineWithPoints:tempPoints count:count];
    
    //添加路线,绘图
    if (self.polyLine) {
        [self.mapView addOverlay:self.polyLine];
    }
    
    // 清空 tempPoints 内存
    delete []tempPoints;

}

/**
 *  添加一个大头针
 *
 *  @param location
 */
- (BMKPointAnnotation *)creatPointWithLocaiton:(CLLocation *)location title:(NSString *)title;
{
    BMKPointAnnotation *point = [[BMKPointAnnotation alloc] init];
    point.coordinate = location.coordinate;
    point.title = title;
    [self.mapView addAnnotation:point];
    
    return point;
}

/**
 *  清空数组以及地图上的轨迹
 */
- (void)clean
{
    // 清空状态信息
    self.sumDistance = 0.0;
    self.sumHeat = 0.0;
    self.sumTime  = 0.0;
    //清空数组
    [self.locationArrayM removeAllObjects];
    
    //清屏，移除标注点
    if (self.startPoint) {
        [self.mapView removeAnnotation:self.startPoint];
        self.startPoint = nil;
    }
    if (self.endPoint) {
        [self.mapView removeAnnotation:self.endPoint];
        self.endPoint = nil;
    }
    if (self.polyLine) {
        [self.mapView removeOverlay:self.polyLine];
        self.polyLine = nil;
    }
}

/**
 *  运动完成后 根据polyline设置地图范围
 *  根据点求出最大的x和最小的x  以及最大的y和最小的y 从而计算出范围
 *  @param polyLine
 */
- (void)mapViewFitPolyLineNew:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX-40 , ltY-60);
    rect.size = BMKMapSizeMake((rbX - ltX)+80, (rbY - ltY)+120);
    [self.mapView setVisibleMapRect:rect];
    
}




#pragma mark - BMKMapViewDelegate

/**
 *  根据overlay生成对应的View
 *  @param mapView 地图View
 *  @param overlay 指定的overlay
 *  @return 生成的覆盖物View
 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor clearColor] colorWithAlphaComponent:0.7];
        polylineView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.7];
        // 设置线宽
        polylineView.lineWidth = 5.0;
        return polylineView;
    }
    return nil;
}


/**
 *  只有在添加大头针的时候会调用，直接在viewDidload中不会调用
 *  根据anntation生成对应的View
 *  @param mapView 地图View
 *  @param annotation 指定的标注
 *  @return 生成的标注View */
 
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *annotationView = [[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        if(self.startPoint){
        // 有起点旗帜代表应该放置终点旗帜（程序一个循环只放两张旗帜：起点与终点）
            //annotationView.pinColor = BMKPinAnnotationColorGreen;
            annotationView.image = [UIImage imageNamed:@"end"];
            // self.statusView.stopPointLabel.text = @"YES";
        }else { // 没有起点旗帜，应放置起点旗帜
            //annotationView.pinColor = BMKPinAnnotationColorPurple;
            annotationView.image = [UIImage imageNamed:@"start"];
            // self.statusView.startPointLabel.text = @"YES";
        }
        
        // 从天上掉下效果
        annotationView.animatesDrop = YES;
        
        // 不可拖拽
        annotationView.draggable = YES;
        
        return annotationView;
    }
    return nil;
}


#pragma mark - lazyLoad

- (NSMutableArray *)locationArrayM
{
    if (_locationArrayM == nil) {
        _locationArrayM = [NSMutableArray array];
    }
    
    return _locationArrayM;
}
//截图
-(void)snapshot
{
    _hiddenView.hidden = false;
    [self.view bringSubviewToFront:_hiddenView];
    //获得地图当前可视区域截图
    self.imageView.image = [_mapView takeSnapshot];
    
    self.navigationItem.rightBarButtonItem.enabled = false;
    
}


/** 选择运动模式 */
- (IBAction)selectSport:(id)sender {
 
    [self.view bringSubviewToFront:self.hiddenView];
    if (self.hiddenView.hidden) {
        self.hiddenView.hidden = NO;
    }else{
        self.hiddenView.hidden = YES;
    }
}


@end
