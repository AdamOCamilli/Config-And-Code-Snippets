package search;

import java.util.AbstractQueue;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Queue;

public class Tree {
	Node root;
	LinkedList<Node> adj = new LinkedList<Node>();
	
	public Tree(Node root) {
		this.root = root;
		adj.add(this.root);
	}
	
	public void BFS(Node start) {
		ArrayList<Boolean> visited = new ArrayList<Boolean> ();
		Queue<Node> queue = new LinkedList<Node>();
		
		queue.add(start);
		while (queue.size() > 0) {
			// Dequeue and print
			Node temp = queue.poll();
			System.out.print(temp + " ");
			
			
		}
		
	}
}
