package se.net.ws.nodejs;

#if nodejs
import js.node.Net;
import js.node.net.Server;
import js.node.net.Socket;
import sys.net.Host;

class NodeSocket {
	static var connections:Array<NodeSocket> = [];

	var host:Host;
	var port:Int;
	var socket:Socket;
	var server:Server;
	var newConnections:Array<NodeSocket> = [];

	public var input:NodeSocketInput;
	public var output:NodeSocketOutput;

	public function new() {}

	function setSocket(s:Socket) {
		socket = s;
		input = new NodeSocketInput(this);
		output = new NodeSocketOutput(this);
	}

	function createServer():Void {
		if (server == null)
			server = Net.createServer(acceptConnection);
	}

	function acceptConnection(socket:Socket) {
		socket.setTimeout(0);
		var nodeSocket = new NodeSocket();
		nodeSocket.setSocket(socket);
		connections.push(nodeSocket);
		newConnections.push(nodeSocket);
	}

	public function accept() {
		if (newConnections.length == 0)
			throw "Blocking";
		return newConnections.pop();
	}

	public function listen(connections:Int):Void {
		if (host == null)
			throw "You must bind the Socket to an address!";
		createServer();
		server.listen({
			host: host.host,
			port: port,
			backlog: connections
		});
	}

	public function bind(host:Host, port:Int):Void {
		host = host;
		port = port;
	}

	public function setBlocking(blocking:Bool) {}

	public function close() {
		server?.close();
		socket?.destroy();
	}

	public static function select(read:Array<Socket>, write:Array<Socket>, others:Array<Socket>,
			?timeout:Float):{read:Array<Socket>, write:Array<Socket>, others:Array<Socket>} {
		if (write != null && write.length > 0)
			throw "Not implemented";
		if (others != null && others.length > 0)
			throw "Not implemented";

		var ret;
		for (c in connections)
			if (read.indexOf(c) != -1 && c.input.hasData) {
				if (ret == null) {
					ret = {
						read: [],
						write: null,
						others: null
					}
				}
				ret.read.push(c);
			}
		return ret;
	}
}
#end
