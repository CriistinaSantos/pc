package g9;
import java.io.*;
import java.net.*;

public class Listener extends Thread{

	String host;
	int port;
	Socket s;
	
	// n ta a funcionar, ta a entrar 2 vezes
	
	Listener(String host, int port, Socket s){
		this.host = host;
		this.port = port;
		this.s = s;
		
	}
	
	public void run() {
		try {
			//ServerSocket srv = new ServerSocket(port);
			//BufferedReader in = new BufferedReader(new InputStreamReader(cli.getInputStream()));
			BufferedReader br = new BufferedReader(new InputStreamReader(s.getInputStream()));
			//PrintWriter out = new PrintWriter(System.out);
			
			String str;
			while((str = br.readLine()) != null) {
				System.out.println(str);
			}
			//while(true){
			//	System.out.println(br.readLine());
			//}
			
		}catch(Exception e) {
			//todo:
		}
	}
	
}
