package g9;
import java.io.*;
import java.net.*;

public class Client extends Thread{
	
	String host;
	int port;
	Socket s;
	
	Client(String host, int port) throws UnknownHostException, IOException{
		this.host = host;
		this.port = port;
		this.s = new Socket(host, port);
	}
	
	public void run() {
		try {
			//s = new Socket(host, port);
			//BufferedReader in = new BufferedReader(new InputStreamReader(cli.getInputStream()));
			BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
			PrintWriter out = new PrintWriter(s.getOutputStream());
			
			String str;
			
			while((str = br.readLine()) != null) {
				out.println(str);
				out.flush();
			}
			
			s.close();
			
		}catch(Exception e) {
			//todo:
		}
	}
}
