//
//  DebugLoggingModule.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "DebugLoggingModule.h"

@interface DebugLoggingModule ()
@property (nonatomic, assign) BOOL loggingEnabled;
@end


@implementation DebugLoggingModule
@synthesize loggingEnabled = _loggingEnabled;

+ (NSString*)defaultUTI
{
	// Module's default UTI (does not require customization if only one instance of the module will be installed)
	return @"com.minaz.debuglogging";
}


+ (NSDictionary*)defaultProperties
{
	return @{
			 @"ModuleClassName":@"DebugLoggingModule",
			 @"Name":@"DebugLoggingModule",
			 @"Version":@"2.0.1",
			 };
}

- (void) enableLogging:(BOOL) inEnable
{
	gJMFDebugLoggingOn = inEnable;
    self.loggingEnabled = inEnable;
}

- (BOOL) isLoggingEnabled
{
    return self.loggingEnabled;
}

- (void)logMessage:(const char *)path_c line:(uint32_t)line
                function:(const char *)function_c
                  format:(NSString *)format, ...
{
    if (self.loggingEnabled)
    {
        va_list args;
        va_start(args, format);
        
        NSString *path = [NSString stringWithCString:path_c encoding:NSASCIIStringEncoding];
        NSString *prefix = [NSString stringWithFormat:@"%@:%s:%d ", [path lastPathComponent],
                            function_c,
                            line];

        NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
        InternalLog(@"%@%@", prefix, msg);
        
        va_end(args);
    }
}

@end
