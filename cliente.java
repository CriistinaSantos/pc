import java.io.*;
import java.net.*;

public class cliente {

public static void main(String[] args) {

try{
  if(args.length<2)
  System.exit(1);
  //System.out.println(args[1]);
  String host = args[0];
  int port = Integer.parseInt(args[1]);
  Socket s = new Socket(host, port);
  BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
  PrintWriter out = new PrintWriter(s.getOutputStream());
  String line;
  while((line = in.readLine()) != null){//Ja le do terminal.
	System.out.println(line);
	out.println(line);
	out.flush();
  }
  //out.println(line);
  //out.flush();
  //String res = in.readLine();
  //System.out.println(res);
}catch(Exception e){
  e.printStackTrace();
  System.exit(0);
}
}

}
