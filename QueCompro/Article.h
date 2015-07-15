//
//  Article.h
//  QueCompro
//
//  Created by Esteban Luengo on 07/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, Shopping;

@interface Article : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) NSSet *shoppingList;
@end

@interface Article (CoreDataGeneratedAccessors)

- (void)addShoppingListObject:(Shopping *)value;
- (void)removeShoppingListObject:(Shopping *)value;
- (void)addShoppingList:(NSSet *)values;
- (void)removeShoppingList:(NSSet *)values;

@end
