/*
 * ProjectionMapping - v0.1
 *
 * An example of 2D polygon based projection mapping. Refer to the instructions
 * below and some on screen instructions for usage.
 *
 *
 * There are several steps to using this program. They are:
 * 1 - Create polygons with vertices
 * 2 - Adjust vertices
 * 3 - Main animation state
 *
 * In the first step, you click on the screen to create vertices and use already
 * created vertices to define the vertices of a polygon. This polygon must have at
 * least three vertices.
 *
 * When the mouse pointer is close to a vertex, it will be highlighted and expand
 * slightly. You should reuse vertices when you are creating a mesh of polygons.
 *
 * In the second step you can adjust vertices. Keep this in mind when you are
 * creating the vertices in the first step, you will have a chance to fine tune
 * their location now.
 *
 * Finally, the animation begins.
 *
 *
 * NOTE ON ANIMATION
 *
 * The animation style is a looping beat. Each polygon's update method is supplied
 * a value called normTime which corresponds to the current time in the animation loop
 * and is number between 0.f and 1.f. 
 */

import java.util.List;
import java.util.ArrayList;

// --- Constants
// gfx
private final int WIDTH = 800;
private final int HEIGHT = 600;
private final int TEXT_SIZE = 13;
private final int TEXT_PADDING = 5;
// timer
private float TIMER_BPM = 70.f; // set average normal human heart beats per minute (BPM)
// other
private final int MIN_VERTEX_HIGHLIGHT_DIST = 15;
private final int VERTEX_SHOW_SIZE = 15;

// --- State engine
private final int STATE_SET_VERTICES = 0;
private final int STATE_ADJUST_VERTICES = 1;
private final int STATE_MAIN = 2;

private int currentState = STATE_SET_VERTICES;

// --- Shape objects
// vertices
private List<PVector> globalVertices = new ArrayList<PVector>();
private int currentSelectedVertex = -1;
private boolean draggingVertex = false;
// polygons
private List<AnimatedPolygon> polygons = new ArrayList<AnimatedPolygon>();
private AnimatedPolygon tempPolygon = null; // used for interactive polygon creation

// --- Misc global variables
// timer
private float lastTime = 0.f;
private float normTimeCounter = 0.f;
private float timerLengthInSeconds = 60.f / TIMER_BPM; //use this calculation if you change the BPM
// on screen text
private boolean displayText = true;


// --- Support methods
private float getTime() {
	return (float)millis()/1000.f;
}


void setup() {
	// screen setup
	size(WIDTH, HEIGHT);
	// text setup
	textSize(TEXT_SIZE);
	textAlign(LEFT);
	// stroke setup
	strokeCap(ROUND);
	strokeJoin(ROUND);

	// set first time
	lastTime = getTime();
}


void draw() {
	// Processing doesn't split drawing and updating into two different
	// methods like most other frameworks so let's do that anyway to
	// make this code more portable

	// update
	update();

	// actual draw
	background(0);
	drawPolygons();
	drawOverlay();
}

void update() {
	// get time difference from last frame and calculate normialized time
	float thisTime = getTime();
	normTimeCounter += (thisTime - lastTime);
	if( normTimeCounter > timerLengthInSeconds ) {
		normTimeCounter -= timerLengthInSeconds;
	}
	float normTime = normTimeCounter / timerLengthInSeconds;
	// do state dependent updates and tasks
	if( currentState == STATE_SET_VERTICES || currentState == STATE_ADJUST_VERTICES ) {
		// mouse handling is in mouseClicked() method
		// key handling is in keyPressed() method

		// vertex selection
		if( !draggingVertex ) {
			currentSelectedVertex = -1;
			int count = 0;
			for( PVector v : globalVertices ) {
				if( dist(mouseX, mouseY, v.x, v.y) < MIN_VERTEX_HIGHLIGHT_DIST ) {
					currentSelectedVertex = count;
					break;
				}
				count++;
			}
		} else {
			PVector v = globalVertices.get(currentSelectedVertex);
			v.x = mouseX;
			v.y = mouseY;
		}
	}
	// update polygons
	for( AnimatedPolygon polygon : polygons ) {
		polygon.update(normTime);
	}
	if( tempPolygon != null ) {
		tempPolygon.update(normTime);
	}
	// update time
	lastTime = thisTime;
}

void mouseClicked() {
	if( currentState == STATE_SET_VERTICES ) {
		// HANDLE MOUSE INPUT
		//   GET VERTEX IDX
		// if the mouse click is close enough to a previously create vertex then use that,
		// otherwise create a new vertex
		int idx = -1;
		if( currentSelectedVertex != -1 ) {
			// use previously created vertex
			idx = currentSelectedVertex;
		} else {
			// create new vertex
			idx = globalVertices.size();
			globalVertices.add(new PVector(mouseX,mouseY));
		}
		// ADD VERTEX IDX TO POLYGON
		if( tempPolygon == null ) {
			// first click of polygon
			tempPolygon = new AnimatedPolygon(); // TODO : change this for different polygon subclass
			tempPolygon.init(globalVertices);
		}
		// add to polygon
		tempPolygon.addVertex(idx);
	}
}

void mousePressed() {
	if( currentState == STATE_ADJUST_VERTICES ) {
		if( currentSelectedVertex != -1 && !draggingVertex ) {
			draggingVertex = true;
		}
	}
}

void mouseReleased() {
	if( currentState == STATE_ADJUST_VERTICES && draggingVertex ) {
		draggingVertex = false;
	}
}

void keyPressed() {
	if( currentState == STATE_SET_VERTICES ) {
		if( key == 'x' || key == 'X' ) {
			// make sure we can add the polygon. it needs to exist
			// and have at least 3 vertices
			boolean acceptPolygon = false;
			if( tempPolygon != null ) {
				if( tempPolygon.getNumVertices() >= 3 ) {
					acceptPolygon = true;
				}
			}
			if( acceptPolygon ) {
				// add to list
				polygons.add(tempPolygon);
				tempPolygon = null;
			}
		} else if( key == 'z' || key == 'Z' ) {
			// exit this state
			currentState = STATE_ADJUST_VERTICES;
			currentSelectedVertex = -1;
		}
	} else if( currentState == STATE_ADJUST_VERTICES ) {
		if( key == 'x' || key == 'X' ) {
			// **** VERY IMPORTANT ***
			// Migrate polygons from default polygon to whatever one you want.
			// In this example I'm using LineAnimatedPolygon.
			// All AnimatedPolygon subclasses have a copy constructor to make
			//   this easy.
			List<AnimatedPolygon> newPolygonList = new ArrayList<AnimatedPolygon>();
			for( AnimatedPolygon polygon : polygons ) {
				AnimatedPolygon newPolygon = (AnimatedPolygon)new LineAnimatedPolygon(polygon);
				newPolygon.init(globalVertices);
				newPolygonList.add(newPolygon);
			}
			polygons = newPolygonList;
			// change state
			currentState = STATE_MAIN;
		}
	} else if( currentState == STATE_MAIN ) {
		if( key == 'd' || key == 'D' ) {
			displayText = !displayText;
		}
	}
}

void drawPolygons() {
	for( AnimatedPolygon polygon : polygons ) {
		polygon.draw(this);
	}
	if( tempPolygon != null ) {
		tempPolygon.draw(this);
	}
}

void drawOverlay() {
	// vertices
	if( currentState == STATE_SET_VERTICES || currentState == STATE_ADJUST_VERTICES ) {
		pushStyle();
		noStroke();
		int count = 0;
		for( PVector v : globalVertices ) {
			if( count != currentSelectedVertex ) {
				fill(0,255,0);
				ellipse(v.x, v.y, VERTEX_SHOW_SIZE, VERTEX_SHOW_SIZE);
			} else {
				fill(128,255,128);
				ellipse(v.x, v.y, VERTEX_SHOW_SIZE*2, VERTEX_SHOW_SIZE*2);
			}
			count++;
		}
		popStyle();
	}
	// joining line
	if( currentState == STATE_SET_VERTICES ) {
		if( tempPolygon != null ) {
			// get last vertex
			int idx = tempPolygon.getLastVertex();
			if( idx != -1 ) { // if there is at least one vertex
				// draw connecting line between last vertex and mouse
				pushStyle();
				noFill();
				stroke(255,0,0);
				line(globalVertices.get(idx).x, globalVertices.get(idx).y, mouseX, mouseY);
				popStyle();
			}
		}
	}
	// text overlay
	pushStyle();
	fill(255);
	if( currentState == STATE_SET_VERTICES ) {
		// top of screen
		text("State: Create polygons", TEXT_PADDING*2, TEXT_PADDING + ((TEXT_SIZE+TEXT_PADDING)*1) );
		if( tempPolygon == null ) {
			text("Polygons: "+polygons.size()+" / current: none", TEXT_PADDING*2, TEXT_PADDING + ((TEXT_SIZE+TEXT_PADDING)*2) );
		} else {
			text("Polygons: "+polygons.size()+" / current: "+tempPolygon.getNumVertices()+" vertices", TEXT_PADDING*2, TEXT_PADDING + ((TEXT_SIZE+TEXT_PADDING)*2) );
		}
		// bottom of screen
		text("Click with mouse to set next polygon vertex", TEXT_PADDING*2, height - TEXT_PADDING - ((TEXT_SIZE+TEXT_PADDING)*2) );
		text("Press 'x' to start next polygon, 'z' when finished", TEXT_PADDING*2, height - TEXT_PADDING - ((TEXT_SIZE+TEXT_PADDING)*1) );
	} else if( currentState == STATE_ADJUST_VERTICES ) {
		// top of screen
		text("State: Adjust vertices", TEXT_PADDING*2, TEXT_PADDING + ((TEXT_SIZE+TEXT_PADDING)*1) );
		// bottom of screen
		text("Click and drag a vertex with the mouse to adjust it", TEXT_PADDING*2, height - TEXT_PADDING - ((TEXT_SIZE+TEXT_PADDING)*2) );
		text("Press 'x' when finished", TEXT_PADDING*2, height - TEXT_PADDING - ((TEXT_SIZE+TEXT_PADDING)*1) );
	}	else if( currentState == STATE_MAIN && displayText ) {
		// top of screen
		text("State: Main", TEXT_PADDING*2, TEXT_PADDING + ((TEXT_SIZE+TEXT_PADDING)*1) );
		// bottom of screen
		text("Press 'd' to toggle on screen text, Esc to exit", TEXT_PADDING*2, height - TEXT_PADDING - ((TEXT_SIZE+TEXT_PADDING)*1) );
	}
	popStyle();
}