import controlP5.*;
import java.io.*;
import java.net.*;
import java.util.*;

ControlP5 cp5;

PImage login_image,start_image,game_image;
PFont f;
boolean OK = true;
boolean loading = false;
boolean connectFailure = false;
boolean create_accountFailure = false;
boolean loginFailure = false;

String textValue = "";
Textfield myTextfield;

//WINDOWS
final int start_window = 0;
final int login_window = 1;
final int loading_window = 2;
final int game_window = 3;
int state = start_window;

//CLIENT, SOCKET, DATA
Client c = null;
String user,pass;
BufferedReader in = null;

Avatar av = new Avatar(50,50,4);
 
void setup() {
  size(1024, 700, P3D);
  noStroke();
  PFont font = createFont("arial",15);
  cp5 = new ControlP5(this);
  
  login_image = loadImage("medieval.gif");
  start_image = loadImage("medieval.gif");
  game_image = loadImage("maingame.jpeg");
  
  
  myTextfield = cp5.addTextfield("USERNAME")
     .setPosition(145,280) 
     .setSize(200,40)
     .setFont(createFont("arial",17))
     .setFocus(true)
     .setAutoClear(false)
     .setColor(color(255,255,255));
     
  myTextfield.setFocus(true);
  cp5.addTextfield("PASSWORD")
  .setPosition(145,350) 
     .setSize(200,40)
     .setFont(createFont("arial",17))
     .setFocus(true)
     .setColor(color(255,255,255))
     .setAutoClear(false)
     .setPasswordMode(true);
     
     cp5.addButton("START")
     .setValue(0)
     .setPosition(145,240) 
     .setSize(200,28)
     .setFont(font)
     .onPress(new CallbackListener() {  
       public void controlEvent(CallbackEvent theEvent){
        c = new Client();
          try {
            c.connect();
            in = new BufferedReader(new InputStreamReader(c.getSocket().getInputStream()));
            state = login_window;
          }
          catch(Exception e){
            connectFailure = true;
            state = start_window;
          };
       }
     });
       
       
     cp5.addButton("LOGIN")
     .setValue(0)
     .setPosition(145,240) 
     .setSize(200,28)
     .setFont(font)
     .onPress(new CallbackListener() {  
       public void controlEvent(CallbackEvent theEvent){
      user = cp5.get(Textfield.class,"USERNAME").getText();
      pass = cp5.get(Textfield.class,"PASSWORD").getText();
      c.login(user,pass);
        try{
        String s = in.readLine();
        if(s.equals("ok_login")){
          System.out.println("logged in!");
          cp5.hide();
          state = game_window;
        }
        else {
          loginFailure = true;
          }
        }
      catch(Exception e){
        state = login_window;
      }
      cp5.hide();
     //state = loading_window;
     }
   })
   ;
  
      cp5.addButton("CREATE AVATAR")
     .setValue(0)
     .setPosition(145,200) 
     .setSize(200,28)
     .setFont(font)
     .onPress(new CallbackListener() {  public void controlEvent(CallbackEvent theEvent) {
      System.out.println("create account!");
      String user = cp5.get(Textfield.class,"USERNAME").getText();
      String pass = cp5.get(Textfield.class,"PASSWORD").getText();
      c.create_account(user,pass);
      try{
        String s = in.readLine();
        if(s.equals("ok_create_account")){
          System.out.println("account created!");
          //cp5.hide();
          state = login_window;
        }
        else {
          create_accountFailure = true;
        }
      }
      catch(Exception e){
        state = login_window;
      }

      //cp5.hide();
      state = login_window;
     }
   })
   ;
   
   f = createFont("Dotum-20.vlw", 20, true);
   smooth();
}


void draw() {
  background(0);
  //PFont font = createFont("arial",10);
  switch(state){
    case start_window:
      showStart();
      break;
    case login_window:
      showLogin();
      break;
    case loading_window:
      showLoading();
      break;
    case game_window:
      showGame();
      break;
  }
}

void showStart(){
  image(start_image,0,0,width,height);
  cp5.getController("LOGIN").hide();
  cp5.getController("CREATE AVATAR").hide();
  cp5.getController("USERNAME").hide();
  cp5.getController("PASSWORD").hide();
  cp5.getController("START").show();
  
  if(connectFailure==true){
      fill(204, 0, 0);
      text("Notice: Connection failure!",100,100);
      connectFailure = false;
  }
}

void showLogin() {
  image(login_image, 0, 0, width, height);
  cp5.getController("LOGIN").show();
  cp5.getController("CREATE AVATAR").show();
  cp5.getController("USERNAME").show();
  cp5.getController("PASSWORD").show();
  cp5.getController("START").hide();
  
  if(loginFailure == true){
    fill(204, 0, 0);
    text("Failed to log in!",100,100);
    loginFailure = false;
    }
    
    if(create_accountFailure == true){
      fill(204, 0, 0);
      text("This account already exists!",100,100);
      create_accountFailure = false;
    }
}

void showGame(){
  image(game_image, 0, 0, width, height);
  cp5.getController("LOGIN").hide();
  cp5.getController("CREATE AVATAR").hide();
  cp5.getController("USERNAME").hide();
  cp5.getController("PASSWORD").hide();
  cp5.getController("START").hide();
  
  av.DesenharAvatar();
  
}

void keyPressed() {
  //enviar("keyPress",Integer.toString(keyCode));
  if(state==game_window){
  if (keyCode == LEFT) {
    av.leftBoolean = true;
    //chamar metodo de mandar mensagem do cliente (class cliente)
  }
  if (keyCode == RIGHT) {
    av.rightBoolean = true;
  }
  if (keyCode == UP) {
    av.speedBoolean = true;
  }
  }
}

void keyReleased() {
  //enviar("keyReleased",Integer.toString(keyCode));
  if(state==game_window){
  if (keyCode == LEFT) {
    av.leftBoolean = false;
  }
  if (keyCode == RIGHT) {
    av.rightBoolean = false;
  }
  if (keyCode == UP) {
    av.speedBoolean = false;
  }
 }
}
  
  
void showLoading() {
  image(login_image, 0, 0, width, height);
  if(OK == true)
  {
    loading = true;
    frameCount = 1;
    OK = false;
  }
  if(loading == false)
  {
    fill(255);
    textAlign(CENTER);
    //text (tx, 150, 150);
  }
  if(loading == true)
  {
    fill(255);
    textAlign(LEFT);
    text ("LOADING " + int((frameCount%301) / 3) + "%", 50, 130);
    rect(48, 138, 204, 24);
    fill(0);
    int fillX = ((frameCount%301) / 3 * 2);
    rect(250, 140, fillX-200, 20);
    if(frameCount%301 == 0)
    {
      System.out.println("Ok");
      loading = false;
    }
  }
}