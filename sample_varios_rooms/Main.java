package g9;

import java.io.*;
import java.net.*;


public class Main{
	
	public static void main(String[] args) throws InterruptedException{
		try {
			Client c = new Client("127.0.0.1", 12345);
			Listener l = new Listener("127.0.0.1", 12345, c.s);
			
			c.start();
			l.start();
			
			c.join();
			l.join();
			
			
		} catch (UnknownHostException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
}
