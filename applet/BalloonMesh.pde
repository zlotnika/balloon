
class BalloonMesh {
  WETriangleMesh side1;
  WETriangleMesh side2;
  VerletParticle[] boundaryParticles;
  RMesh inputMesh;
  int IDOffset;
  float scaleSize = .07;
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

  void curveBoundaryIn(WETriangleMesh mesh) {
    for (WEVertex v : getBoundaryVertices(mesh)) {
      ((WEVertex) v).set(new Vec3D(v.x, v.y, 0));
    }
  }

  void attachSpringsToBoundary() {
    for (WingedEdge e : side1.edges.values()) {
      if (e.faces.size() == 1) {

        VerletParticle a = physics.particles.get(((WEVertex) e.a).id);
        VerletParticle b = physics.particles.get(((WEVertex) side2.getClosestVertexToPoint(e.a)).id + IDOffset);
        physics.addSpring(new VerletSpring(a, b, 0, 1));
      }
    }
  }

  void centerBalloon() {
    Vec3D cent1 = side1.computeCentroid();
    Vec3D cent2 = side2.computeCentroid();
    Vec3D totalCent = cent1.add(cent2);  

    totalCent.scaleSelf(-.1);
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

  void moveBalloon() {
    moveMesh(side1, 0);
    moveMesh(side2, IDOffset);
  }

  void inflateBalloon() {
    inflateMesh(side1, 0);
    inflateMesh(side2, IDOffset);
  }
}

