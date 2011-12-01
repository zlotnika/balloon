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
import controlP5.*;

PeasyCam cam;
PImage picture;
VerletPhysics physics;
AttractionBehavior inflate;
ToxiclibsSupport gfx;

//controllers
ControlP5 controller;
ControlWindow controlWindow;
Toggle inflateToggle;
Toggle textureToggle;
Button resizeButton;
Button pauseButton;
Boolean pause = false;
Boolean reSize = false;
Button subdivideButton;
Boolean sub = false;

BalloonMesh balloon;
String inputOutline;
boolean Inflate = false;
boolean Texture = false;
int Subdivisions = 0;
float Scale;

void setup() {
  size(800, 800, P3D);

  //just initialize everything
  PeasyCam cam = new PeasyCam(this, 100);
  gfx = new ToxiclibsSupport(this);
  RG.init(this);
  physics = new VerletPhysics();
  physics.setWorldBounds(new AABB(new Vec3D(), 100));

  //controllers
  initControllers();

  //inputs
  newInput();
}

void draw() {
  background(255);
  reEstablishNormals(balloon.side1);
  reEstablishNormals(balloon.side2);
  //move the particles
  if (Inflate == true) {
    balloon.inflateBalloon();
  }
  physics.update();
  stopParticles();
  if (pause == true){
    pauseParticles();
    pause = false;
  }
  balloon.centerBalloon();
  //move the mesh to the particles
  balloon.moveBalloon();
  //display the mesh
  stroke(0);
  noFill();
  box(100);

  if (Texture == true) {
    noStroke();
    lights();
    gfx.texturedMesh(balloon.side1, picture, true);
    gfx.texturedMesh(balloon.side2, picture, true);
  }
  else {
    stroke(255, 0, 0);
    gfx.mesh(balloon.side1, true);
    stroke(0, 0, 255);
    gfx.mesh(balloon.side2, true);
  }

  //do buttons
  if (reSize == true) {
    balloon.reScale(Scale);
    reSize = false;
  }
  if (sub == true) {
    balloon.initBalloon(Subdivisions); 
    println("Restarted with " + Subdivisions + " subdivisions.");
    sub = false;
  }
}

