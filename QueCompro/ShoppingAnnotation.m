//
//  ShoppingAnnotation.m
//  QueCompro
//
//  Created by Esteban Luengo on 05/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "ShoppingAnnotation.h"
#import "Article.h"
#import "QueComproUtils.h"

@implementation ShoppingAnnotation

@synthesize shopping = _shopping;

+ (ShoppingAnnotation *)annotationForShopping:(Shopping *)shopping
{
    ShoppingAnnotation *annotation = [[ShoppingAnnotation alloc] init];
    annotation.shopping = shopping;
    return annotation;
}

#pragma mark - MKAnnotation

- (NSString *)title
{
    return self.shopping.article.name;
}

- (NSString *)subtitle
{
    return [QueComproUtils stringValue:self.shopping.cost withDecimals:2];
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.shopping.latitude doubleValue];
    coordinate.longitude = [self.shopping.longitude doubleValue];
    return coordinate;
}

@end
