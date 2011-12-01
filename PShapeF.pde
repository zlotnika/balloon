//These functions help the input by manipulating the PShape input (SVG)
RMesh PShapeToRMesh(String filename, float scaleSize) {
  // input the SVG
  PShape inputShape = loadShape(filename);
  // get us to the correct child
  PShape vertexShape = findVertices(inputShape);
  // scale it down
  RShape scaledShape = scalePShapeToRShape(vertexShape, scaleSize);
  // make it an RMesh
  RMesh Rmesh = scaledShape.toMesh();
  // convert it to a WETriangleMesh
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
  newShape.addPath(newPath);
  return newShape;
}

PShape findVertices(PShape oldShape) {
  PShape newShape = oldShape;
  Boolean found = false;
  while (found == false) {
    for (PShape s : oldShape.getChildren() ) {
      if (s.getVertexCount() > newShape.getVertexCount()) {
        newShape = s;
      }
    }
    if (newShape.getVertexCount() > 0) {
      found = true;
    }
    else {
      newShape = newShape.getChild(0);
    }
  }
  return newShape;
}

