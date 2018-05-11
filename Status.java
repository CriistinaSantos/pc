import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.locks.*;

public class Status{
    private Map<Player, Avatar> online;
    private Lock l = new ReentrantLock();
    
    Status(){
      online = new HashMap<>();
    }
    
    public void addPlayer(Player p, Avatar a){
      l.lock();
      try{
        online.put(p,a);  
      }
      finally{
        l.unlock();
      }
    }
    
    public String[] getNames(){
      l.lock(); 
      int i=0; 
      String[] names = new String[2];
        try{
         for(Map.Entry<Player,Avatar> entry : online.entrySet()){
             names[i] = entry.getKey().getUsername();
             i++;
         }
        }finally{
          l.unlock();
          return names;
        } 
    }
    
    public double[][] playerAtributes(){
      l.lock();
      
      double[][] elements = new double[2][5];
      int i = 0;
      try{
        for (Map.Entry<Player,Avatar> entry : online.entrySet()){
          double[] atb = entry.getValue().getAtributes();
          //System.out.println(entry.getKey().toString() + entry.getValue().toString());
          elements[i][0] = atb[0]; elements[i][1] = atb[1];
          elements[i][2] = atb[2]; elements[i][3] = atb[3];
          elements[i][4] = atb[4];
          i++;
        }
      }finally{
        l.unlock();
        return elements;
      } 
    }
    
    public void updatePosition(String username,double x, double y){
      l.lock();
      try{
        Avatar a = null;
        for (Map.Entry<Player,Avatar> entry : online.entrySet()){
          if(entry.getKey().getUsername().equals(username)){
            a = entry.getValue();
            a.updatePos(x,y);
            break;
          }
        }
      }finally{
        l.unlock();
      }
    }
    
    public void updateDirection(String username,double dir){
      l.lock();
      
      try{
        Avatar a = null;
        for (Map.Entry<Player,Avatar> entry : online.entrySet()){
          if(entry.getKey().getUsername().equals(username)){
            a = entry.getValue();
            a.updateDir(dir);
            break;
          }
        }
      }finally{
        l.unlock();
      }
    }
    
    public String toString(){
      String s = "";
      for (Map.Entry<Player,Avatar> entry : online.entrySet()){
        s += entry.getKey().toString() + entry.getValue().toString();
      }
      return s;
    }
}