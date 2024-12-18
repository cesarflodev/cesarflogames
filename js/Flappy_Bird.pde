import ddf.minim.*;  // Import Minim library

PImage goku, bg, bg2, topPipe, botPipe; // Background, Goku, Pipes
Minim minim;  // Declare a Minim object
AudioPlayer flapSound;  // Declare a variable for the sound
float bgx1, bgx2, bgSpeed = 2;  // Background movement
float bgWidth; // Background width
int gokuX, gokuY, Vy, g; // Goku position and gravity variables
int pipeGap = 200, pipeWidth = 200, pipeSpeed = 3; // Pipe settings
ArrayList<Pipe> pipes; // List to hold pipes
int gameState = 0, score = 0, highScore = 0; // Game state and scoring
int frameTime = 0; // Frame time profiling

void setup() {
  size(800, 750);  // Set canvas size to 1080p (1920x1080)

  goku = loadImage("goku.png");  // Load Goku image
  bg = loadImage("city.png");    // Load city background image
  bg2 = loadImage("city2.png");  // Load second background image
  topPipe = loadImage("toppipe.png");
  botPipe = loadImage("botpipe.png");

  minim = new Minim(this);  // Initialize Minim
  flapSound = minim.loadFile("flap.mp3");  // Load the flap sound

  bgWidth = bg.width;  // Save the width of the background
  bgx1 = 0;             // Start position for first background
  bgx2 = bgWidth;       // Start position for second background

  gokuX = 100;          // Set Goku's horizontal position
  gokuY = height / 2;   // Set Goku's initial vertical position
  Vy = 0;               // Initial vertical speed
  g = 1;                // Gravity constant

  pipes = new ArrayList<Pipe>();  // Initialize pipe list

  // Create the initial set of pipes
  for (int i = 0; i < 3; i++) {
    pipes.add(new Pipe(width + i * (width / 3), random(200, height - pipeGap - 200)));
  }
}

void draw() {
  long startTime = millis();  // Start time for profiling
  
  if (gameState == 0) {
    background(0);  // Clear the screen

    // Draw the background images (scrolling effect)
    image(bg, bgx1, 0);      // First part of the background
    image(bg2, bgx2, 0);     // Second part of the background
    
    // Move the backgrounds to the left
    bgx1 -= bgSpeed;
    bgx2 -= bgSpeed;

    // Seamless loop logic for background scrolling
    if (bgx1 <= -bgWidth) {
      bgx1 = bgx2 + bgWidth;  // Place the first background after the second one
    }
    
    if (bgx2 <= -bgWidth) {
      bgx2 = bgx1 + bgWidth;  // Place the second background after the first one
    }

    // Update and draw pipes
    for (int i = pipes.size() - 1; i >= 0; i--) {
      Pipe p = pipes.get(i);
      p.update();
      p.display();

      // Check for passing pipes (and increase score)
      if (p.x + pipeWidth < gokuX && !p.isScored) {
        score++;  // Increment score when Goku passes a pipe
        p.isScored = true;  // Mark this pipe as scored
      }

      // Reset pipes when they go off-screen
      if (p.x + pipeWidth < 0) {
        p.resetPosition();
      }
    }

    // Draw Goku
    image(goku, gokuX, gokuY - goku.height / 2);

    // Apply gravity to Goku
    gokuY += Vy;
    Vy += g;  // Apply gravity effect

    // Prevent Goku from going below the ground (screen bottom)
    if (gokuY > height - goku.height) {
      gokuY = height - goku.height;
    }

    // Prevent Goku from going above the top of the screen
    if (gokuY < 0) {
      gokuY = 0;
    }

    // Check for collisions with pipes
    for (int i = 0; i < pipes.size(); i++) {
      Pipe p = pipes.get(i);
      if (gokuX > p.x && gokuX < p.x + pipeWidth) {
        if (!(gokuY > p.topHeight && gokuY < p.topHeight + pipeGap)) {
          gameState = 1; // Game over on collision
          // Update high score if the current score is higher
          if (score > highScore) {
            highScore = score;
          }
        }
      }
    }

    // Display score
    fill(255);
    textSize(30);
    textAlign(LEFT, TOP);
    text("Score: " + score, 20, 20);

    // Display high score
    textAlign(RIGHT, TOP);
    text("High Score: " + highScore, width - 20, 20);

  } else {
    // Game over screen
    fill(255, 0, 0);
    textSize(50);
    textAlign(CENTER, CENTER);
    text("Game Over!", width / 2, height / 2);
    text("Click to Restart", width / 2, height / 2 + 60);

    // Display the final score on game over screen
    fill(255);
    textSize(30);
    textAlign(CENTER, TOP);
    text("Final Score: " + score, width / 2, height / 2 + 120);
  }

  // End time for profiling
  long endTime = millis();
  frameTime = (int)(endTime - startTime);
  println("Frame time: " + frameTime + " ms");
}

// Handle mouse press to make Goku jump
void mousePressed() {
  if (gameState == 0) {
    Vy = -10;  // Make Goku jump

    // Restart the flap sound from the beginning
    flapSound.rewind();  // Rewind the sound to the beginning
    flapSound.play();    // Play the sound when Goku jumps
  } else {
    // Restart the game if it's over
    gameState = 0;
    gokuY = height / 2;
    pipes.clear();
    for (int i = 0; i < 3; i++) {
      pipes.add(new Pipe(width + i * (width / 3), random(200, height - pipeGap - 200)));
    }
    score = 0;
  }
}


// Pipe class for pipe logic
class Pipe {
  float x, topHeight, bottomHeight;
  boolean isScored = false;  // Flag to check if the pipe has been scored

  // Constructor to initialize pipe position and height
  Pipe(float startX, float startY) {
    x = startX;
    topHeight = startY;
    bottomHeight = height - startY - pipeGap;
  }

  // Update pipe position
  void update() {
    x -= pipeSpeed;  // Move pipe to the left
  }

  // Draw the pipe to the screen
  void display() {
    image(topPipe, x, 0, pipeWidth, topHeight);  // Draw the top pipe
    image(botPipe, x, height - bottomHeight, pipeWidth, bottomHeight);  // Draw the bottom pipe
  }

  // Reset pipe position when it goes off-screen
  void resetPosition() {
    x = width + 50;  // Reset pipe position off-screen
    topHeight = random(200, height - pipeGap - 200);
    bottomHeight = height - topHeight - pipeGap;
    isScored = false;  // Reset the scored flag
  }
}
