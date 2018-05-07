//import processing.core.PVector; 
import java.lang.*;

class Avatar {
PVector positionShip;
float speed = 0; 
float rot; 
float radiusShip;
double mShip;
float x,y;
boolean leftBoolean, rightBoolean, speedBoolean; 

Avatar(float x, float y, float r_) {
    positionShip = new PVector(x, y);
    this.x = x;
    this.y = y;  //ver depois como atualizar a posicao da nave através do erlang
    //speed.mult(3);
    speed = 0;
    rot = 0;
    radiusShip = r_;
    mShip = radiusShip*.1;
  }
 

void DesenharAvatar() {
  x +=  Math.cos(rot)*(speed); // current location + the next "step"
  y +=  Math.sin(rot)*(speed);
  fill(65, 250, 255);
  pushMatrix();
  translate(x,y); 
  rotate(rot); 
   triangle(0, 0, -30, 20, -30, -20);
  // fill(255, 10, 50);
   rect(-38, 12  , 8, 8);
   rect(-38, 0, 8, 8);
   rect(-38, -12, 8, 8); 
  popMatrix();   

  if (leftBoolean == true) {
    rot -= .05;
  } 
  else if (rightBoolean == true) {
    rot += .05;
  } 
  if (speedBoolean == true) { 
    speed += .1;
  }
  else {
    speed -= .25;
  }
  speed = constrain(speed, 0, 4);
}


void keyPressed() {
  //enviar("keyPress",Integer.toString(keyCode));
  if (keyCode == LEFT) {
    leftBoolean = true;
  }
  if (keyCode == RIGHT) {
    rightBoolean = true;
  }
  if (keyCode == UP) {
    speedBoolean = true;
  }
}

void keyReleased() {
  //enviar("keyReleased",Integer.toString(keyCode));
  
  if (keyCode == LEFT) {
    leftBoolean = false;
  }
  if (keyCode == RIGHT) {
    rightBoolean = false;
  }
  if (keyCode == UP) {
    speedBoolean = false;
  }
 }
}