# Elm-Interactive-Art

This app was created using Elm and the shapes was rendered using MacCASOutreach's GraphicSVG package.
Create your own animations! [Try it out!](https://mac1xa3.ca/u/bhavsd1/simpleapp.html)

### How to Create your Animation

First, you will be prompted to Main Menu Screen, which will have 2 text fields. The first one is for the angle of the 
rotation and the second one is for the increment of the position of the circles. *Tip: Keep the position increment low for better result.* The text fields already come with a default value, so if you keep it empty, it will use the default value to render the animation

Then click **Start Animation** to begin!

Once in the Animation screen, the circles are going to reach a fixed position and will keep spinning in that place. 
Click anywhere on the screen to change the direction of the rotation and to decrease the position.

If you keep clicking the screen, the circles will reach outside of the fixed position and will make its way inside 
and back to its fixed position.

To make another animation, simply refresh the webpage.

The constant rendering of the circles is possible because of it being added to a list each time and rendering that list with previous circles.


