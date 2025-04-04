package se.net.ws.nodejs;

#if nodejs
import haxe.io.Bytes;
import js.node.Buffer;

@:access(se.net.ws.nodejs.NodeSocket)
class NodeSocketInput {
	var socket:NodeSocket;
	var buffer;

	public var hasData:Bool = false;

	public function new(socket:NodeSocket) {
		socket = socket;
		socket._socket.on("data", onData);
	}

	function onData(data:Any) {
		var a = [];
		if (buffer != null)
			a.push(buffer);
		a.push(Buffer.from(data));
		buffer = Buffer.concat(a);
		hasData = true;
	}

	public function readBytes(s:Bytes, pos:Int, len:Int):Int {
		if (buffer == null)
			return 0;

		len = buffer.length > len ? len : buffer.length;

		var part = buffer.slice(0, len);
		var remain = null;
		if (buffer.length > len)
			remain = buffer.slice(len);
		var src = part.hxToBytes();
		s.blit(pos, src, 0, len);
		hasData = (remain != null);
		buffer = remain;
		return len;
	}
}
#end
