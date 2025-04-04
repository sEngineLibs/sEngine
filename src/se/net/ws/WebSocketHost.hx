package se.net.ws;

#if sys
import haxe.io.Bytes;
import sys.net.Host;
import sys.thread.Thread;
import se.net.HTTP;

using StringTools;
using se.net.ws.WebSocket;
using se.net.ws.WebSocketHost;

class WebSocketHost extends WebSocket {
	static function sendFrame(socket:Socket, data:Bytes, opcode:OpCode) {
		try {
			socket.output.write(data.writeFrame(opcode, false, true));
			socket.output.flush();
		} catch (e)
			Log.error('Failed to send data from ${socket.host().host} - ${e.message}');
	}

	var connections:Array<Socket> = [];

	public var onConnectionOpen:(connection:Socket) -> Void;

	public var onConnectionMessage:(connection:Socket, message:Message) -> Void;

	public var onConnectionClose:(connection:Socket) -> Void;

	public var limit:Int;

	public function new(host:String, port:Int, limit:Int = 10) {
		super('ws://$host:$port', false);
		this.limit = limit;
	}

	public function start() {
		try {
			bind();
			Log.debug('Server started at $url');
			process();
		} catch (e)
			Log.fatal('Failed to start server at $url - ${e.message}');
	}

	overload extern public inline function sendAll(message:String) {
		for (connection in connections)
			connection.sendFrame(Bytes.ofString(message), Text);
	}

	overload extern public inline function sendAll(data:Bytes) {
		for (connection in connections)
			connection.sendFrame(data, Binary);
	}

	function bind() {
		socket.bind(new Host(host), port);
		socket.listen(limit);
	}

	override function process() {
		while (tick())
			Sys.sleep(1 / tickRate);
	}

	override function close(?code:Int, ?reason:String):Void {
		try {
			socket.sendFrame(Bytes.ofString("close"), Close);
			for (connection in connections)
				closeConnection(connection);
			socket.close();
			if (onclose != null)
				onclose(code, reason);
		} catch (e)
			error('Failed to close socket - ${e.message}');
	}

	override function tick() {
		var connection = socket.accept();
		if (connection != null)
			processConnection(connection);
		return true;
	}

	function handshake(connection:Socket, req:HTTPRequest):Bool {
		var res = new HTTPResponse();
		var result = "";

		res.headers.set(HTTPHeader.SEC_WEBSOCKET_VERSION, "13");
		if (req.method != "GET" || req.httpVersion != "HTTP/1.1") {
			res.code = 400;
			res.text = "Bad";
			res.headers.set(HTTPHeader.CONNECTION, "close");
			res.headers.set(HTTPHeader.X_WEBSOCKET_REJECT_REASON, 'Bad request');
		} else if (req.headers.get(SEC_WEBSOCKET_VERSION) != "13") {
			res.code = 426;
			res.text = "Upgrade";
			res.headers.set(HTTPHeader.CONNECTION, "close");
			res.headers.set(HTTPHeader.X_WEBSOCKET_REJECT_REASON,
				'Unsupported websocket client version: ${req.headers.get(SEC_WEBSOCKET_VERSION)}, Only version 13 is supported.');
		} else if (req.headers.get(UPGRADE) != "websocket") {
			res.code = 426;
			res.text = "Upgrade";
			res.headers.set(HTTPHeader.CONNECTION, "close");
			res.headers.set(HTTPHeader.X_WEBSOCKET_REJECT_REASON, 'Unsupported upgrade header: ${req.headers.get(UPGRADE)}.');
		} else if (req.headers.get(CONNECTION).indexOf("Upgrade") == -1) {
			res.code = 426;
			res.text = "Upgrade";
			res.headers.set(HTTPHeader.CONNECTION, "close");
			res.headers.set(HTTPHeader.X_WEBSOCKET_REJECT_REASON, 'Unsupported connection header: ${req.headers.get(CONNECTION)}.');
		} else {
			var key = req.headers.get(SEC_WEBSOCKET_KEY);
			result = wsKey(key);

			res.code = 101;
			res.text = "Switching Protocols";
			res.headers.set(HTTPHeader.UPGRADE, "websocket");
			res.headers.set(HTTPHeader.CONNECTION, "Upgrade");
			res.headers.set(HTTPHeader.SEC_WEBSOCKET_ACCEPT, result);
		}

		connection.sendHttpResponse(res);

		if (res.code == 101) {
			connections.push(connection);
			Log.debug('New connection: ${connection.host().host} (${connections.length} total). Handshaking key: $result');
			return true;
		} else {
			Log.error('Failed to handshake with ${connection.host().host} - ${res.text}');
			closeConnection(connection);
			return false;
		}
	}

	function processConnection(connection:Socket) {
		Thread.create(() -> {
			var req = "";
			while (!req.endsWith("\r\n\r\n")) {
				var chunk = connection.input.read(1);
				if (chunk == null || chunk.length == 0)
					break;
				req += chunk.toString();
			}
			if (handshake(connection, parseHttpRequest(req))) {
				if (onConnectionOpen != null)
					onConnectionOpen(connection);
				while (tickConnection(connection))
					Sys.sleep(1 / tickRate);
			}
		});
	}

	function tickConnection(connection:Socket) {
		var frame = connection.readFrame();
		switch frame.opcode {
			case Text:
				var text = frame.data.toString();
				Log.info('Received from ${connection.host().host}: $text');
				if (onConnectionMessage != null)
					onConnectionMessage(connection, Text(text));
			case Binary:
				Log.info('Received ${frame.data.length} bytes from ${connection.host().host}');
				if (onConnectionMessage != null)
					onConnectionMessage(connection, Binary(frame.data));
			case Close:
				removeConnection(connection);
				if (onConnectionClose != null)
					onConnectionClose(connection);
				return false;
			case Ping:
				connection.sendFrame(frame.data, Pong);
			case Pong:
				null;
			case Continuation:
				null;
		}
		return true;
	}

	function closeConnection(connection:Socket) {
		connection.sendFrame(Bytes.ofString("close"), Close);
		removeConnection(connection);
		if (onConnectionClose != null)
			onConnectionClose(connection);
	}

	function removeConnection(connection:Socket) {
		if (connections.remove(connection))
			Log.debug('Connection ${connection.host().host} was closed - (${connections.length} total)');
	}
}
#end
