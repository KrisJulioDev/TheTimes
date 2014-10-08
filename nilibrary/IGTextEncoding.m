//
//  IGTextEncoding.m
//  IGFrameworkProject
//
//  Created by Ondrej Rafaj on 1.4.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "IGTextEncoding.h"


@implementation IGTextEncoding


+ (NSString *)decodeBase64:(NSString *)input {
	//NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-";
	NSString *decoded = @"";
	/*NSString *encoded = [input stringByPaddingToLength:(ceil([input length] / 4) * 4) withString:@"A" startingAtIndex:0];
	int i;
	char a, b, c, d;
	UInt32 z;
	for(i = 0; i < [encoded length]; i += 4) {
		a = [alphabet rangeOfString:[encoded substringWithRange:NSMakeRange(i + 0, 1)]].location;
		b = [alphabet rangeOfString:[encoded substringWithRange:NSMakeRange(i + 1, 1)]].location;
		c = [alphabet rangeOfString:[encoded substringWithRange:NSMakeRange(i + 2, 1)]].location;
		d = [alphabet rangeOfString:[encoded substringWithRange:NSMakeRange(i + 3, 1)]].location;
		z = ((UInt32)a << 26) + ((UInt32)b << 20) + ((UInt32)c << 14) + ((UInt32)d << 8);
		//decoded = [decoded stringByAppendingString:[NSString stringWithCString:(char *)&z]];
		long base64Length = BIO_get_mem_data(mem, &base64Pointer);
		decoded = [[[NSString alloc] initWithBytes:base64Pointer length:base64Length encoding:NSASCIIStringEncoding] autorelease];
	}*/
	return decoded;
}

/*- (NSString *)base64Encoding {
	NSTask *task = [[[NSTask alloc] init] autorelease];
	NSPipe *inPipe = [NSPipe pipe], *outPipe = [NSPipe pipe];
	NSFileHandle *inHandle = [inPipe fileHandleForWriting], *outHandle = [outPipe fileHandleForReading];
	NSData *outData = nil;
	[task setLaunchPath:@"/usr/bin/openssl"];
	[task setArguments:[NSArray arrayWithObjects:@"base64", @"-e", nil]];
	[task setStandardInput:inPipe];
	[task setStandardOutput:outPipe];
	[task setStandardError:outPipe];
	[task launch];
	[inHandle writeData:self];
	[inHandle closeFile];
	[task waitUntilExit];
	outData = [outHandle readDataToEndOfFile];
	if (outData) {
		NSString *base64 = [[[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding] autorelease];
		if (base64)
			return base64;
	}
	return nil;
}*/

@end
