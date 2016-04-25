<%@page import="com.rivetlogic.quickquestions.action.util.CustomComparatorUtil"%>
<%@page import="com.liferay.portlet.PortalPreferences"%>
<%@page import="com.liferay.portlet.PortletPreferencesFactoryUtil"%>
<%@page import="com.liferay.portal.model.Subscription"%>
<%@page
	import="com.liferay.portlet.messageboards.service.MBCategoryServiceUtil"%>
<%@page
	import="com.liferay.portlet.messageboards.service.persistence.MBThreadUtil"%>
<%@page
	import="com.liferay.portlet.messageboards.service.persistence.MBCategoryUtil"%>
<%@page
	import="com.liferay.portal.kernel.dao.orm.RestrictionsFactoryUtil"%>
<%@page
	import="com.liferay.portal.kernel.dao.orm.Disjunction"%>
<%@page
	import="com.liferay.portal.kernel.dao.orm.DynamicQueryFactoryUtil"%>
<%@page import="com.liferay.portal.kernel.dao.orm.DynamicQuery"%>
<%@include file="/html/quickquestions/init.jsp"%>

	<%
	
		PortletURL portletURL = renderResponse.createRenderURL();
		
		boolean isSearch = ParamUtil.getBoolean(renderRequest, "isSearch");
		String title = ParamUtil.getString(renderRequest, "title");
		long[]	categoryIds = ParamUtil.getLongValues(renderRequest, "categories");
		String topLink = ParamUtil.getString(request, "topLink", "all");
		
		long groupThreadsUserId = 0;
		
		String emptyResultsMessage = null;
		
		/* PortalPreferences portalPrefs = PortletPreferencesFactoryUtil.getPortalPreferences(request); 
		String sortByCol = ParamUtil.getString(request, "orderByCol"); 
		String sortByType = ParamUtil.getString(request, "orderByType"); 
		System.out.println(sortByCol+" "+sortByType);
		   
		if (Validator.isNotNull(sortByCol ) && Validator.isNotNull(sortByType )) { 

		portalPrefs.setValue(renderResponse.getNamespace(), "sort-by-col", sortByCol); 
		portalPrefs.setValue(renderResponse.getNamespace(), "sort-by-type", sortByCol); 

		} else { 

		sortByCol = portalPrefs.getValue(renderResponse.getNamespace(), "sort-by-col", "First Name");
		sortByType = portalPrefs.getValue(renderResponse.getNamespace(), "sort-by-type ", "asc");   
		} */

		if (topLink.equals("my-posts")) {
			emptyResultsMessage = "you-do-not-have-any-questions";
		}
		else if (topLink.equals("my-subscriptions")) {
			emptyResultsMessage = "you-are-not-subscribed-to-any-questions";
		}else if(topLink.equals("all")){
			emptyResultsMessage = "no-questions-found";
		}
		
		
		
		if ((topLink.equals("my-posts") || topLink.equals("my-subscriptions")) && themeDisplay.isSignedIn()) {
			groupThreadsUserId = user.getUserId();
		}

		if (groupThreadsUserId > 0) {
			portletURL.setParameter("groupThreadsUserId", String.valueOf(groupThreadsUserId));
		}

			
			DynamicQuery registered = DynamicQueryFactoryUtil.forClass(MBThread.class, "thread");
			registered.add(PropertyFactoryUtil.forName("thread.question").eq(
					Boolean.TRUE));
			registered.add(PropertyFactoryUtil.forName("thread.groupId").eq(
					scopeGroupId));
			
			/* if(Validator.isNotNull(sortByCol) && Validator.isNotNull(sortByType)){
				StringBuffer queryHead = new StringBuffer("thread.message.");
				if(sortByType.equals("asc")){
					registered.addOrder(PropertyFactoryUtil.forName(queryHead.append(sortByCol).toString()).asc());
				}else{
					registered.addOrder(PropertyFactoryUtil.forName(queryHead.append(sortByCol).toString()).desc());
				}
			}else{ */
				registered.addOrder(PropertyFactoryUtil.forName("thread.lastPostDate").desc());
				
			/* }
			 */
				List<MBCategory> categories = MBCategoryServiceUtil
							.getCategories(scopeGroupId);
			
			if(isSearch){
				
				DynamicQuery messagesWithTitle = DynamicQueryFactoryUtil.forClass(MBMessage.class, "message");
				messagesWithTitle.setProjection(PropertyFactoryUtil.forName("message.threadId"));
				
				if(title.trim().length() > 0) {
				    Disjunction or = RestrictionsFactoryUtil.disjunction();
				    for(String keyword : title.split(" ")) {
				        or.add(RestrictionsFactoryUtil.ilike("message.subject", String.format("%%%s%%", keyword)));
				    }
				    messagesWithTitle.add(or);
				}
				
				if(categoryIds.length > 0)
					messagesWithTitle.add(PropertyFactoryUtil.forName("message.categoryId").in(categoryIds));
				if(topLink.equals("my-posts"))
					messagesWithTitle.add(PropertyFactoryUtil.forName("message.userId").eq(groupThreadsUserId));
				
				messagesWithTitle.add(PropertyFactoryUtil.forName("message.groupId").eq(scopeGroupId));
				List ids = MBMessageLocalServiceUtil.dynamicQuery(messagesWithTitle);
				if(ids.isEmpty()) {
				    ids = Arrays.asList(-1L);
				}
				registered.add(PropertyFactoryUtil.forName("thread.threadId").in(ids));
			}else{
				List<Long> catIdList = new ArrayList<Long>(categories.size());
				catIdList.add(new Long(0));
				for (MBCategory cat : categories) {
					catIdList.add(cat.getCategoryId());
				}
				registered.add(PropertyFactoryUtil.forName("thread.categoryId").in(
						catIdList));
					
			}
%>

<liferay-ui:panel-container>

	<liferay-ui:panel title="questions" extended="true" persistState="true">
		
		<%@include file="/html/quickquestions/top_links.jspf" %>
		
		<%portletURL.setParameter("topLink", topLink);
			String subtargetPage = request.getParameter("subtargetPage");
		  portletURL.setParameter("subtargetPage", (subtargetPage != null ? subtargetPage : "view_category_list"));
		%>
		<%if(!topLink.equals("my-posts") && !topLink.equals("categories")){
		%>
		<aui:form action="<%=portletURL %>">
			<aui:fieldset>
				<aui:field-wrapper>
					<aui:input type="text" name="title" value="<%= title %>" placeholder="Search by Title"/>
				</aui:field-wrapper>
				<aui:field-wrapper label="categories">
					<select name="<%=renderResponse.getNamespace()%>categories" multiple="true" class="choosen" data-placeholder="Select Categories">
						<option value="0" <%= ArrayUtil.contains(categoryIds, 0) ? "selected" : StringPool.BLANK %>>Default Category</option>
						<% for(MBCategory category : categories){ 
								if(!category.isInTrash() && !category.isInactive()){
						%>
						<option value="<%=category.getCategoryId() %>" <%= ArrayUtil.contains(categoryIds, category.getCategoryId()) ? "selected" : StringPool.BLANK %>><%=category.getName()%></option>
						<%
								}
							}
						%>
					</select>
				</aui:field-wrapper>
				<%
					PortletURL clearURL = renderResponse.createRenderURL();
					clearURL.setParameter("topLink", "all");
					clearURL.setParameter("target", "view_main");
					clearURL.setParameter("subtargetPage", "view_category_list");
					clearURL.setParameter("topLink", topLink);
				%>
				<aui:button-row>
					<aui:button value="search" type="submit"/>
					<aui:button href="<%=clearURL.toString()%>" value="clear"/>
				</aui:button-row>
				
				<aui:input name="isSearch" value="true" type="hidden"></aui:input>
			</aui:fieldset>
		</aui:form>
		<%} %>
	
	
		<c:if test='<%=!topLink.equals("categories") %>'>
	
				<liferay-ui:search-container curParam="cur3"
						emptyResultsMessage="<%=emptyResultsMessage%>" 
						iteratorURL="<%=portletURL%>" delta="5" >   <%-- orderByCol="<%= sortByCol %>" orderByType="<%= sortByType %>" --%>
					<liferay-ui:search-container-results>
		 		 	<%
		 	
					 	if(topLink.equals("all")){
					 		total = MBThreadLocalServiceUtil.dynamicQuery(registered)
									.size();
					 		
					 		searchContainer.setTotal(total);
					 		results=MBThreadLocalServiceUtil.dynamicQuery(registered,
									searchContainer.getStart(),
									searchContainer.getEnd());
					 		/* ArrayList resultSet = new ArrayList(results);
					 		OrderByComparator orderByComparator =  CustomComparatorUtil.getUserOrderByComparator(sortByCol, sortByType);         
					 		  
					           Collections.sort(resultSet,orderByComparator); */
					 		searchContainer.setResults(results);
					 	}else if (topLink.equals("my-posts")) {
					 		
			 		 		//registered.add(PropertyFactoryUtil.forName("status").eq(WorkflowConstants.STATUS_ANY));
							/* registered.add(PropertyFactoryUtil.forName("userId").eq(groupThreadsUserId));
							
					 		
					 		total = MBThreadLocalServiceUtil.dynamicQuery(registered)
									.size();
					 		
					 		searchContainer.setTotal(total);
					 		results=MBThreadLocalServiceUtil.dynamicQuery(registered,
									searchContainer.getStart(),
									searchContainer.getEnd());
					 		searchContainer.setResults(results); */ 
						 	 total = MBThreadServiceUtil.getGroupThreadsCount(scopeGroupId, groupThreadsUserId, WorkflowConstants.STATUS_ANY);
			
							searchContainer.setTotal(total);
			
							results = MBThreadServiceUtil.getGroupThreads(scopeGroupId, groupThreadsUserId, WorkflowConstants.STATUS_ANY, searchContainer.getStart(), searchContainer.getEnd());
							searchContainer.setResults(results);  
						}
						else if (topLink.equals("my-subscriptions")) {
								DynamicQuery subscription = DynamicQueryFactoryUtil.forClass(Subscription.class,"subscription");
								subscription.setProjection(ProjectionFactoryUtil.property("classPK"));
								//subscription.add(PropertyFactoryUtil.forName("subscription.classPK").eqProperty("thread.threadId"));
								subscription.add(PropertyFactoryUtil.forName("subscription.userId").eq(groupThreadsUserId));
								List ids = MBThreadLocalServiceUtil.dynamicQuery(subscription);
								if(ids.isEmpty()) {
								    ids = Arrays.asList(-1L);
								}
								registered.add(PropertyFactoryUtil.forName("thread.threadId").in(ids));
								
								List<MBThread> threads = MBThreadLocalServiceUtil.dynamicQuery(registered); 
									
								 total =  threads.size();//MBThreadServiceUtil.getGroupThreadsCount(scopeGroupId, groupThreadsUserId, WorkflowConstants.STATUS_APPROVED, true);//
			
								 searchContainer.setTotal(total);
			
								results = MBThreadLocalServiceUtil.dynamicQuery(registered,searchContainer.getStart(), searchContainer.getEnd());// MBThreadServiceUtil.getGroupThreads(scopeGroupId, groupThreadsUserId, WorkflowConstants.STATUS_APPROVED, true, searchContainer.getStart(), searchContainer.getEnd());//
								searchContainer.setResults(results); 					
			 			}
					 	%>
					 				 
		 	
		 	</liferay-ui:search-container-results>
		<liferay-ui:search-container-row
			className="com.liferay.portlet.messageboards.model.MBThread"
			escapedModel="<%=true%>" keyProperty="threadId" modelVar="thread">
			<%
				MBMessage message = null;

							try {
								message = MBMessageLocalServiceUtil
										.getMessage(thread.getRootMessageId());

								//if not a question, skiping the message from list
								if (!message.getThread().isQuestion())
									row.setSkip(true);
							} catch (NoSuchMessageException nsme) {
								_log.error("Thread requires missing root message id "
										+ thread.getRootMessageId());

								row.setSkip(true);
							}

							message = message.toEscapedModel();
							row.setObject(new Object[] { message });
			%>
			<liferay-ui:search-container-column-text 
				value="<%=message.getSubject()%>" name="Title"/>  <!-- orderable="true" orderableProperty="subject" -->
			
			
			<liferay-ui:search-container-column-text buffer="buffer"
				name="Asked by"><%-- orderable="true" orderableProperty="userName" --%>
				<% buffer.append((message.isAnonymous() ? LanguageUtil.get(
						pageContext, "anonymous") : HtmlUtil
						.escape(PortalUtil.getUserName(
								message.getUserId(),
								message.getUserName())))); %>
				</liferay-ui:search-container-column-text>
				
			
			<liferay-ui:search-container-column-text
				value="<%=String.valueOf(message.getThread().getMessageCount())%>" name="Comments"/>
			
			<liferay-ui:search-container-column-text
				value="<%=dateFormat.format(message.getCreateDate())%>" name="Created" /> <%--orderable="true" orderableProperty="createDate" --%>
				
			<liferay-ui:search-container-column-jsp
				path="/html/quickquestions/quickquestions_actions.jsp" align="right" name="Actions" />
			
		</liferay-ui:search-container-row>
		
		<liferay-ui:search-iterator />
	</liferay-ui:search-container>
	</c:if>
	
	<c:if test='<%=topLink.equals("my-subscriptions") %>'>
		<%-- <%
			int  total =MBCategoryServiceUtil.getSubscribedCategoriesCount(scopeGroupId, user.getUserId()); 
			List<MBCategory> subscribedCategories = MBCategoryServiceUtil.getSubscribedCategories(scopeGroupId, user.getUserId(),0,total);			
		%>
		
		<div>
					<aui:field-wrapper>
						Subscribed Categories: <br> 
							<select name="<%=renderResponse.getNamespace()%>subscribed_categories" multiple="true" class="choosen">
						<% for(MBCategory category : subscribedCategories){ 
								if(!category.isInTrash() && !category.isInactive()){
						%>
						<option value="<%=category.getCategoryId() %>" selected><%=category.getName()%></option>
						<%
								}
							}
						%>
				</select>
					</aui:field-wrapper>
				</div> --%>
	
		<liferay-ui:search-container
				curParam="cur1"
				deltaConfigurable="<%= false %>"
				headerNames="category,Actions" delta="5"
				iteratorURL="<%= portletURL %>"
				total="<%= MBCategoryServiceUtil.getSubscribedCategoriesCount(scopeGroupId, user.getUserId()) %>"
			>
				<liferay-ui:search-container-results
					results="<%= MBCategoryServiceUtil.getSubscribedCategories(scopeGroupId, user.getUserId(),searchContainer.getStart(),searchContainer.getEnd())%>"
				/>

				<liferay-ui:search-container-row
					className="com.liferay.portlet.messageboards.model.MBCategory"
					escapedModel="<%= true %>"
					keyProperty="categoryId"
					modelVar="curCategory"
				>
					 <liferay-ui:search-container-row-parameter name="categorySubscriptionClassPKs" value="<%= categorySubscriptionClassPKs %>" />

					<liferay-ui:search-container-column-text
							buffer="buffer"
							name="category"
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
					<liferay-ui:search-container-column-jsp path="/html/quickquestions/category_action.jsp" name="Actions" />
				</liferay-ui:search-container-row>

				<liferay-ui:search-iterator type="more" />
			</liferay-ui:search-container>
	</c:if>
	
	<c:if test='<%=topLink.equals("categories") %>'>
		<jsp:include page="/html/quickquestions/${not empty subtargetPage ? subtargetPage : 'view_category_list'}.jsp"></jsp:include>
	</c:if>
	
	<aui:script>
		$('.choosen').chosen({width:'50%',display_disabled_options:false});
	</aui:script>
	
	</liferay-ui:panel>
</liferay-ui:panel-container>

<%!private static Log _log = LogFactoryUtil
			.getLog("portal-web.docroot.html.portlet.message_boards.view_jsp");%>

