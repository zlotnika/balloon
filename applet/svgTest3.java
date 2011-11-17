import processing.core.*; 
import processing.xml.*; 

import peasy.*; 
import toxi.geom.*; 
import toxi.geom.mesh.subdiv.*; 
import toxi.geom.mesh.*; 
import toxi.physics.*; 
import toxi.physics.behaviors.*; 
import toxi.physics.constraints.*; 
import toxi.processing.*; 
import geomerative.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class svgTest3 extends PApplet {












PeasyCam cam;
PImage picture;
VerletPhysics physics;
AttractionBehavior inflate;
ToxiclibsSupport gfx;

float springLength = 1;
float strength = .9f;
BalloonMesh balloon;

public void setup() {
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

public void draw() {
  background(255);
  balloon.inflateBalloon();
  physics.update();
  stopParticles();

  balloon.centerBalloon();

  balloon.moveBalloon();

  reEstablishNormals(balloon.side1);
  reEstablishNormals(balloon.side2);
  stroke(0);
  noFill();
  box(100);

  noStroke();
  lights();
  gfx.texturedMesh(balloon.side1,picture,false);
  gfx.texturedMesh(balloon.side2,picture,false);
}

public void keyPressed() {
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


class BalloonMesh {
  WETriangleMesh side1;
  WETriangleMesh side2;
  VerletParticle[] boundaryParticles;
  RMesh inputMesh;
  int IDOffset;
  float scaleSize = .07f;
  float invScaleSize = 1/scaleSize;

  BalloonMesh(String filename) {
    inputMesh = SVGToRMesh(filename, scaleSize);

    side1 = initMesh(inputMesh, 5, 1, invScaleSize);
    side2 = initMesh(inputMesh, 5, -1, invScaleSize);

    //cleanUpSubdivision(side1,10);
    //side1.rebuildIndex();
    // pull the edges of the meshes to each other

    curveBoundaryIn(side1);
    curveBoundaryIn(side2);

    // get us some physics
    initPhysics(side1, 0);
    IDOffset = physics.particles.size();

    initPhysics(side2, IDOffset);

    // add the second to the first mesh
    attachSpringsToBoundary();
  }

  public void curveBoundaryIn(WETriangleMesh mesh) {
    for (WEVertex v : getBoundaryVertices(mesh)) {
      ((WEVertex) v).set(new Vec3D(v.x, v.y, 0));
    }
  }

  public void attachSpringsToBoundary() {
    for (WingedEdge e : side1.edges.values()) {
      if (e.faces.size() == 1) {

        VerletParticle a = physics.particles.get(((WEVertex) e.a).id);
        VerletParticle b = physics.particles.get(((WEVertex) side2.getClosestVertexToPoint(e.a)).id + IDOffset);
        physics.addSpring(new VerletSpring(a, b, 0, 1));
      }
    }
  }

  public void centerBalloon() {
    Vec3D cent1 = side1.computeCentroid();
    Vec3D cent2 = side2.computeCentroid();
    Vec3D totalCent = cent1.add(cent2);  

    totalCent.scaleSelf(-.1f);
    //print(totalCent);

    for (VerletParticle p : physics.particles) {
      p.set(p.add(totalCent));
    }
    /*
    side1.translate(totalCent);
     side2.translate(totalCent);
     
     for (Vertex v : balloon.side1.vertices.values()) {
     physics.particles.get(v.id).set(v);
     }
     
     for (Vertex v : balloon.side2.vertices.values()) {
     physics.particles.get(v.id + IDOffset).set(v);
     }
     */
  }

  public void moveBalloon() {
    moveMesh(side1, 0);
    moveMesh(side2, IDOffset);
  }

  public void inflateBalloon() {
    inflateMesh(side1, 0);
    inflateMesh(side2, IDOffset);
  }
}


public int[] removeInt(int[] oldArray, int index) {
  int[] newArray;
  int[] part1;
  int[] part2;

  if (index == oldArray.length) {
    newArray = shorten(oldArray);
    return newArray;
  }

  part1 = subset(oldArray, 0, index);
  part2 = subset(oldArray, index+1);
  newArray = concat(part1, part2);
  return newArray;
}

public int[] remove3Int(int[] oldArray, int ind1, int ind2, int ind3) {
  int[] newArray;
  newArray = removeInt(oldArray, ind1);
  newArray = removeInt(newArray, ind2);
  newArray = removeInt(newArray, ind3);
  return newArray;
}

public float[] removeFloat(float[] oldArray, int index) {
  float[] newArray;
  float[] part1;
  float[] part2;

  if (index == oldArray.length) {
    newArray = shorten(oldArray);
    return newArray;
  }

  part1 = subset(oldArray, 0, index);
  part2 = subset(oldArray, index+1);
  newArray = concat(part1, part2);
  return newArray;
}

public float[] remove3Float(float[] oldArray, int ind1, int ind2, int ind3) {
  float[] newArray;
  newArray = removeFloat(oldArray, ind1);
  newArray = removeFloat(newArray, ind2);
  newArray = removeFloat(newArray, ind3);
  return newArray;
}


public RMesh SVGToRMesh(String filename, float scaleSize) {
  // input the SVG
  RShape inputShape = RG.loadShape(filename);
  // scale it down
  RShape scaledShape = scaleShape(inputShape.children[0].children[0], scaleSize);
  // make it an RMesh
  RMesh Rmesh = scaledShape.toMesh();
  // convert it to a WETriangleMesh for each side
  return Rmesh;
}

public WETriangleMesh initMesh(RMesh Rmesh, int subdiv, float offset, float invScaleSize) {

  WETriangleMesh mesh = convertMesh(Rmesh, invScaleSize);

  //center mesh
  centerMesh(mesh, offset);

  for (int i=0;i<subdiv;i++) {
    mesh.subdivide(2);
  }
  return mesh;
}

public RShape scaleShape( RShape oldShape, float scaleSize) {
  RShape newShape = new RShape();

  for (RPath path : oldShape.paths) {
    RPoint[] newHandles = new RPoint[path.getHandles().length];
    for (int i = 0 ; i < path.getHandles().length ; i++) {
      RPoint newHandle = new RPoint(path.getHandles()[i].x * scaleSize, path.getHandles()[i].y * scaleSize);
      newHandles[i] = newHandle;
    }
    RPath newPath = new RPath(newHandles);
    //print(newHandles.length);
    newShape.addPath(newPath);
  }
  return newShape;
}

public WETriangleMesh convertMesh(RMesh oldMesh, float invScaleSize) {
  WETriangleMesh newMesh = new WETriangleMesh();

  // copy over the faces of the strips
  for (RStrip triStrip : oldMesh.strips) {
    for (int i = 0 ; i < triStrip.vertices.length - 2 ; i++) {

      VerletParticle a = new VerletParticle(triStrip.vertices[i].x, triStrip.vertices[i].y, 0);
      Vec2D uvA = new Vec2D(triStrip.vertices[i].x * invScaleSize, triStrip.vertices[i].y * invScaleSize);
      VerletParticle b = new VerletParticle(triStrip.vertices[i+1].x, triStrip.vertices[i+1].y, 0);
      Vec2D uvB = new Vec2D(triStrip.vertices[i+1].x * invScaleSize, triStrip.vertices[i+1].y * invScaleSize);
      VerletParticle c = new VerletParticle(triStrip.vertices[i+2].x, triStrip.vertices[i+2].y, 0);
      Vec2D uvC = new Vec2D(triStrip.vertices[i+2].x * invScaleSize, triStrip.vertices[i+2].y * invScaleSize);

      newMesh.addFace(a, b, c, uvA, uvB, uvC);
    }
  }

  // to connect the faces in between the strips
  int[] iList = new int[0];
  int[] jList = new int[0];
  float[] vertX = new float[0];
  float[] vertY = new float[0];

  // get the points of intersection
  for (int i = 0 ; i < oldMesh.strips.length - 1 ; i++) {
    for (int j = i + 1 ; j < oldMesh.strips.length ; j++) {
      for (RPoint p : oldMesh.strips[i].vertices) {
        for (RPoint q : oldMesh.strips[j].vertices) {
          if (p.x == q.x && p.y == q.y) {
            iList = append(iList, i);
            jList = append(jList, j);
            vertX = append(vertX, p.x);
            vertY = append(vertY, p.y);
          }
        }
      }
    }
  }

  // add faces to the correct ones
  while (iList.length > 0) {
    for ( int k = 1 ; k < iList.length - 1 ; k++ ) {
      for ( int l = k+1 ; l < iList.length ; l++ ) {
        if ( (jList[0] == iList[l] && jList[k] == jList[l]) || (jList[0] == jList[l] && jList[0] == iList[l]) ) {

          VerletParticle a = new VerletParticle(vertX[0], vertY[0], 0);
          Vec2D uvA = new Vec2D(vertX[0] * invScaleSize, vertY[0] * invScaleSize);
          VerletParticle b = new VerletParticle(vertX[k], vertY[k], 0);
          Vec2D uvB = new Vec2D(vertX[k] * invScaleSize, vertY[k] * invScaleSize);
          VerletParticle c = new VerletParticle(vertX[l], vertY[l], 0);   
          Vec2D uvC = new Vec2D(vertX[l] * invScaleSize, vertY[l] * invScaleSize);

          newMesh.addFace(a, b, c, uvA, uvB, uvC);

          iList = remove3Int(iList, l, k, 0);
          jList = remove3Int(jList, l, k, 0);
          vertX = remove3Float(vertX, l, k, 0);
          vertY = remove3Float(vertY, l, k, 0);

          k = iList.length;
          l = iList.length;
        }
      }
    }
  }

  return newMesh;
}


public void displayMeshWithTexture(WETriangleMesh mesh, PImage picture) {
  textureMode(IMAGE);
  for (Face f : mesh.faces) {
    beginShape();
    texture(picture);
    vertex(f.a.x, f.a.y, f.a.z, f.uvA.x, f.uvA.y);
    vertex(f.b.x, f.b.y, f.b.z, f.uvB.x, f.uvB.y);
    vertex(f.c.x, f.c.y, f.c.z, f.uvC.x, f.uvC.y);
    endShape();
  }
}

public void inflateMesh(WETriangleMesh mesh, int IDOffset) {
  for (VerletParticle p : physics.particles) {
    p.clearForce();
  }
  for (Face f : mesh.faces) {
    Vec3D v1 = f.b.sub(f.a);
    Vec3D v2 = f.c.sub(f.a);
    float area = (v1.cross(v2)).magnitude() * .5f;
    Vec3D force = f.normal.scale(.3f * area);
    physics.particles.get(f.a.id + IDOffset).addForce(force);
    physics.particles.get(f.b.id + IDOffset).addForce(force);
    physics.particles.get(f.c.id + IDOffset).addForce(force);
  }
}


public void moveMesh(WETriangleMesh mesh, int IDOffset) {
  for (Vertex v : mesh.vertices.values()) {
    v.set(physics.particles.get(v.id + IDOffset));
  }
}

public void initPhysics(WETriangleMesh mesh, int IDOffset) {
  // turn mesh vertices into physics particles
  for (Vertex v : mesh.vertices.values()) {
    physics.addParticle(new VerletParticle(v));
  }
  // turn mesh edges into springs
  for (WingedEdge e : mesh.edges.values()) {
    VerletParticle a = physics.particles.get(((WEVertex) e.a).id + IDOffset);
    VerletParticle b = physics.particles.get(((WEVertex) e.b).id + IDOffset);
    physics.addSpring(new VerletSpring(a, b, a.distanceTo(b), 1f));
  }
}

public void centerMesh(WETriangleMesh mesh, float offset) {
  Vec3D cent = mesh.computeCentroid();
  Vec3D offsetVec = new Vec3D(0, 0, offset);
  cent.scaleSelf(-1);
  cent.addSelf(offsetVec);
  mesh.translate(cent);
}

public void reEstablishNormals(WETriangleMesh mesh) {
  mesh.computeFaceNormals();
  mesh.faceOutwards();
  mesh.computeVertexNormals();
}

public WEVertex[] getBoundaryVertices(WETriangleMesh mesh) {
  WEVertex[] boundaryVertices = new WEVertex[0];
  for (WingedEdge e : mesh.edges.values()) {
    if (e.faces.size() == 1) {
      boundaryVertices = (WEVertex[]) append(boundaryVertices, e.a);
    }
  }
  return boundaryVertices;
}

public void cleanUpSubdivision(WETriangleMesh mesh, float minDist) {
  boolean inBound = false;
  List<Vertex> remove = new ArrayList<Vertex>();
  for (int i = 0 ; i < mesh.vertices.size() - 1; i++) {
    Vertex v = mesh.getVertexForID(i);
    for (Vertex bound : getBoundaryVertices(mesh)) {
      if (v == bound) {
      }
      else {
        for (int j = i+1 ; j < mesh.vertices.size() ; j++) {
          Vertex other = mesh.getVertexForID(j);
          if ((v.distanceTo(other) < minDist) && (v != other) ) {
            remove.add(v);
            mesh.removeVertices(remove);
            remove.remove(0);
          }
        }
      }
    }
  }
}

public void stopParticles() {
  for (VerletParticle p : physics.particles) {
    p.clearVelocity();
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "svgTest3" });
  }
}
