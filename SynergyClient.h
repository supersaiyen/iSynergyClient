/*
 * Copyright (C) 2009 by Matthias Ringwald
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holders nor the names of
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY MATTHIAS RINGWALD AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MATTHIAS
 * RINGWALD OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */

#import <Foundation/Foundation.h>

typedef enum {
	SOCKET_W4_HEADER,
	SOCKET_W4_DATA,
	SOCKET_W4_SKIP,
} SOCKET_STATE;

typedef enum {
	STATE_NOT_CONNECTED,
	STATE_CONNECTING,
	STATE_CONNECTED,
	STATE_LIVE,
	STATE_W4_RECONNECT
} CLIENT_STATE;

@protocol SynergyClientDelegate 
- (void) connectionStateChanged;
- (void) connectionFailed;
- (void) remoteDisconnected;
@end

#define MAX_MESSAGE 80

@class LAActivator;

@interface SynergyClient : NSObject {
	
	SOCKET_STATE socketState;
	int socketFD;
	uint16_t bytesToRead;
	uint16_t bytesToSkip;
	uint16_t readPos;
	uint8_t message[MAX_MESSAGE];

	CLIENT_STATE clientState;
	BOOL _enabled;
	Point screenSize;
	id delegate;
	
	int screenWidth;
	int screenHeight;
	BOOL mouseShown;

	NSString *connectionError;
	
	// LA
	LAActivator *activator;
}

-(void) startOpeningConnection;
-(void) stopConnection;

-(BOOL) openConnection:(NSString *) remote;
-(void) handleSocketCallback;
//saiyen
- (void) sendResetOptionsMessage;
//saiyen
-(void) handleMessageWithLen:(uint16_t)len;
-(NSString *) connectionStatus;
-(BOOL) isConnecting;
-(NSString *) hostName;
-(void) setEnabled:(BOOL)enabled;
-(BOOL) enabled;
-(BOOL) keyboardSupportInstalled;
-(void) setScreenWidth:(int)width andHeight:(int)height;
- (void) deactivateMouse;

-(void) setServerAddress:(NSString *) serverAddress;
-(NSString *) serverAddress;
-(void) setClientName:(NSString *) clientName;
-(NSString *) clientName;
-(BOOL) homeButtonHotkey;
-(void) setHomeButtonHotKey:(BOOL) homeButtonHotKey;
-(CLIENT_STATE) clientState;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSString *connectionError;

@end
