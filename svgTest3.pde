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
boolean isWireFrame = false;

void setup() {
  size(800, 800, P3D);
  //background(255);
  PeasyCam cam = new PeasyCam(this, 200);
  gfx = new ToxiclibsSupport(this);
  RG.init(this);

  picture = loadImage("fishy.png");

  physics = new VerletPhysics();
  physics.setWorldBounds(new AABB(new Vec3D(), 100));
  //wiggle = new ParticleShape("fishy.svg");
  balloon = new BalloonMesh("fishy.svg");
}

void draw() {
  background(255);
  if (doesInflate == true) {
    balloon.inflateBalloon();
  }
  physics.update();
  stopParticles();

  balloon.centerBalloon();

  balloon.moveBalloon();

  reEstablishNormals(balloon.side1);
  reEstablishNormals(balloon.side2);
  stroke(0);
  noFill();
  box(100);

  if (isWireFrame == false) {
    noStroke();
    lights();
    gfx.texturedMesh(balloon.side1, picture, false);
    gfx.texturedMesh(balloon.side2, picture, false);
  }
  
  else {
    stroke(255, 0, 0);
    gfx.mesh(balloon.side1, true);
    stroke(0, 0, 255);
    gfx.mesh(balloon.side2, true);
  }
}

void keyPressed() {
  if (key=='i') {
    if (doesInflate == false) {
      doesInflate = true;
    }
    else { 
      doesInflate = false;
    }
  }
  if (key=='c') {
    if (isWireFrame == false) {
      isWireFrame = true;
    }
    else { 
      isWireFrame = false;
    }
  }
  if (key=='p') {
    noLoop();
  }
  if (key == 's') {
    balloon.side1.saveAsSTL(sketchPath("balloon-" + DateUtils.timeStamp() + ".stl"));
  }
}

