//This gives our controller window
void initControllers() {
  PFont font = createFont("",30);
  textFont(font);
  
  //get our box to work in
  controller = new ControlP5(this);
  controlBox = controller.addGroup("Control Box",0,height-149,800);
  controlBox.setBackgroundHeight(150);
  controlBox.setBackgroundColor(color(0,100));
  controlBox.hideBar();
  
  //buttons and stuff
  Slider subSlider = controller.addSlider("Subdivisions", 0, 8, 0, 50, 10, 10, 100);
  subSlider.moveTo(controlBox);
  subSlider.setNumberOfTickMarks(9);
  subdivideButton = controller.addButton("Subdivide", Subdivisions, 100, 100, 70, 10 );
  subdivideButton.moveTo(controlBox);
  Slider scaleSlider = controller.addSlider("Scale", 0.0, 1.0, 0.5, 250, 10, 10, 100);
  scaleSlider.moveTo(controlBox);
  resizeButton = controller.addButton("ReSize", Scale, 300, 100, 70, 10);
  resizeButton.moveTo(controlBox);
  inflateToggle = controller.addToggle("Inflate", false, 300, 10, 10, 10);
  inflateToggle.moveTo(controlBox);
  textureToggle = controller.addToggle("Texture", false, 400, 10, 10, 10);
  textureToggle.moveTo(controlBox);
  pauseToggle = controller.addToggle("Pause", false, 500, 10, 10, 10);
  pauseToggle.moveTo(controlBox);
  Button saveButton = controller.addButton("Save", 0, 600, 10, 70, 10);
  saveButton.moveTo(controlBox);
  Button areaButton = controller.addButton("SurfaceArea", 0, 450, 100, 70, 10);
  areaButton.moveTo(controlBox);
  Button volumeButton = controller.addButton("Volume", 0, 550, 100, 70, 10);
  volumeButton.moveTo(controlBox);
  Button newButton = controller.addButton("New", 0, 700, 10, 70, 10);
  newButton.moveTo(controlBox);
  outputText = controller.addTextlabel("label", outputNumber, 650, 100);
  outputText.moveTo(controlBox);
  controller.setAutoDraw(false);
}

void New() {
  newBoolean = true;
}

void Volume() {
  println("Volume = " + 2*computeVolume(balloon.side1));
  outputText.setValue("Volume = " + 2*computeVolume(balloon.side1));
}

void SurfaceArea() {
  println("Surface Area = " + 2*computeSurfaceArea(balloon.side1));
  outputText.setValue("Surface Area = " + 2*computeSurfaceArea(balloon.side1));
}

void ReSize() {
  reSize = true;
}

void Subdivide() {
  sub = true;
}

void Save() {    
  balloon.side1.saveAsSTL(sketchPath("balloon-" + DateUtils.timeStamp() + ".stl"));
}

//key commands
void keyPressed() {
  //inflation
  if (key=='i') {
    inflateToggle.toggle();
  }
  //texture
  if (key=='t') {
    textureToggle.toggle();
  }
  //pause
  if (key=='p') {
    pauseToggle.toggle();
  }
  //reset
  if (key == 'r') {
    Subdivide();
  }
  //save
  if (key == 's') {
    Save();
  }
  //new
  if (key == 'n') {
    setup();
  }
}

void pauseParticles() {
  if (physics.particles.get(0).isLocked() == false) {
    for (VerletParticle p : physics.particles) {
      p.lock();
    }
    println("paused");
  }
}

void resumeParticles() {
  if (physics.particles.get(0).isLocked()) {
    for (VerletParticle p : physics.particles) {
      p.unlock();
    }
    println("unpaused");
  }
}

