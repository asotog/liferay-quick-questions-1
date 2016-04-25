package com.rivetlogic.quickquestions.model;

public class Entry {

	private String name;
	private String message;

	public Entry() {
		// TODO Auto-generated constructor stub
	}

	public Entry(String name, String message) {
		super();
		this.name = name;
		this.message = message;
	}

	public String getName() {
		return name;
	}
	

	public void setName(String name) {
		this.name = name;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

}
