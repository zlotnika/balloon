import peasy.*;
import toxi.geom.*;
import toxi.geom.mesh.subdiv.*;
import toxi.geom.mesh.*;
import toxi.physics.*;
import toxi.physics.constraints.*;
import toxi.processing.*;
import geomerative.*;
import toxi.util.*;
import controlP5.*;
import processing.opengl.*;

//initialize packages
PeasyCam cam;
VerletPhysics physics;
ToxiclibsSupport gfx;
PMatrix3D currCameraMatrix;
PGraphics3D g3;

//controllers
ControlP5 controller;
ControlGroup controlBox;
ControlWindow controlWindow;
Toggle inflateToggle;
Toggle textureToggle;
Button resizeButton;
Toggle pauseToggle;
Boolean reSize = false;
Button subdivideButton;
Boolean sub = false;
Boolean newBoolean = false;
Textlabel outputText;
String outputNumber = "";
boolean Inflate = false;
boolean Texture = false;
int Subdivisions = 0;
boolean Pause = false;
float Scale;

//initialize other variables
PImage picture;
BalloonMesh balloon;
String inputOutline;

void setup() {
  size(800, 800, OPENGL);

  //just initialize everything
  g3 = (PGraphics3D)g;
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
  hint(ENABLE_DEPTH_TEST);
  pushMatrix();
  background(255);
  reEstablishNormals(balloon.side1);
  reEstablishNormals(balloon.side2);
  //move the particles
  if (Inflate) {
    balloon.inflateBalloon();
  }
  physics.update();
  stopParticles();
  if (Pause) {
    pauseParticles();
  }
  else {
    resumeParticles();
  }
  balloon.centerBalloon();
  //move the mesh to the particles
  balloon.moveBalloon();
  //display the mesh
  stroke(0);
  noFill();
  box(50);

  if (Texture) {
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
  if (newBoolean == true) {
    newBoolean = false;
    setup();
  }
  popMatrix();
  hint(DISABLE_DEPTH_TEST);
  gui();
}

void gui() {
   currCameraMatrix = new PMatrix3D(g3.camera);
   camera();
   controller.draw();
   g3.camera = currCameraMatrix;
}
