import processing.sound.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.WeekFields;
import java.util.Locale;

SoundFile tone; // Single sound file
String[] csvLines;
int[] pagesRead;
String[] dates;

int numBooks;
Book[] books;
PFont font;
PImage bookImage; 
color[] weekColours; 

void setup() {
  size(1600, 1000); 

  // Load  files
  csvLines = loadStrings("pages_read_data.csv");

  tone = new SoundFile(this, "sound.mp3");

  bookImage = loadImage("book_icon.png"); 
  
  // Parse CSV data
  numBooks = csvLines.length - 1; 
  pagesRead = new int[numBooks];
  dates = new String[numBooks];

  for (int i = 1; i < csvLines.length; i++) {
    String[] parts = split(csvLines[i], ",");
    dates[i - 1] = parts[0]; 
    pagesRead[i - 1] = int(parts[1]); 
  }

  // Generate week colours
  weekColours = new color[52];
  for (int i = 0; i < weekColours.length; i++) {
    weekColours[i] = color(random(50, 255), random(50, 255), random(50, 255)); 
  }

  books = new Book[numBooks];
  for (int i = 0; i < numBooks; i++) {
    books[i] = new Book(pagesRead[i], dates[i]);
  }

  font = createFont("Arial", 16);
}

void draw() {
  background(30);

  for (Book book : books) {
    book.move();
    book.display();
  }
}

// Adjust playback speed based of sound when mouse is clicked
void mousePressed() {
  for (Book book : books) {
    if (book.isHovered(mouseX, mouseY)) {
      float speed = map(book.pages, 0, 50, 0.5, 2.0);
      tone.rate(speed);
      tone.play();
    }
  }
}

class Book {
  float x, y; 
  float xSpeed, ySpeed; 
  int pages; 
  String date; 
  float scaleFactor; 
  color bookColour; 
  float opacity; 

  Book(int pagesRead, String bookDate) {
    // Random initial positions with margins
    x = random(60, width - 60); 
    y = random(60, height - 60); 
    xSpeed = random(1, 3) * (random(1) > 0.5 ? 1 : -1); 
    ySpeed = random(1, 3) * (random(1) > 0.5 ? 1 : -1); 
    pages = pagesRead;
    date = bookDate;

    // Determine scale factor, opacity and colourbased on pages
    scaleFactor = map(pages, 0, 50, 0.3, 1.5);
    opacity = map(pages, 0, 50, 50, 255); 

    int weekOfYear = getWeekOfYear(bookDate);
    bookColour = weekColours[weekOfYear];
  }

  void move() {
    x += xSpeed;
    y += ySpeed;

    // Bounce off edges using the book's width and height
    if (x < 0 || x > width - 60) xSpeed *= -1;
    if (y < 0 || y > height - 60) ySpeed *= -1;
  }

  void display() {
    // Draw the book icon with scaling and opacity
    tint(bookColour, opacity);  
    image(bookImage, x, y, bookImage.width * scaleFactor, bookImage.height * scaleFactor);

    // Show the date and pages when hovering over a book
    if (isHovered(mouseX, mouseY)) {
      fill(255);
      textFont(font);
      text(date + " (" + pages + " pages)", x, y - 10);
    }
  }

  boolean isHovered(int mx, int my) {
    float imgWidth = bookImage.width * scaleFactor;
    float imgHeight = bookImage.height * scaleFactor;
    return mx > x && mx < x + imgWidth && my > y && my < imgHeight;
  }

  int getWeekOfYear(String bookDate) {
    // Parse the date and determine the week of the year
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    LocalDate localDate = LocalDate.parse(bookDate, formatter);
    WeekFields weekFields = WeekFields.of(Locale.getDefault());
    return localDate.get(weekFields.weekOfWeekBasedYear()) - 1; 
  }
}
