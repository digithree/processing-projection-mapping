/*
 * LineAnimatedPolygon
 *
 * Animates the bounding lines of the polygon moving inwards the center
 */
import java.util.List;
import java.util.ArrayList;
import processing.core.*;

public class LineAnimatedPolygon extends AnimatedPolygon {
	// variables for this instance of the class only
	private PVector center;
	private PVector []moveVector;
	private PVector []currentVertices;

	// CONSTRUCTORS - these need to be here exactly like this in every subclass
	LineAnimatedPolygon() {
		super();
	}

	// copy constructor
	public LineAnimatedPolygon(AnimatedPolygon polygon) {
		super(polygon);
	}

	// --- Overriden methods (see superclass for more information)
	public void init(List<PVector> globalVertices) {
		// set globalVertices
		this.globalVertices = globalVertices;
		// init

		// calculate center and point movement vectors for each vertex
		// center is calculated by average of all vertices
		center = new PVector();
		for( Integer idx : vertices ) {
			PVector v = globalVertices.get(idx.intValue());
			center.add(v.x, v.y, 0.f);
		}
		center.div(vertices.size());
		// vector is full distance from vertex to center with direction
		moveVector = new PVector[vertices.size()];
		currentVertices = new PVector[vertices.size()];
		int count = 0;
		for( Integer idx : vertices ) {
			PVector v = globalVertices.get(idx.intValue());
			currentVertices[count] = new PVector(v.x, v.y);
			moveVector[count] = new PVector(center.x, center.y);
			moveVector[count].sub(v.x, v.y, 0.f);
			count++;
		}
	}

	public void update(float normTime) {
		int count = 0;
		for( Integer idx : vertices ) {
			PVector v = globalVertices.get(idx.intValue());
			currentVertices[count] = new PVector(
				v.x + (moveVector[count].x * normTime),
				v.y + (moveVector[count].y * normTime) );
			count++;
		}
	}

	public void draw(PApplet papplet) {
		papplet.pushStyle();
		papplet.stroke(255,255,100);
		papplet.strokeWeight(5);
		papplet.noFill();
		if( !vertices.isEmpty() ) {
			papplet.beginShape(); // use default state, filled in polygon
			for( PVector v : currentVertices ) {
				papplet.vertex(v.x, v.y);
			}
			papplet.endShape(papplet.CLOSE); // CLOSE means that it automatically adds the first vertex again to close the shape
		}
		papplet.popStyle();
	}
}
