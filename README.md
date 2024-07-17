# Alphabet-catching-game-in-assembly
this game is made in assembly and will run when you run .asm file on dosbox. after 10 miss game will automatically end ad your points will be shown on screen.

## Features:
* The game will start when you run your program on DOSBox.
* The box can be moved left when the left arrow key is pressed and right when the right arrow key on the keyboard is pressed.
* Characters A-Z will randomly fall from the top to the bottom of the screen.
* The characters start falling from the top of the screen towards the bottom until they disappear. Please note that the characters appear randomly in the first row and then start falling down. At one time, there will be at least 5 characters falling down with different speeds.
* If any alphabet touches the box, it will disappear, and one point will be added to the score. The score is displayed in the upper right corner of the screen.
* The game is over when the box misses 10 falling alphabets, i.e., your program will terminate, and DOSBox and the command prompt will run normally.



## Game set-up:
#### 1. Downloading:
Download dosbox and everything. if you have dosbox then then download only project.asm file.
#### 2. Dosbox set-up:
Mount your folder in doxbox where you have this project file.

#### 3. Compiling the project:
Run the following command in DosBox:
```
nasm project.asm -o project.com
```

#### 4. Run the game:
Once the compilation is done, write the following commad in Dosbox to start game.
```
project.com
```
* The game will start and you can play

## Controls:
* Use `<` to move towards left
* Use `>` to move towards right


