class WETriangleMeshText extends WETriangleMesh {
  float invScaleSize;
  WETriangleMeshText(float invScaleSize) {
    this.invScaleSize = invScaleSize;
  }

  //every time we split a face, this reconstructs the texture coordinates
  protected void splitFace(WEFace f, WingedEdge e, List<Vec3D> midPoints) {
    Vec2D uvA = new Vec2D(e.a.x * invScaleSize, e.a.y * invScaleSize);
    Vec2D uvB = new Vec2D(e.b.x * invScaleSize, e.b.y * invScaleSize);
    Vec3D p = null;
    for (int i = 0; i < 3; i++) {
      WingedEdge ec = f.edges.get(i);
      if (!ec.equals(e)) {
        if (ec.a.equals(e.a) || ec.a.equals(e.b)) {
          p = ec.b;
        } 
        else {
          p = ec.a;
        }
        break;
      }
    }
    Vec2D uvP = new Vec2D(p.x * invScaleSize, p.y * invScaleSize);
    Vec3D prev = null;
    Vec2D uvPrev = null;
    for (int i = 0, num = midPoints.size(); i < num; i++) {
      Vec3D mid = midPoints.get(i);
      Vec2D uvMid = new Vec2D(mid.x * invScaleSize, mid.y * invScaleSize);
      if (i == 0) {
        addFace(p, e.a, mid, f.normal, uvP, uvA, uvMid);
      } 
      if (i == num - 1) {
        addFace(p, mid, e.b, f.normal, uvP, uvMid, uvB);
      }
      prev = mid;
      uvPrev = uvMid;
    }
  }

  //if we want to try to fix the triangles
  void fixTexture() {
    for (Face f : faces) {
      Vec2D[] uvOrder = orderUVCoordinates(f.a, f.b, f.c, f.uvA, f.uvB, f.uvC);
      f.uvA = uvOrder[0];
      f.uvB = uvOrder[1];
      f.uvC = uvOrder[2];
    }
  }

  Vec2D[] orderUVCoordinates(Vec3D a, Vec3D b, Vec3D c, Vec2D uvA, Vec2D uvB, Vec2D uvC) {
    //order the vertices
    Vec3D[] startList3D = {
      a, b, c
    };
    ArrayList ordered3D = new ArrayList();
    //add the leftmost
    Vec3D left3D = startList3D[0];
    for (Vec3D p : startList3D) {
      if ( p.x < left3D.x) {
        left3D = p;
      }
    }
    ordered3D.add(left3D);
    //add the rightmost
    Vec3D right3D = startList3D[0];
    for (Vec3D p : startList3D) {
      if ( p.x > right3D.x) {
        right3D = p;
      }
    }
    ordered3D.add(right3D);
    //add the middle
    Vec3D middle3D = null;
    for (Vec3D p : startList3D) {
      if ( p != left3D && p != right3D) {
        middle3D = p;
      }
    }
    ordered3D.add(middle3D);  

    //now for the uv
    Vec2D[] startList2D = {
      uvA, uvB, uvC
    };
    ArrayList ordered2D = new ArrayList();
    //add the leftmost
    Vec2D left2D = startList2D[0];
    for (Vec2D p : startList2D) {
      if ( p.x < left2D.x) {
        left2D = p;
      }
    }
    ordered2D.add(left2D);
    //add the rightmost
    Vec2D right2D = startList2D[0];
    for (Vec2D p : startList2D) {
      if ( p.x > right2D.x) {
        right2D = p;
      }
    }
    ordered2D.add(right2D);
    //add the middle
    Vec2D middle2D = startList2D[1];
    for (Vec2D p : startList2D) {
      if ( p != left2D && p != right2D) {
        middle2D = p;
      }
    }
    ordered2D.add(middle2D);

    //order uv in a,b,c order
    Vec2D[] output = new Vec2D[3];
    print(ordered3D.indexOf(a) + ",");
    output[0] = (Vec2D) ordered2D.get(ordered3D.indexOf(a));
    output[1] = (Vec2D) ordered2D.get(ordered3D.indexOf(b));
    output[2] = (Vec2D) ordered2D.get(ordered3D.indexOf(c));
    return output;
  }
}

