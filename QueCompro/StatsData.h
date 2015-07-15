//
//  StatsData.h
//  QueCompro
//
//  Created by Esteban Luengo on 11/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatsData : NSObject

@property (nonatomic, strong) NSDecimalNumber *costTotal;  //representa el gasto total de todas las compras representadas en esta informacion estadistica
@property (nonatomic, strong) NSString *titleGraph;
@property (nonatomic, strong) NSString *titleXAxis;
@property (nonatomic, strong) NSString *titleYAxis;
@property (nonatomic, strong) NSArray *records;

-(void)makeCategoryStatsData:(NSArray *)listShopping;
-(NSArray *)getCategoriesNames;
-(NSArray *)getCategoriesCost;

-(void)makeCategoryStatsData:(NSArray *)listShopping dayPeriod:(BOOL)day;
-(NSDictionary *)getCategorieCostByTime;
-(CGFloat)getMaxCost;


@end
