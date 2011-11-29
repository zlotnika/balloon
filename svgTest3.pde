import peasy.*;
import toxi.geom.*;
import toxi.geom.mesh.subdiv.*;
import toxi.geom.mesh.*;
import toxi.physics.*;
import toxi.physics.behaviors.*;
import toxi.physics.constraints.*;
import toxi.processing.*;
import geomerative.*;
import toxi.util.*;

PeasyCam cam;
PImage picture;
VerletPhysics physics;
AttractionBehavior inflate;
ToxiclibsSupport gfx;

BalloonMesh balloon;
boolean doesInflate = false;
boolean isWireFrame = true;
int subdiv = 0;

void setup() {
  size(800, 800, P3D);

  //just initialize everything
  PeasyCam cam = new PeasyCam(this, 100);
  gfx = new ToxiclibsSupport(this);
  RG.init(this);

  picture = loadImage("air-swimmers-125x125.jpg");

  physics = new VerletPhysics();
  physics.setWorldBounds(new AABB(new Vec3D(), 100));

  balloon = new BalloonMesh("clownFish4.svg");
}

void draw() {
  background(255);
  reEstablishNormals(balloon.side1);
  reEstablishNormals(balloon.side2);
  if (doesInflate == true) {
    balloon.inflateBalloon();
  }
  physics.update();


  stopParticles();

  balloon.centerBalloon();

  balloon.moveBalloon();


  stroke(0);
  noFill();
  box(100);

  if (isWireFrame == false) {
    noStroke();
    lights();
    //displayMeshWithTexture(balloon.side1,picture);
    gfx.texturedMesh(balloon.side1, picture, true);

    gfx.texturedMesh(balloon.side2, picture, true);
  }

  else {
    stroke(255, 0, 0);
    gfx.mesh(balloon.side1, true);
    stroke(0, 0, 255);
    gfx.mesh(balloon.side2, true);
  }
}

void keyPressed() {
  //inflation
  if (key=='i') {
    if (doesInflate == false) {
      doesInflate = true;
    }
    else { 
      doesInflate = false;
    }
  }
  //color
  if (key=='c') {
    if (isWireFrame == false) {
      isWireFrame = true;
    }
    else { 
      isWireFrame = false;
    }
  }
  //pause
  if (key=='p') {
    if (physics.particles.get(0).isLocked()) {
      for (VerletParticle p : physics.particles) {
        p.unlock();
      }
    }
    else {
      for (VerletParticle p : physics.particles) {
        p.lock();
      }
    }
  }
  //restart
  if (key == 'r') {
    balloon.initBalloon(subdiv); 
    print(subdiv);
  }
  //save
  if (key == 's') {
    balloon.side1.saveAsSTL(sketchPath("balloon-" + DateUtils.timeStamp() + ".stl"));
  }
  if (key>='0' && key<='6') {

    switch(key) {
    case '0':
      subdiv = 0;
      break;
    case '1':
      subdiv = 1;
      break;  
    case '2':
      subdiv = 2;
      break;
    case '3':
      subdiv = 3;
      break;
    case '4':
      subdiv = 4;
      break;
    case '5':
      subdiv = 5;
      break;
    case '6':
      subdiv = 6;
      break;
    }
  }
}

