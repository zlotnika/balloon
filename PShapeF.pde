RMesh PShapeToRMesh(String filename, float scaleSize) {
  // input the SVG
  PShape inputShape = loadShape(filename);
  //print(inputShape.children[0].countPaths());
  //inputShape = inputShape.children[0];
  // get us to the correct child
  //print(inputShape.getChild(1).getVertexCount());
  /*
  PShape newShape = inputShape;
   int i = 0;
   while (newShape.getVertexCount() == 0) {
   if (inputShape.getChild(i) == inputShape.getChild(-1)){
   inputShape
   }
   }
   */
  // scale it down
  RShape scaledShape = scalePShapeToRShape(inputShape.getChild(1), scaleSize);
  // make it an RMesh
  RMesh Rmesh = scaledShape.toMesh();
  // convert it to a WETriangleMesh for each side
  return Rmesh;
}

RShape scalePShapeToRShape( PShape oldShape, float scaleSize) {
  RShape newShape = new RShape();

  RPoint[] newHandles = new RPoint[oldShape.getVertexCount()];
  for (int i = 0 ; i < oldShape.getVertexCount() ; i++) {
    RPoint newHandle = new RPoint(oldShape.getVertexX(i) * scaleSize, oldShape.getVertexY(i) * scaleSize);
    newHandles[i] = newHandle;
  }
  RPath newPath = new RPath(newHandles);
  //print(newHandles.length);
  newShape.addPath(newPath);

  return newShape;
}
