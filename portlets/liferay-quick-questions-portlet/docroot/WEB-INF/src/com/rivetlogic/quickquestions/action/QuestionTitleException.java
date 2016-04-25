package com.rivetlogic.quickquestions.action;

public class QuestionTitleException extends RuntimeException {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	private String message; 
	
	public QuestionTitleException() {
	}
	
	public QuestionTitleException(String message) {
		super(message);
		this.message = message;
	}
	
	

}
