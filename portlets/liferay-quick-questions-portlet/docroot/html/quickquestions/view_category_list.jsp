<%@include file="/html/quickquestions/init.jsp" %>

	<portlet:renderURL var="addCategoryURL">
		<portlet:param name="targetPage" value="view_main"/>
		<portlet:param name="topLink" value="categories"/>
		<portlet:param name="subtargetPage" value="edit_category"/>
		<portlet:param name="mvcPath" value="/html/quickquestions/view.jsp"></portlet:param>
	</portlet:renderURL>
	
	<aui:button value="Add Category" onClick="<%=addCategoryURL%>" />
	
	<%
	long categoryId = 0;//MBUtil.getCategoryId(request, category);
	int categoriesCount = MBCategoryServiceUtil.getCategoriesCount(scopeGroupId, categoryId, WorkflowConstants.STATUS_APPROVED);
	PortletURL portletURL = renderResponse.createRenderURL();
	%>
		<liferay-ui:search-container
				curParam="cur12"
				deltaConfigurable="<%= false %>"
				headerNames="category,categories,threads,posts"
				iteratorURL="<%= portletURL %>"
				total="<%= categoriesCount %>"
			>
				<liferay-ui:search-container-results
					results="<%= MBCategoryServiceUtil.getCategories(scopeGroupId, categoryId, WorkflowConstants.STATUS_APPROVED, searchContainer.getStart(), searchContainer.getEnd()) %>"
				/>

				<liferay-ui:search-container-row
					className="com.liferay.portlet.messageboards.model.MBCategory"
					escapedModel="<%= true %>"
					keyProperty="categoryId"
					modelVar="curCategory"
				>
					<liferay-ui:search-container-row-parameter name="categorySubscriptionClassPKs" value="<%= categorySubscriptionClassPKs %>" />

					<portlet:renderURL  var="rowURL" >
						<portlet:param name="struts_action" value="/message_boards/view" />
						<portlet:param name="mbCategoryId" value="<%= String.valueOf(curCategory.getCategoryId()) %>" />
					</portlet:renderURL>
					<liferay-ui:search-container-column-text
							buffer="buffer"
							name="category[message-board]"
						>

								<%
								buffer.append("<span class=\"category-title\">");
								buffer.append(curCategory.getName());
								buffer.append("</span>");
							
								if (Validator.isNotNull(curCategory.getDescription())) {
									buffer.append("<div class=\"category-description\">");
									buffer.append(curCategory.getDescription());
									buffer.append("</div>");
								}
								%>
					
					</liferay-ui:search-container-column-text>
					<liferay-ui:search-container-column-jsp path="/html/quickquestions/category_action.jsp"></liferay-ui:search-container-column-jsp>
					</liferay-ui:search-container-row>
					
									<liferay-ui:search-iterator />
								</liferay-ui:search-container>
