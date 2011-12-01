//these are helper functions for the input functions (mostly convertMesh)
int[] removeInt(int[] oldArray, int index) {
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

int[] remove3Int(int[] oldArray, int ind1, int ind2, int ind3) {
  int[] newArray;
  newArray = removeInt(oldArray, ind1);
  newArray = removeInt(newArray, ind2);
  newArray = removeInt(newArray, ind3);
  return newArray;
}

float[] removeFloat(float[] oldArray, int index) {
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

float[] remove3Float(float[] oldArray, int ind1, int ind2, int ind3) {
  float[] newArray;
  newArray = removeFloat(oldArray, ind1);
  newArray = removeFloat(newArray, ind2);
  newArray = removeFloat(newArray, ind3);
  return newArray;
}


