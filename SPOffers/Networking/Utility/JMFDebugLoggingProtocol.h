//
//  JMFDebugLoggingProtocol.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#if defined (INTERNAL_BUILD) || defined (DEBUG) || defined (PRODUCTION_BUILD_LOGGING)
#import "JMFModuleManager.h" // Must include the module manager so that the macros work
#endif

#define InternalLog NSLog
//#pragma GCC poison NSLog // 120816-1024-SAG - NSLog is used in lots of places and this is causing issues for some folks.

BOOL gJMFDebugLoggingOn;

@protocol JMFDebugLoggingProtocol <NSObject>
- (void) enableLogging:(BOOL) inEnable; // This should NOT be called within any module; it should be called at the app level. This flag will enable logging for EVERYTHING and if one module sets it, it is enabled for all modules and potentially sensitive information could leak out.
- (BOOL) isLoggingEnabled;
#if defined (INTERNAL_BUILD) || defined (DEBUG) || defined (PRODUCTION_BUILD_LOGGING)
- (void) logMessage: (const char *)path line:(uint32_t)line
           function:(const char *)function
             format:(NSString *)format, ... __attribute__((format(__NSString__, 4, 5)));
#endif
@end


#if defined (INTERNAL_BUILD) || defined (DEBUG) || defined (PRODUCTION_BUILD_LOGGING)

#define JDebugLog(_format, ...) if (gJMFDebugLoggingOn && [JMFModuleManager sharedManagerInitialized]) [(JMFModule<JMFDebugLoggingProtocol>*)[[JMFModuleManager sharedManager] moduleConformingToProtocol:@protocol(JMFDebugLoggingProtocol)] logMessage:__FILE__ line:__LINE__ function:__PRETTY_FUNCTION__ format:_format, ## __VA_ARGS__]
#define EnableLogging()    if ([JMFModuleManager sharedManagerInitialized]) [(JMFModule<JMFDebugLoggingProtocol>*)[[JMFModuleManager sharedManager] moduleConformingToProtocol:@protocol(JMFDebugLoggingProtocol)] enableLogging:YES]
#define DisableLogging()    if ([JMFModuleManager sharedManagerInitialized]) [(JMFModule<JMFDebugLoggingProtocol>*)[[JMFModuleManager sharedManager] moduleConformingToProtocol:@protocol(JMFDebugLoggingProtocol)] enableLogging:NO]

#else

#define JDebugLog(s, ...)
#define EnableLogging()
#define DisableLogging()

#endif
