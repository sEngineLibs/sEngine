package se.net.ws.nodejs;

#if nodejs
import haxe.io.Bytes;
import js.node.Buffer;

@:access(se.net.ws.nodejs.NodeSocket)
class NodeSocketOutput {
	var socket:NodeSocket;
	var buffer:Buffer;

	public function new(socket:NodeSocket) {
		this.socket = socket;
	}

	public function write(data:Bytes) {
		var a = [];
		if (buffer != null)
			a.push(buffer);
		a.push(Buffer.hxFromBytes(data));
		buffer = Buffer.concat(a);
	}

	public function flush() {
		socket.socket.write(buffer);
		buffer = null;
	}
}
#end
