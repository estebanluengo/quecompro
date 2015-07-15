//
//  Category+CRUD.h
//  QueCompro
//
//  Created by Esteban Luengo on 14/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "Category.h"

@interface Category (CRUD)
+(Category *)createCategory:(NSString *)categoryName inManagedObjectContext:(NSManagedObjectContext *)context;

+(NSArray *)getCategoriesContaining:(NSString *)name
             inManagedObjectContext:(NSManagedObjectContext *)context;
@end
