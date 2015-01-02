/*
 * AnimatedPolygon
 *
 * Base class for an animated polygon. It's just the generic building block
 * to build a standardised animated polygon.
 *
 * Note that vertices are stored in a global array and the index of these
 * vertices are refered to in this class. Is allows for reuse and global
 * modification of vertices.
 */
import java.util.List;
import java.util.ArrayList;
import processing.core.*;

public class AnimatedPolygon {
	// variables visible to all subclasses
	protected List<PVector> globalVertices;
	protected List<Integer> vertices = new ArrayList<Integer>();

	// variables for this class only
	private float colStart, colVector;
	private int col;


	public AnimatedPolygon() {
		// do nothing
	}

	// copy constructor
	public AnimatedPolygon(AnimatedPolygon polygon) {
		vertices = polygon.getAllVertices();
	}

	// --- Protected methods, cannot be overriden but are visible to subclasses
	protected boolean addVertex(int idx) {
		if( !vertices.contains(idx) ) {
			vertices.add(idx);
			return true;
		}
		return false;
	}

	protected List<Integer> getAllVertices() {
		return vertices;
	}

	protected int getLastVertex() {
		if( !vertices.isEmpty() ) {
			return vertices.get(vertices.size()-1);
		}
		return -1;
	}

	protected int getNumVertices() {
		return vertices.size();
	}


	// --- Use ethods, should be overriden in subclasses
	/*
	 * init
	 *
	 * initialise polygon. Should be called when created
	 *
	 * NOTE! don't forget to set globalVertices
	 */
	public void init(List<PVector> globalVertices) {
		// set globalVertices
		this.globalVertices = globalVertices;
		// init
		colStart = 140;
		colVector = -100;
		col = (int)colStart;
	}

	/*
	 * update
	 *
	 * args: normTime - normalized time, between 0.f and 1.f inclusive
	 *
	 * usage: Use deltaTime to animate events. Typically animation changes
	 *    will be scaled by normTime to get the change in animation.
	 */
	public void update(float normTime) {
		// EXAMPLE ANIMATION
		// change colour
		col = (int)(colStart + (normTime * colVector));
		if( col < 0 ) {
			col = 0;
		} else if( col > 255 ) {
			col = 255;
		}
	}


	/*
	 * draw
	 *
	 * args: Papplet is the Processing instance. We use this so that we can serialize
	 *    and deserialize this object
	 *
	 * no modifcations to variables should be made in the draw call, only drawing
	 * the polygon as required.
	 */
	public void draw(PApplet papplet) {
		// EXAMPLE
		// set style
		papplet.pushStyle();
		papplet.stroke(128,128,255);
		papplet.strokeWeight(3);
		papplet.fill(col);
		if( !vertices.isEmpty() ) {
			papplet.beginShape(); // use default state, filled in polygon
			for( Integer idx : vertices ) {
				PVector v = globalVertices.get(idx.intValue());
				papplet.vertex(v.x, v.y);
			}
			papplet.endShape(papplet.CLOSE); // CLOSE means that it automatically adds the first vertex again to close the shape
		}
		papplet.popStyle();
	}
}