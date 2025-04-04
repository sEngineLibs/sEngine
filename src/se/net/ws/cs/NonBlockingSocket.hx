package se.net.ws.cs;

#if cs
import sys.net.Socket;
import cs.system.net.sockets.Socket in NativeSocket;
import cs.system.net.sockets.NetworkStream;
import cs.system.net.sockets.SocketAsyncEventArgs;

class NonBlockingSocket extends Socket {
	var acceptedSockets:Array<NativeSocket> = [];
	var socketAsyncEventArgs:SocketAsyncEventArgs = null;

	public function new() {
		super();
		setBlocking(false);
	}

	public override function accept():NonBlockingSocket {
		if (acceptedSockets.length > 0) {
			var n = acceptedSockets.shift();
			var r = new NonBlockingSocket();
			r.sock = n;
			r.output = new cs.io.NativeOutput(new NetworkStream(r.sock));
			r.input = new cs.io.NativeInput(new NetworkStream(r.sock));
			return r;
		}

		if (socketAsyncEventArgs == null) {
			socketAsyncEventArgs = new SocketAsyncEventArgs();
			socketAsyncEventArgs.add_Completed(onAcceptCompleted);
			sock.AcceptAsync(socketAsyncEventArgs);
		}
		throw "Blocking";
	}

	function onAcceptCompleted(sender:Dynamic, e:SocketAsyncEventArgs) {
		acceptedSockets.push(e.AcceptSocket);
		socketAsyncEventArgs = null;
	}

	public static function select(read:Array<Socket>, write:Array<Socket>, others:Array<Socket>,
			?timeout:Float):{read:Array<Socket>, write:Array<Socket>, others:Array<Socket>} {
		return Socket.select(read, write, others, timeout);
	}
}
#end
