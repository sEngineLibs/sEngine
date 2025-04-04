package se.net.ws;

#if java
typedef Socket = se.net.ws.java.NioSocket;
#elseif cs
typedef Socket = se.net.ws.cs.NonBlockingSocket;
#elseif nodejs
typedef Socket = se.net.ws.nodejs.NodeSocket;
#elseif sys
typedef Socket = sys.net.Socket;
typedef SecureSocket = sys.ssl.Socket;
#end
