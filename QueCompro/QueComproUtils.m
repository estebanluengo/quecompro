//
//  QueComproUtils.m
//  QueCompro
//
//  Created by Esteban Luengo on 03/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "QueComproUtils.h"

#define PHOTOS_CACHE_DIRECTORY @"_queComproPhotos"

@implementation QueComproUtils

+(BOOL)savePhoto:(UIImage *)photo withName:(NSString *)photoName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //el directorio donde almacenamos nuestras fotos. Estará dentro de Documents
    NSString *photosCacheDirectory = [documentsDirectory stringByAppendingPathComponent:PHOTOS_CACHE_DIRECTORY];
    //Se creó alguna vez?
    if (![fileManager fileExistsAtPath:photosCacheDirectory]){
        if ([fileManager createDirectoryAtPath:photosCacheDirectory withIntermediateDirectories:YES attributes:nil error:nil])
            NSLog(@"Se crea el directorio para guardar las imagenes en cache");
        else
            NSLog(@"No se puede crear el directorio para guardar las imagenes en cache");
    }
    NSData *dataImage = UIImageJPEGRepresentation(photo, 1.0);
    NSString *savePath = [photosCacheDirectory stringByAppendingPathComponent:photoName];  //path donde se guardará el fichero
    if ([fileManager createFileAtPath:savePath contents:dataImage attributes:nil]){
        NSLog(@"Se guarda la imagen en el directorio:%@",savePath);
        return YES;
    }else{
        NSLog(@"No se pudo guardar la imagen en cache:%@",savePath);
        return NO;
    }
}

+(UIImage *)loadPhoto:(NSString *)photoName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //el directorio donde almacenamos nuestras fotos. Estará dentro de Documents
    NSString *photosCacheDirectory = [documentsDirectory stringByAppendingPathComponent:PHOTOS_CACHE_DIRECTORY];
    NSData *data = [NSData dataWithContentsOfFile:[photosCacheDirectory stringByAppendingPathComponent:photoName]];
    return [UIImage imageWithData:data];
}

+(NSDate *)getDate:(NSString *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    return [dateFormatter dateFromString:date];
}

+(NSString *)getStringDate:(NSDate *)date
{
    return [QueComproUtils getStringFormatDate:date withFormat:@"dd/MM/yyyy HH:mm"];
}

+(NSString *)getStringShortDate:(NSDate *)date
{
    return [QueComproUtils getStringFormatDate:date withFormat:@"dd/MM/yyyy"];
}

+(NSString *)getStringFormatDate:(NSDate *)date withFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *stringDate = [dateFormatter stringFromDate:date];
    return stringDate;
}

+(NSString *)stringValue:(NSDecimalNumber *)number withDecimals:(int)n
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setMaximumFractionDigits:2];
    [nf setMinimumFractionDigits:2];
    [nf setMinimumSignificantDigits:1];
    if ([number isEqualToNumber:[NSDecimalNumber notANumber]]){
        number = [NSDecimalNumber zero];
    }
    return [nf stringFromNumber:number];
}

+(NSNumber *)numberValue:(NSString*)number
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    return [nf numberFromString:number];
}

+(NSDate *)getFirstDateOfMonth:(NSDate *)date
{
    NSDate *from = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:from];
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setDay:1];
    return [calendar dateFromComponents:dateComponents];
}

+(NSDate *)getLastDateOfMonth:(NSDate *)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:date]; // Get necessary date components
    [comps setMonth:[comps month]+1];
    [comps setDay:0];
    NSDate *tDateMonth = [calendar dateFromComponents:comps];
    return tDateMonth;
}

+(NSDate *)getMonthBefore:(NSInteger)n fromDate:(NSDate *)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:date]; // Get necessary date components
    [comps setMonth:[comps month]-n];
    [comps setDay:+1];
    NSDate *tDateMonth = [calendar dateFromComponents:comps];
    return tDateMonth;
}

+(NSDate *)getNextMonth:(NSDate *)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:date];
    [comps setMonth:[comps month]+1];
    [comps setDay:+1];
    NSDate *tDateMonth = [calendar dateFromComponents:comps];
    return tDateMonth;
}

+(NSNumber *)getDay:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSInteger day = [dateComponents day];
    return [NSNumber numberWithInteger:day];
}

+(NSNumber *)getMonth:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSInteger month = [dateComponents month];
    return [NSNumber numberWithInteger:month];
}

+(NSInteger)getDaysOfMonth:(NSDate *)date
{
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange range = [c rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    return range.length;
}

+(void)zoomToFitMapAnnotations:(MKMapView *)mapView
{
    if ([mapView.annotations count] == 0) return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id<MKAnnotation> annotation in mapView.annotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1;
    
    // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1;
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

+(UIActivityIndicatorView *)startSpinner:(UIView *)view {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    [spinner setColor:[UIColor grayColor]];
    spinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    spinner.center = CGPointMake(view.bounds.size.width / 2.0, view.bounds.size.height / 2.0);
    [view addSubview:spinner];
    [spinner startAnimating];
    return spinner;
}


@end
