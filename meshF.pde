//These are functions for meshes which can be used by the BalloonMesh class
void inflateMesh(WETriangleMesh mesh, int IDOffset) {
  Boolean inBound = false;
  for (Face f : mesh.faces) {
    Vec3D v1 = f.b.sub(f.a);
    Vec3D v2 = f.c.sub(f.a);
    float area = (v1.cross(v2)).magnitude() * .5;
    Vec3D force = f.normal.scale(.1 * area);
    
    //add the force to the particles
    /*
    //This might be important for getting the correct forces, but slows everything down too much
    //we have a close enough approximation to physics without it
    for(Vertex v : f.getVertices(new Vertex[3])){
      inBound = false;
      for(Vertex w : getBoundaryVertices(mesh)){
        if (w == v){
          inBound = true;
        }
      }
      if(inBound == true){
            physics.particles.get(v.id + IDOffset).addForce(new Vec3D(force.x * 2.0,force.y * 2.0,0));
      }else{
            physics.particles.get(v.id + IDOffset).addForce(force);
      }
    }*/
    physics.particles.get(f.a.id + IDOffset).addForce(force);
    physics.particles.get(f.b.id + IDOffset).addForce(force);
    physics.particles.get(f.c.id + IDOffset).addForce(force);
  }
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
    physics.addSpring(new VerletSpring(a, b, a.distanceTo(b), 1f));
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

void stopParticles() {
  for (VerletParticle p : physics.particles) {
    p.clearVelocity();
  }
}

float computeSurfaceArea(TriangleMesh mesh){
  float SA = 0;
  float area;
  for(Face f : mesh.faces){
    Vec3D v1 = f.b.sub(f.a);
    Vec3D v2 = f.c.sub(f.a);
    area = (v1.cross(v2)).magnitude() * .5;
    SA += area;
  }
  return SA;
}

float computeVolume(TriangleMesh mesh){
  float V = 0;
  float area;
  for(Face f : mesh.faces){
    Vec3D v1 = f.b.sub(f.a);
    Vec3D v2 = f.c.sub(f.a);
    area = (v1.cross(v2)).magnitude() * .5;
    V += (area * f.getCentroid().z);
  }
  return V;
}
