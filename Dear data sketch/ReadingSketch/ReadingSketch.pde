// Import sound library
import processing.sound.*;

SoundFile tone; // Single sound file
String[] csvLines;
int[] pagesRead;
String[] dates;

int barWidth;
float maxBarHeight;
PImage bookIcon;

void setup() {
  size(1200, 600);

  // Load CSV file
  csvLines = loadStrings("pages_read_data.csv");

  // Load sound file
  tone = new SoundFile(this, "tone.mp3");

  // Initialize arrays
  pagesRead = new int[csvLines.length - 1]; // Exclude header row
  dates = new String[csvLines.length - 1];

  // Parse CSV data
  for (int i = 1; i < csvLines.length; i++) {
    String[] parts = split(csvLines[i], ",");
    dates[i - 1] = parts[0]; // First column is the date
    pagesRead[i - 1] = int(parts[1]); // Second column is pages read
  }

  println(dates); // For debugging
  println(pagesRead);

  barWidth = width / pagesRead.length;
  maxBarHeight = height * 0.8;
  bookIcon = loadImage("book_icon.png"); // Replace with your icon
}

void draw() {
  background(30);
  for (int i = 0; i < pagesRead.length; i++) {
    float barHeight = map(pagesRead[i], 0, 50, 0, maxBarHeight);
    float x = i * barWidth;

    // Set color based on page range
    if (pagesRead[i] == 0) {
      fill(100, 50, 50); // Dark red for no reading
    } else if (pagesRead[i] < 20) {
      fill(150, 150, 255); // Soft blue
    } else if (pagesRead[i] < 40) {
      fill(100, 255, 150); // Soft green
    } else {
      fill(255, 200, 100); // Vibrant orange
    }

    rect(x, height - barHeight, barWidth - 2, barHeight);

    // Draw book icon on days with 0 pages
    if (pagesRead[i] == 0) {
      image(bookIcon, x + barWidth / 4, height - barHeight - 50, barWidth / 2, 50);
    }
  }
}

void mousePressed() {
  // Determine which bar was clicked
  int index = mouseX / barWidth;
  if (index >= 0 && index < pagesRead.length) {
    // Adjust playback speed based on pages read
    float speed = map(pagesRead[index], 0, 50, 0.5, 2.0); // 0.5x to 2.0x speed
    tone.rate(speed);
    tone.play();
  }
}
