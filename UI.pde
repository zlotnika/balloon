void initControllers() {
  controller = new ControlP5(this);
  controlWindow = controller.addControlWindow("Control Window", 100, 800, 1000, 150);
  controlWindow.setBackground(0);
  Slider subSlider = controller.addSlider("Subdivisions", 0, 5, 0, 100, 10, 10, 100);
  subSlider.setWindow(controlWindow);
  subSlider.setNumberOfTickMarks(6);
  subdivideButton = controller.addButton("Subdivide", Subdivisions, 200, 100, 90, 10 );
  subdivideButton.setWindow(controlWindow);
  Slider scaleSlider = controller.addSlider("Scale", 0.0, 1.0, 0.5, 300, 10, 10, 100);
  scaleSlider.setWindow(controlWindow);
  resizeButton = controller.addButton("ReSize", Scale, 400, 100, 40, 10);
  resizeButton.setWindow(controlWindow);
  inflateToggle = controller.addToggle("Inflate", false, 400, 10, 10, 10);
  inflateToggle.setWindow(controlWindow);
  textureToggle = controller.addToggle("Texture", false, 500, 10, 10, 10);
  textureToggle.setWindow(controlWindow);
  pauseButton = controller.addButton("Pause", 0, 600, 10, 50, 10);
  pauseButton.setWindow(controlWindow);
  Button saveButton = controller.addButton("Save", 0, 700, 10, 40, 10);
  saveButton.setWindow(controlWindow);
  Button areaButton = controller.addButton("SurfaceArea", 0, 500, 100, 110, 10);
  areaButton.setWindow(controlWindow);
  Button volumeButton = controller.addButton("Volume", 0, 650, 100, 60, 10);
  volumeButton.setWindow(controlWindow);
}

void Volume() {
  println("Volume = " + 2*computeVolume(balloon.side1));
}

void SurfaceArea() {
  println("Surface Area = " + 2*computeSurfaceArea(balloon.side1));
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

void Pause(){
  pause = true;
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
    Pause();
  }
  //reset
  if (key == 'r') {
    balloon.initBalloon(Subdivisions); 
    print(" Restarted with " + Subdivisions + " subdivisions.");
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
  if (physics.particles.get(0).isLocked()) {
    for (VerletParticle p : physics.particles) {
      p.unlock();
    }
  }
  else {
    for (VerletParticle p : physics.particles) {
      p.lock();
    }
  }
}

