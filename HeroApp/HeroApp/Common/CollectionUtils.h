#import <Foundation/Foundation.h>

struct _dictpair {__unsafe_unretained id key; __unsafe_unretained id value; };
NSDictionary* _dictof(const struct _dictpair*, size_t count);
NSMutableDictionary* _mdictof(const struct _dictpair*, size_t count);
NSValue* _box(const void *value, const char *encoding);

@interface NSArray (HigherOrderFunctions)

- (id)findWithPredicateBlock:(BOOL(^)(id element))predicateBlock;
- (NSArray *)grepWithPredicateBlock:(BOOL(^)(id element))predicateBlock;
- (NSArray *)mapWithBlock:(id(^)(id element))block;
- (void)foreachWithBlock:(void(^)(id element))block;

@end


@interface NSArray (Reverse)

- (NSArray *)reversedArray;

@end

@interface NSMutableArray (Reverse)

- (void)reverse;

@end

@interface NSMutableArray (Queue)

- (id)shift;
- (id)pop;
- (void)push:(id)obj;
-(NSMutableArray *)getValueFromDicUsingKey:(NSString *)key;

@end

@interface NSMutableDictionary (Misc)

- (id)removeAndReturnObjectForKey:(id)key;

@end

@interface NSDictionary (TransientProperties)

- (id)transientValueForKey:(NSString *)key;

@end


@interface NSMutableDictionary (TransientProperties)

- (void)setTransientValue:(id)value forKey:(NSString *)key;
- (void)resetTransientValues;

@end