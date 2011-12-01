//This gives our controller window
void initControllers() {
  controller = new ControlP5(this);
  controlWindow = controller.addControlWindow("Control Window", 100, 800, 1000, 150);
  controlWindow.setBackground(0);
  Slider subSlider = controller.addSlider("Subdivisions", 0, 5, 0, 100, 10, 10, 100);
  subSlider.setWindow(controlWindow);
  subSlider.setNumberOfTickMarks(6);
  subdivideButton = controller.addButton("Subdivide", Subdivisions, 200, 100, 80, 10 );
  subdivideButton.setWindow(controlWindow);
  Slider scaleSlider = controller.addSlider("Scale", 0.0, 1.0, 0.5, 300, 10, 10, 100);
  scaleSlider.setWindow(controlWindow);
  resizeButton = controller.addButton("ReSize", Scale, 400, 100, 80, 10);
  resizeButton.setWindow(controlWindow);
  inflateToggle = controller.addToggle("Inflate", false, 400, 10, 10, 10);
  inflateToggle.setWindow(controlWindow);
  textureToggle = controller.addToggle("Texture", false, 500, 10, 10, 10);
  textureToggle.setWindow(controlWindow);
  pauseToggle = controller.addToggle("Pause", false, 600, 10, 10, 10);
  pauseToggle.setWindow(controlWindow);
  Button saveButton = controller.addButton("Save", 0, 700, 10, 80, 10);
  saveButton.setWindow(controlWindow);
  Button areaButton = controller.addButton("SurfaceArea", 0, 500, 100, 80, 10);
  areaButton.setWindow(controlWindow);
  Button volumeButton = controller.addButton("Volume", 0, 600, 100, 80, 10);
  volumeButton.setWindow(controlWindow);
  Button newButton = controller.addButton("New", 0, 700, 10, 80, 10);
  newButton.setWindow(controlWindow);
  outputText = controller.addTextlabel("label", outputNumber, 700, 100);
  outputText.setWindow(controlWindow);
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

