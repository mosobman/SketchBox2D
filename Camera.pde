
class Camera2D {
  PVector pan = new PVector(0,0);
  float zoomLog = 0.0;
  
  Camera2D() {}
  
  public void pan(float x, float y) {
    pan.add(x/zoom(), -y/zoom());
  }
  
  public void applyMatrix() {
    translate(width/2.0, height/2.0);
    scale(zoom(), zoom());
    translate(pan.x, -pan.y);
  }
  public void drawGrid() {
    float visibleWidth = width / zoom();
    float visibleHeight = height / zoom();
    
    float gridScale = 100.0;
    // Find the start and end coordinates for drawing based on the camera position
    float startX = floor((-pan.x - visibleWidth / 2) / gridScale) * gridScale;
    float endX = floor((-pan.x + visibleWidth / 2) / gridScale) * gridScale;
    float startY = floor((pan.y - visibleHeight / 2) / gridScale) * gridScale;
    float endY = floor((pan.y + visibleHeight / 2) / gridScale) * gridScale;
  
    // Draw vertical grid lines
    float fade = min(max(map(zoomLog, -2.6,-3.5, 1.0,0.0), 0.0), 1.0);
    
    if (fade < 0.25) return;
    translate(0,0,-1);
    noFill(); stroke(100, fade*255); strokeWeight(2.0);
    for (float x = startX; x <= endX + gridScale; x += gridScale) {
      line(x, startY, x, endY + gridScale);
    }
    // Draw horizontal grid lines
    for (float y = startY; y <= endY + gridScale; y += gridScale) {
      line(startX, y, endX + gridScale, y);
    }
    translate(0,0,1);
  }
  
  public float zoom() { return exp(zoomLog); }
  
  public String toString() {
    return String.format("Camera(pan={x:%d, y:%d}, zoomLog=%.1f, zoom=%.3f)", (int) -pan.x, (int) -pan.y, zoomLog, zoom());
  }
}
