<%@page import="com.liferay.portal.model.Subscription"%>
<%@page import="com.liferay.portal.service.SubscriptionLocalServiceUtil"%>
<%@page import="com.liferay.portal.service.persistence.SubscriptionUtil"%>
<%@include file="/html/quickquestions/init.jsp"%>


<%
	/* MBMessage parentMessage = (MBMessage) renderRequest
	.getAttribute("message"); */
	long currMessageId = ParamUtil.getLong(request, "messageId");
	long parentMessageId = ParamUtil.getLong(renderRequest, "parentMessageId");
	if(currMessageId == 0)
		currMessageId = parentMessageId;
	MBMessage parentMessage =  MBMessageLocalServiceUtil.getMBMessage(currMessageId);
	MBThread thread = parentMessage.getThread();
	int total= thread.getMessageCount();//MBMessageServiceUtil.getThreadMessagesCount(scopeGroupId, parentMessage.getCategoryId(), thread.getThreadId(), WorkflowConstants.STATUS_APPROVED);
	List<MBMessage> messages = MBMessageServiceUtil.getThreadMessages(parentMessage.getGroupId(), parentMessage.getCategoryId(), parentMessage.getThreadId(), WorkflowConstants.STATUS_APPROVED, 0, total);
	
	
	
	MBUtil.addPortletBreadcrumbEntries(parentMessage, request, renderResponse);
	
%>

<liferay-ui:panel-container>

	<liferay-ui:panel title="<%= parentMessage.getSubject() %>" extended="true" persistState="true">
		<div class="content question-view">

			<%
				for(MBMessage message : messages) {
			%>

			<aui:row>
			<aui:col span="2">
			 <liferay-ui:user-display displayStyle="<%= 1 %>"
						userId="<%= message.getUserId() %>"
					/>
			</aui:col>
			<aui:col span="10">
			<div>
				<%
					if(message.getParentMessageId() == 0) {
				%>
				<div class="question-header">
				<div >
				<div class="col-md-9 padding-left-zero author">
					<liferay-ui:breadcrumb showPortletBreadcrumb="true" />
				</div>
					
				
					
				<%
					// to fetch list of follower for the loaded question.
					DynamicQuery followersNo = DynamicQueryFactoryUtil.forClass(Subscription.class)
					.setProjection(ProjectionFactoryUtil.property("userId"))
					.add(PropertyFactoryUtil.forName("classPK").eq(thread.getThreadId()));
				
				%>
					
				<div class="col-md-3 pull-right"><%=SubscriptionLocalServiceUtil.dynamicQueryCount(followersNo)%>
					Following
				</div>
			</div>
				
					<h3><%= (message != null) ? message.getSubject() : StringPool.BLANK%>
						
					</h3>
				</div>
				<%
					} else {
				%>
				<div class="margin-top-15">
					<p>
						<%= (message != null) ? message.getBody() : StringPool.BLANK%>
					</p>
				</div>

				<%
					}
				%>
				<div>
					<div>
						<div class="col-md-8 author">
							<%
								if(message.getParentMessageId() == 0) {
							%>
							<p class="author">
								Asked by:
								<%=message != null ? (message.isAnonymous() ? LanguageUtil
					.get(pageContext, "anonymous") : HtmlUtil.escape(PortalUtil
					.getUserName(message.getUserId(), message.getUserName())))
					: StringPool.BLANK%>
							</p>
							<p class="time">
								Published Date:
								<%=message != null ? dateFormat.format(message.getCreateDate())
					: StringPool.BLANK%>
							</p>
							<%
								} else {
							%>
							<p class="author">
								Posted by:
								<%=message != null ? (message.isAnonymous() ? LanguageUtil
					.get(pageContext, "anonymous") : HtmlUtil.escape(PortalUtil
					.getUserName(message.getUserId(), message.getUserName())))
					: StringPool.BLANK%>
							</p>
							<p class="time">
								<%
									Date now = new Date();

								                    		long lastPostAgo = now.getTime() - thread.getLastPostDate().getTime();
								%>
								<%=LanguageUtil.format(pageContext, "x-ago", LanguageUtil.getTimeDescription(pageContext, lastPostAgo, true))%>
							</p>
							<%
								}
							%>
						</div>
						<div class="col-md-4 author pull-right text-justify"
							style="vertical-align: bottom;">
							<c:if
								test="<%=MBMessagePermission.contains(permissionChecker,
							message, ActionKeys.UPDATE) && !message.getThread().isLocked()%>">
							<%
							PortletURL cancelURL = renderResponse.createRenderURL();
							cancelURL.setParameter("targetPage", "view_question");
							cancelURL.setParameter("messageId", String.valueOf(currMessageId));
							%>
								<portlet:renderURL var="editQuestionURL">
									<portlet:param name="targetPage" value="edit_question" />
									<portlet:param name="cancelURL" value="<%=cancelURL.toString()%>"/>
									<portlet:param name="messageId"
										value="<%=message != null ? String.valueOf(message
										.getMessageId()) : StringPool.BLANK%>" />

								</portlet:renderURL>
								<span class="edit"><a href="<%=editQuestionURL%>">Edit</a></span> |
				</c:if>
							<c:if
								test="<%=!message.getThread().isLocked() && MBMessagePermission.contains(permissionChecker, message, ActionKeys.DELETE)%>">
								<portlet:actionURL name="deleteMessage" var="deleteQuestionURL">
									<portlet:param name="targetPage" value="view_question"></portlet:param>
									<portlet:param name="messageId"
										value="<%=message != null ? String.valueOf(message
						.getMessageId()) : StringPool.BLANK%>" />
									<portlet:param name="parentMessageId" value="<%=message != null ? String.valueOf(message
											.getParentMessageId()) : StringPool.BLANK %>"/>
								</portlet:actionURL>
								<span class="delete"><a href="<%=deleteQuestionURL%>">Delete</a></span>
							</c:if>
						</div>
					</div>
				</div>
				<%
					if(message.getParentMessageId() == 0){
				%>
				<div class="margin-top-15">
					<p>
						<%=message != null ? message.getBody() : StringPool.BLANK%>
					</p>
				</div>
				<div class="col-md-3 pull-right"><%=(thread.getMessageCount()) > 0 ?thread.getMessageCount() - 1 : thread.getMessageCount()%>
					comments
				</div>


				<%
					}
				%>
			</div>
			<%@include file="/html/quickquestions/view_attachements.jspf" %>
			</aui:col>
			</aui:row>
			<br /> <br />

			<hr>


			<%
				}
			%>
			<c:if
				test="<%=MBCategoryPermission.contains(permissionChecker, scopeGroupId, parentMessage.getCategoryId(), ActionKeys.REPLY_TO_MESSAGE)%>">
				<portlet:actionURL name="updateMessage" var="addQuestionURL">
					<portlet:param name="targetPage" value="view_question"></portlet:param>
					<portlet:param name="question" value="true" />
					<portlet:param name="redirectTo" value="view_question"/>
					<portlet:param name="isPost" value="true" />
				</portlet:actionURL>
				<aui:form action="<%=addQuestionURL%>" enctype="multipart/form-data"
					method="post" name="fm_edit_question"
					onSubmit='<%= "event.preventDefault(); " + renderResponse.getNamespace() + "extractCodeFromEditor();" %>'>
					<aui:fieldset>

						<aui:input name="messageId" type="hidden" value="0" />
						<aui:input name="parentMessageId" type="hidden"
							value="<%=parentMessage != null ? parentMessage.getRootMessageId() : 0%>" />
						<aui:input name="threadId" type="hidden"
							value="<%=parentMessage != null ? parentMessage.getThreadId() : StringPool.BLANK%>"></aui:input>
						<aui:input name="mbCategoryId" type="hidden"
							value="<%=parentMessage != null ? parentMessage.getCategoryId() : StringPool.BLANK%>"></aui:input>
						<aui:field-wrapper label="Body">
							<liferay-ui:input-editor toolbarSet="liferay" />
							<input name="<portlet:namespace />body" type="hidden" value="" />
						</aui:field-wrapper>
						
							<%
								for (int i = 1; i <= 5; i++) {
							%>
							<div>
								<aui:input label="" name='<%="msgFile" + i%>' size="70"
										title="message-attachment" type="file" />
							</div>
							<%
								}
							%>
						
						<aui:button name="Submit" type="submit" value="Post this comment" cssClass="pull-right" />
					</aui:fieldset>
				</aui:form>

				<aui:script>
	function <portlet:namespace />initEditor() {
	    return "<%=StringPool.BLANK%>";
	}
	
	function <portlet:namespace />extractCodeFromEditor() {
	    var x = document.<portlet:namespace />fm_edit_question.<portlet:namespace />body.value = window.<portlet:namespace />editor.getHTML();
	
	    submitForm(document.<portlet:namespace />fm_edit_question);
	}
	
	
</aui:script>
	


			
</c:if>
	</liferay-ui:panel>
</liferay-ui:panel-container>



