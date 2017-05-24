PImage starfield;


 Ball[] balls =  { 
  new Ball(100, 100, 20), 
  new Ball(300, 300, 80),
  new Ball(600, 500, 50),
  new Ball(800, 700, 40)
};

void setup() {
  size(1024, 768, P3D);
  
  starfield = loadImage("starfield.png");
  noStroke();
  fill(255);
  
}
void draw() {
  // Even we draw a full screen image after this, it is recommended to use
  // background to clear the screen anyways, otherwise A3D will think
  // you want to keep each drawn frame in the framebuffer, which results in 
  // slower rendering.
  background(0);
  
  // Disabling writing to the depth mask so the 
  // background image doesn't occludes any 3D object.
  hint(DISABLE_DEPTH_MASK);
  image(starfield, 0, 0, width, height);
  hint(ENABLE_DEPTH_MASK);
 
  for (Ball b : balls) {
    b.update();
    b.display();
    
  }
  balls[0].checkCollision(balls[1]);
  balls[0].checkCollision(balls[2]);
  balls[0].checkCollision(balls[3]);
  balls[1].checkCollision(balls[2]);
  balls[1].checkCollision(balls[3]);
  balls[2].checkCollision(balls[3]);
}