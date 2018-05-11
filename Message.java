import java.io.*;
import java.util.*;

public class Message extends Thread {
  private BufferedReader in;
  Status st;
  
   Message(BufferedReader in, Status st){
        this.in = in;
        this.st = st;
    }
    
    public void run(){
        try {
            
            while(true){
              String s = in.readLine();
              System.out.println(s);
              //System.out.println(s);
              String[] token = s.split(" "); //dividir string por espaços
              if(token[0].equals("online")){
                Player p = new Player(token[1],Integer.parseInt(token[2]));
                Avatar a = new Avatar(Double.parseDouble(token[3]), Double.parseDouble(token[4]),
                Double.parseDouble(token[5]),Double.parseDouble(token[6]),
                Double.parseDouble(token[7]),Double.parseDouble(token[8]));
                st.addPlayer(p,a);
               }
            
            if(token[0].equals("on_update_left")){
              //Username, Dir
              st.updateDirection(token[1],Double.parseDouble(token[2]));
            }
            
            if(token[0].equals("on_update_right")){
              //Username, Dir
              st.updateDirection(token[1],Double.parseDouble(token[2]));
            }
            }
        }
        catch(Exception e){
          e.printStackTrace();
        }
    }
}