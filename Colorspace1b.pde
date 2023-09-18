// Devoloped by Carson Bentley
// Copyright (c) 2023 Carson Bentley

//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:

//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

void setup() {
  size(500, 500);
  background(0, 0, 0);
  float halfWidth = width/2;
  float halfHeight = height/2;
  
  // This is the a variable to control the value of the rendered color-wheel
  float renderValue = 0.5; 
  
  // if this is true mask out the color gamut, 
  // otherwise, we render the whole wheel (first)
  boolean maskWheel = false;  
  
  // how many samples to take of the image
  int numSamples = 512;
  
  // color of the indication-mark
  color gamutMarkerColor = color(255);
  
  // filename of image to analyze; it should be in the same folder as this file
  String imgName = "goblin1.png";
  
  
  if(maskWheel) markColorGamut(imgName, numSamples, color(255));
  
  strokeWeight(4); //note: redundant
  float maskThreshold = 254; //only mask if enough points fall on a color
  for (int x = 0; x<width; x++) {
    for (int y = 0; y<height; y++) {
      float offsetX = x - halfWidth;
      float offsetY = y - halfHeight;
      // hsv color
      float angleOffset = PI + (PI/12);
      float angleInput = (atan2(offsetY, offsetX) + angleOffset) * 360/( PI*2 );
      PVector hsvC = HSVToRGB(binVal(angleInput, 360, 12)*30, (binVal((dist(halfWidth, halfHeight, x, y)), halfWidth, 7)/6.0), renderValue);
      stroke(hsvC.x*255, hsvC.y*255, hsvC.z*255);
      if (dist(x, y, halfWidth, halfHeight) <= halfWidth) {
        color xyColor = get(x,y);
        if (red(xyColor) + green(xyColor) + blue(xyColor) > 3 * maskThreshold || !maskWheel){
                point(x, y);
        }
      }
    }
  }
  noFill();
  strokeWeight(1);
  stroke(120);
  for (int i = 1; i <= 7; i++) {
    ellipse(halfWidth, halfHeight, i*width/7, i*width/7);
  }

  float rotOffset = PI/12;
  for (int i = 0; i < 12; i++) {
    line(halfWidth, halfHeight, halfWidth*cos(i*PI/6+rotOffset)+halfWidth, halfWidth*sin(i*PI/6+rotOffset)+halfWidth);
  }
  if(!maskWheel) markColorGamut(imgName, numSamples, gamutMarkerColor);
}


PVector RGBToHSV(float r, float g, float b)
{
  float h, s, v;
  float epsilon = 0.000001;
  float undefinedHue = -1;

  float max = max(r, max(g, b));
  float min = min(r, min(g, b));

  v = max;

  if (max > epsilon) {
    s = (max - min) / max;
  } else {
    s = 0;
  }

  if (s < epsilon) {
    h = undefinedHue;
  } else {
    float delta = max - min;

    if (r == max) {
      h = (g - b) / delta;
    } else if (g == max) {
      h = 2 + (b - r) / delta;
    } else {
      h = 4 + (r - g) / delta;
    }

    h *= 60;
    if (h < 0) {
      h += 360;
    }
  }
  return new PVector(h, s, v);
  //}
}

PVector HSVToRGB(float h, float s, float v)
{
  float r = 0;
  float g = 0;
  float b = 0;
  float epsilon = 0.000001;
  float undefinedHue = -1;

  if (h == 360.0) h = 0;

  if (s < epsilon || h == undefinedHue) {
    // Achromatic case

    r = v;
    g = v;
    b = v;
  } else {
    float f, p, q, t;
    int i;

    if (h > 360 - epsilon) {
      h -= 360;
    }

    h /= 60;
    i = floor(h);
    f = h - i;
    p = v * (1 - s);
    q = v * (1 - (s * f));
    t = v * (1 - (s * (1 - f)));

    switch (i) {
    case 0:
      r = v;
      g = t;
      b = p;
      break;
    case 1:
      r = q;
      g = v;
      b = p;
      break;
    case 2:
      r = p;
      g = v;
      b = t;
      break;
    case 3:
      r = p;
      g = q;
      b = v;
      break;
    case 4:
      r = t;
      g = p;
      b = v;
      break;
    case 5:
      r = v;
      g = p;
      b = q;
      break;
    }
  }
  return new PVector(r, g, b);
}

int binVal(float initVal, float maxVal, int numBins) {
  initVal = initVal / maxVal; //normalize
  return floor(numBins * initVal);
}

PVector RGBToXY(float r, float g, float b) {
  float halfWidth = width/2;
  float halfHeight = height/2;
  float radius = halfWidth;
  PVector hsv = RGBToHSV(r, g, b);

  float x = cos(hsv.x*( PI * 2 )/360 + PI) * hsv.y * radius + halfWidth;
  float y = sin(hsv.x*( PI * 2 )/360 + PI) * hsv.y * radius + halfHeight;
  return new PVector(x, y);
}

void markColorGamut(String imgName, int numSamples, color markColor){
  strokeWeight(3);
  stroke(markColor);
  
  PImage img = loadImage(imgName);
  img.loadPixels();
  for (int i = 0; i < numSamples; i++) {
    int rx = floor(random(img.width));
    int ry = floor(random(img.height));

    color pixelColor = img.get(rx, ry);
    float r = red(pixelColor);
    float g = green(pixelColor);
    float b = blue(pixelColor);
    PVector pos = RGBToXY(r, g, b);
    point(pos.x, pos.y);
  }
}
