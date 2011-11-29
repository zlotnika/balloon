
class VerletPhysicsRandom extends VerletPhysics {
  public List<VerletSpringUpdatable> springs = new ArrayList<VerletSpringUpdatable>();

  protected void updateSprings() {
    ArrayList springList = new ArrayList();
    Iterator i = springs.iterator();
    while (i.hasNext ()) {
      springList.add(i.next());
    }

    for (int j = 0 ; j < springs.size() ; j++) {
      int index = int(random(springList.size()));
      VerletSpringUpdatable s = (VerletSpringUpdatable) springList.get(index);
      s.updatePublic(false);
      springList.remove(index);
    }
  }

  public VerletPhysics addSpring(VerletSpringUpdatable s) {
    if (getSpring(s.a, s.b) == null) {
      springs.add(s);
    }
    return this;
  }
}


class VerletSpringUpdatable extends VerletSpring {
  public VerletSpringUpdatable(VerletParticle a, VerletParticle b, float len, float str) {
    super(a, b, len, str);
  }

  public void updatePublic(boolean applyConstraints) {
    this.update(applyConstraints);
  }
}
