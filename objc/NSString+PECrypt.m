//
//  NSString+PECrypt.m
//  CocoaFob
//
//  Created by Gleb Dolgich on 09/02/2009.
//  Follow me on Twitter @gbd
//  Copyright (C) 2009 PixelEspresso. All rights reserved.
//  Licensed under CC Attribution License 3.0 <http://creativecommons.org/licenses/by/3.0/>
//

#import "NSString+PECrypt.h"
#import "sha.h"
#import "bio.h"
#import "evp.h"

@implementation NSString (PXCrypt)

- (NSData *)sha1 {
	const int DIGEST_LEN = 20;
	unsigned char *buf = malloc(DIGEST_LEN);
	const char *str = [self UTF8String];
	size_t len = strlen(str);
	unsigned char *p = SHA1((unsigned char *)str, len, buf);
	if (!p) {
		free(buf);
		return nil;
	}
	NSData *digest = [NSData dataWithBytes:buf length:DIGEST_LEN];
	free(buf);
	return digest;
}

// Based on Dave Dribin's code, http://www.dribin.org/dave/blog/archives/2006/03/12/base64_cocoa/
- (NSString *)base64DecodeWithBreaks:(BOOL)lineBreaks {
    // Create a memory buffer containing Base64-encoded string data.
	const char *utf8 = [self UTF8String];
	if (!utf8)
		return nil;
	// Create an OpenSSL BIO buffer using UTF8 representation of the string.
    BIO *mem = BIO_new_mem_buf((void *)utf8, strlen(utf8));
    // Push a Base64 filter so that reading from the buffer decodes it.
    BIO *b64 = BIO_new(BIO_f_base64());
    if (!lineBreaks)
        BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);
    mem = BIO_push(b64, mem);
    
    // Decode into an NSMutableData
    NSMutableData *data = [NSMutableData data];
	const int DECODE_BUF_SIZE = 512;
    char inbuf[DECODE_BUF_SIZE];
    int inlen;
    while ((inlen = BIO_read(mem, inbuf, sizeof(inbuf))) > 0)
        [data appendBytes: inbuf length: inlen];
	unsigned char zeroByte[1] = {0};
	[data appendBytes:zeroByte length:1]; // zero-terminate the string
    // Clean up.
    BIO_free_all(mem);
	// Use decoded data bytes to construct a new string.
	NSString *decoded = [NSString stringWithUTF8String:[data bytes]];
    return decoded;
}

- (NSString *)base64Decode {
	return [self base64DecodeWithBreaks:NO];
}


@end
