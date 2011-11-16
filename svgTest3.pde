import peasy.*;
import toxi.geom.*;
import toxi.geom.mesh.subdiv.*;
import toxi.geom.mesh.*;
import toxi.physics.*;
import toxi.physics.behaviors.*;
import toxi.physics.constraints.*;
import toxi.processing.*;
import geomerative.*;


PeasyCam cam;
PShape picture;
VerletPhysics physics;
AttractionBehavior inflate;
ToxiclibsSupport gfx;

float springLength = 1;
float strength = .9;
BalloonMesh balloon;

void setup() {
  size(800, 800, P3D);
  //background(255);
  PeasyCam cam = new PeasyCam(this, 200);
  gfx = new ToxiclibsSupport(this);
  RG.init(this);

  physics = new VerletPhysics();
  physics.setWorldBounds(new AABB(new Vec3D(), 100));
  //wiggle = new ParticleShape("fishy.svg");
  balloon = new BalloonMesh("fishy.svg");
}

void draw() {
  background(255);
  balloon.inflateBalloon();
  physics.update();

  balloon.centerBalloon();

  balloon.moveBalloon();

  reEstablishNormals(balloon.side1);
  reEstablishNormals(balloon.side2);
  stroke(0);
  noFill();
  box(100);

  stroke(255, 0, 0);
  noFill();
  gfx.mesh(balloon.side1);
  stroke(0, 0, 255);
  gfx.mesh(balloon.side2);
}

void keyPressed() {
  if (key=='i') {
    inflate=new AttractionBehavior(new Vec3D(), 100, -0.5f, 0.001f);

    physics.addBehavior(inflate);
  }
  if (key=='d') {
    physics.removeBehavior(inflate);
  }
  if (key=='p') {
    noLoop();
  }
}

