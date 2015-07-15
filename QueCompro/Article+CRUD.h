//
//  Article+CRUD.h
//  QueCompro
//
//  Created by Esteban Luengo on 14/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "Article.h"
#import "Category.h"

@interface Article (CRUD)

+(Article *)createArticle:(NSString *)articleName onCategory:(Category *)category inManagedObjectContext:(NSManagedObjectContext *)context;

+(NSArray *)getArticlesContaining:(NSString *)name
           inManagedObjectContext:(NSManagedObjectContext *)context;

@end
