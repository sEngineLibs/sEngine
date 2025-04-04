package se.net.ws;

import haxe.io.Bytes;
#if js
@:forward()
@:forward.new
extern abstract WebSocket(js.html.WebSocket) {
	public var onopen(get, set):() -> Void;

	public var onerror(get, set):() -> Void;

	public var onmessage(get, set):(message:Message) -> Void;

	public var onclose(get, set):() -> Void;

	inline function get_onopen() {
		return cast this.onopen;
	}

	inline function set_onopen(value:() -> Void) {
		this.onopen = value;
		return onopen;
	}

	inline function get_onerror() {
		return cast this.onerror;
	}

	inline function set_onerror(value:() -> Void) {
		this.onerror = value;
		return onerror;
	}

	inline function get_onmessage() {
		return cast this.onmessage;
	}

	inline function set_onmessage(value:(message:Message) -> Void) {
		this.onmessage = value;
		return onmessage;
	}

	inline function get_onclose() {
		return cast this.onclose;
	}

	inline function set_onclose(value:() -> Void) {
		this.onclose = value;
		return onclose;
	}
}
#elseif sys
import sys.net.Host;
import sys.thread.Thread;
import haxe.crypto.Sha1;
import haxe.crypto.Base64;
import haxe.Constraints.Function;
import se.net.HTTP;
import se.net.ws.Buffer;
import se.net.ws.Socket;

using StringTools;
using se.net.ws.WebSocket;

class WebSocket {
	public static inline var CONNECTING:Int = 0;
	public static inline var OPEN:Int = 1;
	public static inline var CLOSING:Int = 2;
	public static inline var CLOSED:Int = 3;

	static function writeFrame(data:Bytes, opcode:OpCode, isMasked:Bool, isFinal:Bool):Bytes {
		var out = new Buffer();
		var mask = Bytes.alloc(4);
		for (i in 0...4)
			mask.set(i, Std.random(256));
		var sizeMask = isMasked ? 0x80 : 0x00;

		out.writeByte((isFinal ? 0x80 : 0x00) | opcode);

		var len = data.length;
		if (len < 126) {
			out.writeByte(len | sizeMask);
		} else if (len <= 0xFFFF) {
			out.writeByte(126 | sizeMask);
			out.writeByte(len >>> 8);
			out.writeByte(len & 0xFF);
		} else {
			out.writeByte(127 | sizeMask);
			// no UInt64 in haxe so 0 + 32 bit
			out.writeByte(0);
			out.writeByte(0);
			out.writeByte(0);
			out.writeByte(0);
			out.writeByte((len >>> 24) & 0xFF);
			out.writeByte((len >>> 16) & 0xFF);
			out.writeByte((len >>> 8) & 0xFF);
			out.writeByte(len & 0xFF);
		}

		if (isMasked) {
			out.writeBytes(mask);
			var payload = Bytes.alloc(len);
			for (i in 0...len)
				payload.set(i, data.get(i) ^ mask.get(i % 4));
			out.writeBytes(payload);
		} else
			out.writeBytes(data);

		return out.readAllAvailableBytes();
	}

	static function readFrame(socket:Socket):{opcode:OpCode, isFinal:Bool, data:Bytes} {
		var input = socket.input;

		var b1 = input.readByte();
		var b2 = input.readByte();

		var isFinal = (b1 & 0x80) != 0;
		var opcode = b1 & 0x0F;

		var isMasked = (b2 & 0x80) != 0;
		var payloadLen = b2 & 0x7F;

		if (payloadLen == 126) {
			payloadLen = input.readByte() << 8 | input.readByte();
		} else if (payloadLen == 127) {
			// Note: ignoring first 4 bytes (high bits), since Haxe doesn't support 64-bit ints easily
			for (i in 0...4)
				input.readByte();
			payloadLen = (input.readByte() << 24) | (input.readByte() << 16) | (input.readByte() << 8) | input.readByte();
		}

		var mask:Bytes = null;
		if (isMasked) {
			mask = Bytes.alloc(4);
			for (i in 0...4)
				mask.set(i, input.readByte());
		}

		var payload = Bytes.alloc(payloadLen);
		input.readFullBytes(payload, 0, payloadLen);

		if (isMasked) {
			for (i in 0...payloadLen)
				payload.set(i, payload.get(i) ^ mask.get(i % 4));
		}

		return {
			opcode: opcode,
			isFinal: isFinal,
			data: payload
		};
	}

	// All clients messages must be masked: http://tools.ietf.org/html/rfc6455#section-5.1
	static function sendFrame(socket:Socket, data:Bytes, opcode:OpCode) {
		try {
			socket.output.write(WebSocket.writeFrame(data, opcode, true, true));
			socket.output.flush();
		} catch (e)
			Log.error('Failed to send data from ${socket.host().host} - ${e.message}');
	}

	static function sendHttpRequest(socket:Socket, req:HTTPRequest) {
		try {
			socket.output.writeString(req.toString());
			socket.output.flush();
		} catch (e:Dynamic)
			Log.error('Failed to send HTTP request to ${socket.host().host} - ${e.message}');
	}

	static function sendHttpResponse(socket:Socket, resp:HTTPResponse) {
		try {
			socket.output.writeString(resp.toString());
			socket.output.flush();
		} catch (e:Dynamic)
			Log.error('Failed to send HTTP response to ${socket.host().host} - ${e.message}');
	}

	var socket:Socket;
	var key:String;
	var additionalHeaders:Map<String, String> = [];

	/**
		The binary data type used by the connection.
	**/
	var binaryType:BinaryType;

	/**
		The number of bytes of queued data.
	**/
	public var bufferedAmount(default, null):Int;

	/**
		The extensions selected by the server.
	**/
	public var extensions(default, null):String;

	/**
		The sub-protocol selected by the server.
	**/
	public var protocol(default, null):String;

	/**
		The absolute URL of the WebSocket.
	**/
	public var url(default, null):String;

	/**
		The current state of the connection.
	**/
	public var readyState(default, null):Int;

	public var host(default, null):String;
	public var port(default, null):Int;

	public var onopen:() -> Void;

	public var onerror:() -> Void;

	public var onmessage:(message:Message) -> Void;

	public var onclose:() -> Void;

	public var tickRate:Float = 64;

	public function new(url:String, immediateConnect:Bool = true, ?protocols:Array<String>):Void {
		this.url = url;
		this.socket = new Socket();

		var uriRegExp = ~/^(\w+?):\/\/([\w\.-]+)(:(\d+))?(\/.*)?$/;

		if (!uriRegExp.match(url))
			Log.error('Uri not matching websocket uri "$url"');

		var proto = uriRegExp.matched(1);
		if (proto == "wss") {
			#if (java || cs)
			Log.error("Secure sockets not implemented");
			#else
			port = 443;
			this.socket = new SecureSocket();
			#end
		} else if (proto == "ws")
			port = 80;
		else
			Log.error('Unknown protocol $proto');

		host = uriRegExp.matched(2);
		var parsedPort = Std.parseInt(uriRegExp.matched(4));
		if (parsedPort > 0)
			port = parsedPort;

		url = uriRegExp.matched(5);
		if (url == null || url.length == 0)
			url = "/";

		if (immediateConnect)
			connect();
	}

	public function connect() {
		try {
			Log.debug('Connecting to $url ...');

			socket.setBlocking(true);
			socket.connect(new Host(host), port);
			socket.setBlocking(false);
			sendHandshake();

			var resp = recv();
			if (resp == null) {
				Log.error('Handshake failed: no request from ${socket.host().host}');
				close();
				return;
			}

			if (processHandshake(parseHttpResponse(resp))) {
				Log.debug('Successfully connected to $url. Key: $key');
				if (onopen != null)
					onopen();
				process();
			} else {
				error('Failed to connect socket, invalid handshake response');
				close();
			}
		} catch (e:Dynamic) {
			error('Failed to connect socket - ${e.message}');
			close();
		}
	}

	public function close(?code:Int, ?reason:String):Void {
		try {
			WebSocket.sendFrame(socket, Bytes.ofString("close"), Close);
			socket.close();
			if (onclose != null)
				onclose();
			Log.debug("The socket was closed");
		} catch (e)
			error('Failed to close socket - ${e.message}');
	}

	overload extern public inline function send(data:Bytes):Void {
		socket.sendFrame(data, Binary);
	}

	overload extern public inline function send(data:String):Void {
		socket.sendFrame(Bytes.ofString(data), Text);
	}

	function ping() {
		socket.sendFrame(Bytes.ofString("keep-alive"), Ping);
	}

	function process() {
		#if cs
		haxe.MainLoop.addThread(() -> {
			while (tick())
				Sys.sleep(1 / tickRate);
		});
		#else
		Thread.create(() -> {
			while (tick())
				Sys.sleep(1 / tickRate);
		});
		#end
	}

	function tick():Bool {
		var frame = socket.readFrame();
		switch frame.opcode {
			case Text:
				var text = frame.data.toString();
				Log.info('Received from ${socket.host().host}: $text');
				if (onmessage != null)
					onmessage(Text(text));
			case Binary:
				Log.info('Received ${frame.data.length} bytes from ${socket.host().host}');
				if (onmessage != null)
					onmessage(Binary(frame.data));
			case Close:
				try {
					socket.close();
					if (onclose != null)
						onclose();
					Log.debug("The socket was closed");
				} catch (e)
					error('Failed to close socket - ${e.message}');
				return false;
			case Ping:
				sendFrame(socket, frame.data, Pong);
			case Pong:
				null;
			case Continuation:
				null;
		}
		return true;
	}

	function error(?code:Int, ?reason:String) {
		Log.error(reason ?? "An error occured");
		if (onerror != null)
			onerror();
	}

	function sendHandshake() {
		var req = new HTTPRequest();
		req.method = "GET";
		req.uri = url;
		req.httpVersion = "HTTP/1.1";

		req.headers.set(HTTPHeader.HOST, '$host:$port');
		req.headers.set(HTTPHeader.USER_AGENT, "haxe");
		req.headers.set(HTTPHeader.SEC_WEBSOCKET_VERSION, "13");
		req.headers.set(HTTPHeader.UPGRADE, "websocket");
		req.headers.set(HTTPHeader.CONNECTION, "Upgrade");
		req.headers.set(HTTPHeader.PRAGMA, "no-cache");
		req.headers.set(HTTPHeader.CACHE_CONTROL, "no-cache");
		req.headers.set(HTTPHeader.ORIGIN, socket.host().host.toString() + ":" + socket.host().port);

		var b = Bytes.alloc(16);
		for (i in 0...16)
			b.set(i, Std.random(255));
		key = Base64.encode(b);
		req.headers.set(HTTPHeader.SEC_WEBSOCKET_KEY, key);

		for (k in additionalHeaders.keys())
			req.headers.set(k, additionalHeaders[k]);

		socket.sendHttpRequest(req);
	}

	function processHandshake(resp:HTTPResponse) {
		if (resp.code != 101) {
			error(resp.headers.get(HTTPHeader.X_WEBSOCKET_REJECT_REASON));
			return false;
		}
		var secKey = resp.headers.get(HTTPHeader.SEC_WEBSOCKET_ACCEPT);
		if (secKey != wsKey(key)) {
			error("Error during WebSocket handshake: Incorrect 'Sec-WebSocket-Accept' header value");
			return false;
		}
		return true;
	}

	function parseHttpRequest(data:String):HTTPRequest {
		var req = new HTTPRequest();
		for (line in data.split("\n"))
			req.addLine(line);
		return req;
	}

	function parseHttpResponse(data:String):HTTPResponse {
		var resp = new HTTPResponse();
		for (line in data.split("\r\n\r\n")[0].split("\n"))
			resp.addLine(line);
		return resp;
	}

	function recv(timeout:Float = 5.0):Null<String> {
		var startTime = Sys.time();
		var resp = new StringBuf();
		var buffer = Bytes.alloc(1024);

		while (Sys.time() - startTime < timeout) {
			try {
				var data = socket.input.readBytes(buffer, 0, 1024);
				if (data > 0) {
					resp.add(buffer.sub(0, data).toString());
					if (resp.toString().indexOf("\r\n\r\n") != -1)
						return resp.toString();
				}
			} catch (e)
				if (e.message == "Blocked")
					Sys.sleep(1 / tickRate);
				else {
					Log.error('Error while reading input: ${e.message}');
					break;
				}
		}

		Log.error("Reading failed: timed out");
		return null;
	}

	inline function wsKey(key:String):String {
		return Base64.encode(Sha1.make(Bytes.ofString(key + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')));
	}
}

enum abstract BinaryType(String) {
	var BLOB = "blob";
	var ARRAYBUFFER = "arraybuffer";
}

enum abstract OpCode(Int) from Int to Int {
	var Continuation = 0x0;
	var Text = 0x1;
	var Binary = 0x2;
	var Close = 0x8;
	var Ping = 0x9;
	var Pong = 0xA;
}
#end

enum Message {
	Text(text:String);
	Binary(data:Bytes);
}
