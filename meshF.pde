
void displayMeshWithTexture(WETriangleMesh mesh, PImage picture) {
  textureMode(IMAGE);
  for (Face f : mesh.faces) {
    
        //print(f.uvA + "," + f.uvB + ";");
    beginShape();
    texture(picture); 

    vertex(f.a.x, f.a.y, f.a.z, f.uvA.x, f.uvA.y);
    vertex(f.b.x, f.b.y, f.b.z, f.uvB.x, f.uvB.y);
    vertex(f.c.x, f.c.y, f.c.z, f.uvC.x, f.uvC.y);
    endShape();

  }
}

void inflateMesh(WETriangleMesh mesh, int IDOffset) {
  /*
  for (VerletParticle p : physics.particles) {
    p.clearForce();
  }*/
  for (Face f : mesh.faces) {
    Vec3D v1 = f.b.sub(f.a);
    Vec3D v2 = f.c.sub(f.a);
    float area = (v1.cross(v2)).magnitude() * .2;
    Vec3D force = f.normal.scale(.3 * area);
    physics.particles.get(f.a.id + IDOffset).addForce(force);
    physics.particles.get(f.b.id + IDOffset).addForce(force);
    physics.particles.get(f.c.id + IDOffset).addForce(force);
  }
  /*
  for (Vertex v : getBoundaryVertices(mesh)) {
    VerletParticle p = physics.particles.get(v.id + IDOffset);
    Vec3D f = p.getVelocity();
    p.clearVelocity();
    p.addVelocity(new Vec3D(2*f.x, 2*f.y, 0.0));
  }*/
}


void moveMesh(WETriangleMesh mesh, int IDOffset) {
  for (Vertex v : mesh.vertices.values()) {
    v.set(physics.particles.get(v.id + IDOffset));
  }
  for (Vertex v : getBoundaryVertices(mesh)) {
    VerletParticle p = physics.particles.get(v.id + IDOffset);
    p.set(new Vec3D(p.x, p.y, 0));
    p.clearVelocity();
  }
}

void initPhysics(WETriangleMesh mesh, int IDOffset) {
  // turn mesh vertices into physics particles
  for (Vertex v : mesh.vertices.values()) {
    physics.addParticle(new VerletParticle(v));
  }
  // turn mesh edges into springs
  for (WingedEdge e : mesh.edges.values()) {
    VerletParticle a = physics.particles.get(((WEVertex) e.a).id + IDOffset);
    VerletParticle b = physics.particles.get(((WEVertex) e.b).id + IDOffset);
    physics.addSpring(new VerletSpringUpdatable(a, b, a.distanceTo(b), 1f));
  }
}

void centerMesh(WETriangleMesh mesh, float offset) {
  Vec3D cent = mesh.computeCentroid();
  Vec3D offsetVec = new Vec3D(0, 0, offset);
  cent.scaleSelf(-1);
  cent.addSelf(offsetVec);
  mesh.translate(cent);
}

void reEstablishNormals(WETriangleMesh mesh) {
  mesh.computeFaceNormals();
  mesh.faceOutwards();
  mesh.computeVertexNormals();
}

WEVertex[] getBoundaryVertices(WETriangleMesh mesh) {
  WEVertex[] boundaryVertices = new WEVertex[0];
  for (WingedEdge e : mesh.edges.values()) {
    if (e.faces.size() == 1) {
      boundaryVertices = (WEVertex[]) append(boundaryVertices, e.a);
    }
  }
  return boundaryVertices;
}

void cleanUpSubdivision(WETriangleMesh mesh, float minDist) {
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

void stopParticles() {
  for (VerletParticle p : physics.particles) {
    p.clearVelocity();
  }
}

