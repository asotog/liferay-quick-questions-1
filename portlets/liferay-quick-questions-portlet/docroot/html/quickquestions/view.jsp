<%@include file="/html/quickquestions/init.jsp" %>

<%
	PortletURL currentURL = renderResponse.createRenderURL();
	int categoryId = 0;
	
	List<MBCategory> categories = MBCategoryServiceUtil.getCategories(scopeGroupId);
	
	request.setAttribute("categories", categories);
	
	List<Long> catIdList = new ArrayList<Long>(categories.size());
	catIdList.add(0L);
	
	for(MBCategory cat : categories){
		catIdList.add(cat.getCategoryId());
	}

%>


<liferay-ui:success key="message-delete-success" message="Question deleted successfully"/>
<liferay-ui:success key="message-add-success" message="Question added successfully"/>
<liferay-ui:error exception="<%= RequiredMessageException.class %>" message="you-cannot-delete-a-root-message-that-has-more-than-one-immediate-reply" />
<liferay-ui:error key="title-is-required" message="Title is Required" />
<liferay-ui:error key="duplicate-file" message="Please enter a unique document name." />
<aui:row>
	<aui:col span="3">
	<%@ include file="/html/quickquestions/latest_questions_listing.jspf" %>
	<div id="questions" class="questions-list">
		<c:if test="<%=MBCategoryPermission.contains(permissionChecker, scopeGroupId, categoryId, ActionKeys.ADD_MESSAGE)%>">
		<div class="">
		<portlet:renderURL var="editQuestionURL">
			<portlet:param name="targetPage" value="edit_question"></portlet:param>
			<portlet:param name="isNew" value="true"/>
		</portlet:renderURL>
		<aui:button
        value="Ask a question"
        onClick="${editQuestionURL}" cssClass="btn-primary btn-main listing-btn" /> <%--<%= editQuestionURL.toString() %> --%>
        </div>
		</c:if>
		<div class="">
		<portlet:renderURL var="viewAllURL">
			<portlet:param name="targetPage" value="view_main"></portlet:param>
			<portlet:param name="messageId" value="0"></portlet:param>
			<portlet:param name="mvcPath" value="/html/quickquestions/view.jsp"></portlet:param>
		</portlet:renderURL>
		<aui:button 
        value="View all" 
        onClick="${viewAllURL}" cssClass="btn-main listing-btn" /> <%--<%= viewAllURL.toString() %> --%>
        </div>
      </div>
	</aui:col>
	<aui:col span="9">
		<div class="margin-top-21">
			<jsp:include page="/html/quickquestions/${not empty targetPage ? targetPage : 'view_main'}.jsp" />
		</div>
	</aui:col>
</aui:row>

