//
//  DatabaseHelper.h
//  QueCompro
//
//  Created by Esteban Luengo on 28/08/12.
//  Copyright (c) 2012 Esteban Luengo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^completion_block_t)(UIManagedDocument *database);

@interface DatabaseHelper: NSObject

+ (void)openDatabaseUsingBlock:(completion_block_t)completionBlock;

@end
