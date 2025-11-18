
import java.util.List;
import java.util.AbstractList;
import java.lang.reflect.Field;



boolean FULLSCREEN = false;
String MODE = P3D;
int FONTSIZE = 20;
Camera2D camera;
Field pressedKeysField;
List<Long> pressedKeysRef;
List<Integer> keyCodeView;
List<Character> keyCharView;
TonePlayer tone = new TonePlayer();

boolean mouseJustPressed, mouseJustReleased;
void mousePressed() { mouseJustPressed = true; }
void mouseReleased() { mouseJustReleased = true; }
void mouseWheel(MouseEvent e) { camera.zoomLog -= e.getCount()/10.0; }
void keyPressed() { if (key == 'm') tone.toggleAudio(); }

void settings() {
  if (FULLSCREEN) fullScreen(MODE);
  else size(1080,720,MODE);
  smooth(8);
}

void stop() {
  tone.stopAudioThread();
}

void setup() {
  frameRate(60);
  textFont(createFont("Arial", FONTSIZE, true));
  camera = new Camera();
  tone.startAudioThread();
  try {
    // Locate private field in PApplet
    pressedKeysField = PApplet.class.getDeclaredField("pressedKeys");
    pressedKeysField.setAccessible(true);
    pressedKeysRef = (List<Long>) pressedKeysField.get(this);
    keyCodeView = new AbstractList<Integer>() {
      @Override
      public Integer get(int index) {
        long hash = pressedKeysRef.get(index);
        return (int)(hash >> Character.SIZE); // upper 48–16 bits → keyCode
      }
    
      @Override
      public int size() { return pressedKeysRef.size(); }
    };
    keyCharView = new AbstractList<Character>() {
      @Override
      public Character get(int index) {
        long hash = pressedKeysRef.get(index);
        return (char)(hash & ((1<<Character.SIZE)-1)); // upper 48–16 bits → keyCode
      }
    
      @Override
      public int size() { return pressedKeysRef.size(); }
    };
  } catch (Exception e) {
    e.printStackTrace();
  }
}

void draw() {
  background(80);
  if (mousePressed) camera.pan(mouseX-pmouseX, mouseY-pmouseY);
  
  //.update();
  
  pushMatrix(); pushStyle();
  camera.applyMatrix();
  camera.drawGrid();
  //.draw();
  popMatrix(); popStyle();
  
  translate(0,0,1);
  drawHUD();
  
  if (mouseJustPressed) mouseJustPressed = false;
  if (mouseJustReleased) mouseJustReleased = false;
}

int[] i = new int[4];
void drawHUD() {
  i[0] = 0; i[1] = 0; i[2] = 0; i[3] = 0;
  textLineTopLeft(String.format("FPS: %.3f", frameRate));
  textLineBottomRight("2D ToolBox");
  textLineBottomLeft(camera.toString());
  textLineTopRight(String.format("Audio (Press M): %s", (tone.targetAmplitude > 0.5) ? "Playing" : "Mute"));
}
void textLineTopLeft(String text) {
  textAlign(LEFT,TOP);
  text(text, FONTSIZE, FONTSIZE*(++i[0]));
}
void textLineTopRight(String text) {
  textAlign(RIGHT,TOP);
  text(text, width-FONTSIZE, FONTSIZE*(++i[1]));
}
void textLineBottomLeft(String text) {
  textAlign(LEFT,BOTTOM);
  text(text, FONTSIZE, height-(FONTSIZE*(++i[2])));
}
void textLineBottomRight(String text) {
  textAlign(RIGHT,BOTTOM);
  text(text, width-FONTSIZE, height-(FONTSIZE*(++i[3])));
}
