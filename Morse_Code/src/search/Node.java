package search;

public class Node {
	
	private int value;
	private Node left;
	private Node right;
	private Node parent;
	
	public Node(int value) {
		this.value = value;
	}
	
	public int getValue() {
		return this.value;
	}

	public Node getLeft() {
		return this.left;
	}
	
	public Node getRight() {
		return this.right;
	}
	
	public Node getParent() {
		return this.parent;
	}
	
	public void setLeft(Node left) {
		this.left = left;
	}
	
	public void setRight(Node right) {
		this.right = right;
	}
	
	public void setParent(Node parent) {
		this.parent = parent;
	}
}
