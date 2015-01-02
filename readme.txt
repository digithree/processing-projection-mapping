Projection Mapping

--- Summary ---

An example of 2D polygon based projection mapping. Refer to the instructions
below and some on screen instructions for usage.

There are several steps to using this program. They are:
 1 - Create polygons with vertices
 2 - Adjust vertices
 3 - Main animation state

In the first step, you click on the screen to create vertices and use already
created vertices to define the vertices of a polygon. This polygon must have at
least three vertices.

When the mouse pointer is close to a vertex, it will be highlighted and expand
slightly. You should reuse vertices when you are creating a mesh of polygons.

In the second step you can adjust vertices. Keep this in mind when you are
creating the vertices in the first step, you will have a chance to fine tune
their location now.

Finally, the animation begins.

NOTE ON ANIMATION

The animation style is a looping beat. Each polygon's update method is supplied
a value called normTime which corresponds to the current time in the animation loop
and is number between 0.f and 1.f. 


Written by Simon Kenny 2015