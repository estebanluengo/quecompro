//
//  Shopping+CRUD.h
//  QueCompro
//
//  Created by Esteban Luengo on 14/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "Shopping.h"
#import "Category+CRUD.h"
#import "Article+CRUD.h"

#define SHOPPING_COMMENTS @"comments"
#define SHOPPING_COST @"cost"
#define SHOPPING_DATE @"date"
#define SHOPPING_DATE_FROM @"dateFrom"
#define SHOPPING_DATE_UNTIL @"dateUntil"
#define SHOPPING_FAVOURITE @"favourite"
#define SHOPPING_FAVOURITE_PHOTO @"favourite_photo"
#define SHOPPING_UNIQUE @"unique"
#define SHOPPING_LATITUDE @"latitude"
#define SHOPPING_LONGITUDE @"longitude"
#define SHOPPING_PHOTO @"photo"
#define SHOPPING_TICKET @"ticket"
#define SHOPPING_CATEGORY_NAME @"category_name"
#define SHOPPING_ARTICLE_NAME @"article_name"

@interface Shopping (CRUD)

+(Shopping *)createShopping:(NSDictionary *)shopping
     inManagedObjectContext:(NSManagedObjectContext *)context;

+(Shopping *)updateShopping:(NSDictionary *)shopping
     inManagedObjectContext:(NSManagedObjectContext *)context;

+(void)deleteShopping:(NSNumber *)idShopping inManagedObjectContext:(NSManagedObjectContext *)context;

+(NSArray *)getShoppingListInManagedObjectContext:(NSManagedObjectContext *)context
                                      orderByDate:(BOOL)orderByDate;

+(NSArray *)getShoppingListWithFilter:(NSDictionary *)searchShopping
               InManagedObjectContext:(NSManagedObjectContext *)context
                          orderByDate:(BOOL)orderByDate;

@end
