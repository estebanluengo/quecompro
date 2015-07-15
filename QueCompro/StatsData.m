//
//  StatsData.m
//  QueCompro
//
//  Created by Esteban Luengo on 11/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "StatsData.h"
#import "Shopping.h"
#import "Category.h"
#import "Article.h"
#import "QueComproUtils.h"


@interface StatsData () 
@property (nonatomic, strong) NSMutableArray *categoriesNames;
@property (nonatomic, strong) NSMutableArray *categoriesCost;
@property (nonatomic, strong) NSMutableDictionary *categoriesCostByTime;
@property (nonatomic) CGFloat maxCost;
@end

@implementation StatsData
@synthesize costTotal = _costTotal;
@synthesize categoriesNames = _categoriesNames;
@synthesize categoriesCost = _categoriesCost;
@synthesize titleGraph = _titleGraph;
@synthesize titleXAxis = _titleXAxis;
@synthesize titleYAxis = _titleYAxis;
@synthesize records = _records;

-(void)makeCategoryStatsData:(NSArray *)listShopping
{
    NSMutableDictionary *categories = [NSMutableDictionary dictionary];
    //Este for recorre todas las compras y construye un diccionario donde la clave es la categoria y el valor es la suma de todos los importes encontrados para esa categoria
    for (Shopping *s in listShopping){
        NSDecimalNumber *costCategory = [categories objectForKey:s.article.category.name];
        NSLog(@"category:%@",s.article.category.name);
        NSLog(@"cost:%@",s.cost);
        if (!costCategory){
            costCategory = [NSDecimalNumber zero];
        }
        costCategory = [costCategory decimalNumberByAdding:s.cost];
        NSLog(@"cost acumulado:%@",costCategory);
        [categories setObject:costCategory forKey:s.article.category.name];
    }
    //Al terminar el for en categoriesNames guardamos un array con los nombres de todas las categorias
    self.categoriesNames = [[categories allKeys] copy];
    //En categoriesCost guardamos un array con todos los importes totales de cada categoria
    self.categoriesCost = [[NSMutableArray alloc] initWithCapacity:[self.categoriesNames count]];
    self.costTotal = [NSDecimalNumber zero];
    for (NSDecimalNumber *n in self.categoriesNames){
        [self.categoriesCost addObject:[categories objectForKey:n]];
        //calculamos los gastos totales
        self.costTotal = [self.costTotal decimalNumberByAdding:n];
    }
}

-(void)makeCategoryStatsData:(NSArray *)listShopping dayPeriod:(BOOL)day
{
    self.maxCost = 0;
    self.categoriesCostByTime = [NSMutableDictionary dictionary];
    for (Shopping *s in listShopping){
        NSMutableDictionary *costCategoryByDate = [self.categoriesCostByTime objectForKey:s.article.category.name];
        NSDecimalNumber *cost;
        NSLog(@"category:%@",s.article.category.name);
        if (!costCategoryByDate){
            costCategoryByDate = [NSMutableDictionary dictionary];
            [self.categoriesCostByTime setObject:costCategoryByDate forKey:s.article.category.name];
        }
        NSNumber *date;
        if (day){
            date = [QueComproUtils getDay:s.date];
        }else{
            date = [QueComproUtils getMonth:s.date];
        }
        NSDecimalNumber *costDate = [costCategoryByDate objectForKey:date];
        if (costDate)
            cost = [s.cost decimalNumberByAdding:costDate];
        else
            cost = s.cost;
        
        if ([s.cost floatValue] > self.maxCost)
            self.maxCost = [s.cost floatValue];
        
        NSLog(@"cost acumulado:%@ para fecha:%@",cost,date);
        [costCategoryByDate setObject:cost forKey:date];
    }
}

-(CGFloat)getMaxCost
{
    return self.maxCost;
}

-(NSArray *)getCategoriesNames
{
    return self.categoriesNames;
}

-(NSArray *)getCategoriesCost
{
    return self.categoriesCost;
}

-(NSDictionary *)getCategorieCostByTime
{
    return self.categoriesCostByTime;
}

@end
