RMesh SVGToRMesh(String filename, float scaleSize) {
  // input the SVG
  RShape inputShape = RG.loadShape(filename);
  //print(inputShape.children[0].countPaths());
  //inputShape = inputShape.children[0];
  // get us to the correct child

  while ( inputShape.countPaths () == 0 ) {
    inputShape = inputShape.children[0];
  }

  //print(inputShape.countPaths());

  // scale it down
  RShape scaledShape = scaleShape(inputShape, scaleSize);
  // make it an RMesh
  RMesh Rmesh = scaledShape.toMesh();
  // convert it to a WETriangleMesh for each side
  return Rmesh;
}

WETriangleMeshText initMesh(RMesh Rmesh, int subdiv, float offset, float invScaleSize) {

  WETriangleMeshText mesh = convertMesh(Rmesh, invScaleSize);

  for (int i=0;i<subdiv;i++) {
    mesh.subdivide(2);
    //mesh.fixTexture();
  }

  //center mesh
  centerMesh(mesh, offset);


  return mesh;
}

RShape scaleShape( RShape oldShape, float scaleSize) {
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

WETriangleMeshText convertMesh(RMesh oldMesh, float invScaleSize) {
  WETriangleMeshText newMesh = new WETriangleMeshText(invScaleSize);

  // copy over the faces of the strips
  for (RStrip triStrip : oldMesh.strips) {
    for (int i = 0 ; i < triStrip.vertices.length - 2 ; i++) {

      VerletParticle a = new VerletParticle(triStrip.vertices[i].x, triStrip.vertices[i].y, 0);
      Vec2D uvA = new Vec2D(triStrip.vertices[i].x * invScaleSize, triStrip.vertices[i].y * invScaleSize);
      VerletParticle b = new VerletParticle(triStrip.vertices[i+1].x, triStrip.vertices[i+1].y, 0);
      Vec2D uvB = new Vec2D(triStrip.vertices[i+1].x * invScaleSize, triStrip.vertices[i+1].y * invScaleSize);
      VerletParticle c = new VerletParticle(triStrip.vertices[i+2].x, triStrip.vertices[i+2].y, 0);
      Vec2D uvC = new Vec2D(triStrip.vertices[i+2].x * invScaleSize, triStrip.vertices[i+2].y * invScaleSize);
        //newMesh.addFace(a, b, c, uvA, uvB, uvC);

      if (i%2 == 0) {
        newMesh.addFace(a, b, c, uvA, uvB, uvC);
      }
      else {
        newMesh.addFace(a, b, c, uvB, uvA, uvC);
      }
    }
  }

  // to connect the faces in between the strips
  int[] iList = new int[0];
  int[] jList = new int[0];
  float[] vertX = new float[0];
  float[] vertY = new float[0];

  // get the points of intersection
  //print(oldMesh.strips.length);
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
          print(uvA.x +","+ uvA.y + ";");


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

