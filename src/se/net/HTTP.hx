package se.net;

using StringTools;

enum abstract HTTPHeader(String) from String to String {
	var HOST = "Host";
	var PRAGMA = "Pragma";
	var ORIGIN = "Origin";
	var UPGRADE = "Upgrade";
	var CONNECTION = "Connection";
	var USER_AGENT = "User-Agent";
	var CACHE_CONTROL = "Cache-Control";
	var SEC_WEBSOCKET_KEY = "Sec-WebSocket-Key";
	var SEC_WEBSOCKET_ACCEPT = "Sec-WebSocket-Accept";
	var SEC_WEBSOCKET_VERSION = "Sec-WebSocket-Version";
	var X_WEBSOCKET_REJECT_REASON = "X-WebSocket-Reject-Reason";
}

class HTTPRequest {
	public var uri:String;
	public var method:String;
	public var httpVersion:String;
	public var headers:Map<String, String> = [];

	public function new() {}

	public function addLine(line:String) {
		if (method == null) {
			var parts = line.split(" ");
			method = parts[0].trim();
			uri = parts[1].trim();
			httpVersion = parts[2].trim();
		} else {
			var n = line.indexOf(":");
			var name = line.substr(0, n);
			var value = line.substr(n + 1, line.length);
			headers.set(StringTools.trim(name), StringTools.trim(value));
		}
	}

	public function toString():String {
		var sb = new StringBuf();

		sb.add(method);
		sb.add(" ");
		if (uri != null) {
			sb.add(uri);
			sb.add(" ");
		}
		sb.add(httpVersion);
		sb.add("\r\n");

		for (header in headers.keyValueIterator())
			sb.add('${header.key}: ${header.value}\r\n');

		sb.add("\r\n");
		return sb.toString();
	}
}

class HTTPResponse {
	public var httpVersion:String = "HTTP/1.1";
	public var code:Int = -1;
	public var text:String = "";
	public var responseDataString:String;
	public var headers:Map<String, String> = [];

	public function new() {}

	public function addLine(line:String) {
		if (code == -1) {
			var parts = line.split(" ");
			httpVersion = parts[0];
			code = Std.parseInt(parts[1]);
			text = parts[2];
		} else {
			var n = line.indexOf(":");
			var name = line.substr(0, n);
			var value = line.substr(n + 1, line.length);
			headers.set(StringTools.trim(name), StringTools.trim(value));
		}
	}

	public function toString():String {
		var contentLength = 0;
		if (responseDataString != null && responseDataString.length > 0)
			contentLength = responseDataString.length;
		headers.set("Content-Length", Std.string(contentLength));

		var sb:StringBuf = new StringBuf();

		sb.add(httpVersion);
		sb.add(" ");
		sb.add(code);
		if (text != "") {
			sb.add(" ");
			sb.add(text);
		}
		sb.add("\r\n");

		for (header in headers.keys()) {
			sb.add(header);
			sb.add(": ");
			sb.add(headers.get(header));
			sb.add("\r\n");
		}

		sb.add("\r\n");

		if (responseDataString != null && responseDataString.length > 0)
			sb.add(responseDataString);

		return sb.toString();
	}
}
