//This class is a combination of 2 mesh sides, physical particles and springs mapping to the vertices and edges of the meshes, and a texture
//We input using an SVG filename. As we manipulate, scaleSize keeps our texture coordinates.
class BalloonMesh {
  WETriangleMeshText side1;
  WETriangleMeshText side2;
  VerletParticle[] boundaryParticles;
  RMesh inputMesh;
  int IDOffset;
  float scaleSize = .5;
  float invScaleSize = 1/scaleSize;
  int subdivisions = 0;
  String filename;

  BalloonMesh(String _filename) {
    filename = _filename;
    inputMesh = PShapeToRMesh(filename, scaleSize);
    initBalloon(0);
  }
  /*
  void curveBoundaryIn(WETriangleMesh mesh) {
   for (WEVertex v : getBoundaryVertices(mesh)) {
   ((WEVertex) v).set(new Vec3D(v.x, v.y, 0));
   }
   }
   */
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

    totalCent.scaleSelf(-.4);

    for (VerletParticle p : physics.particles) {
      p.set(p.add(totalCent));
    }
  }

  void moveBalloon() {
    moveMesh(side1, 0);
    moveMesh(side2, IDOffset);
  }

  void inflateBalloon() {
    inflateMesh(side1, 0);
    inflateMesh(side2, IDOffset);
  }

  void initBalloon(int newSubdiv) {
    subdivisions = newSubdiv;
    side1 = initMesh(inputMesh, subdivisions, 1, invScaleSize);
    side2 = initMesh(inputMesh, subdivisions, -1, invScaleSize);

    physics.clear();
    // get us some physics
    initPhysics(side1, 0);
    IDOffset = physics.particles.size();
    initPhysics(side2, IDOffset);

    // add the second to the first mesh
    attachSpringsToBoundary();
  }

  void reScale(float newScale) {
    scaleSize = newScale;
    invScaleSize = 1/scaleSize;
    inputMesh = PShapeToRMesh(filename, scaleSize);
    initBalloon(subdivisions);
  }
}

