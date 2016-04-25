package com.rivetlogic.quickquestions.action.util;

import com.liferay.portal.kernel.util.OrderByComparator;
import com.liferay.portlet.messageboards.model.MBMessage;

public class TitleComparator extends OrderByComparator{


	 public static String ORDER_BY_ASC = "status ASC";

	 public static String ORDER_BY_DESC = "status DESC";
	 
	 
	  public TitleComparator() 
	  {
	   this(false);
	  }

	  public TitleComparator(boolean asc) {
	   _asc = asc;
	  }


	 
	 public int compare(Object obj1, Object obj2) {
	   
		 MBMessage message1 = (MBMessage) obj1;
		 MBMessage message2 = (MBMessage) obj2;
		 
	   int value = message1.getSubject().toLowerCase().compareTo(message2.getSubject().toLowerCase());
	 
	   if(_asc) 
	   {
	    return value;
	   } else 
	   {
	    return -value;
	   }
	    
	 }
	 
	 
	 public String getOrderBy() {
	  
	  if (_asc) {
	   return ORDER_BY_ASC;
	  } 
	  else {
	   return ORDER_BY_DESC;
	  }
	  }

	 private boolean _asc;

	}