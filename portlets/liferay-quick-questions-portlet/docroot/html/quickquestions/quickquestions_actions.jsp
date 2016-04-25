<%@include file="/html/quickquestions/init.jsp"%>

<%
	ResultRow row = (ResultRow) request
			.getAttribute(WebKeys.SEARCH_CONTAINER_RESULT_ROW);

	Object[] obj = (Object[]) row.getObject();
	MBMessage message = (MBMessage) obj[0];
	String topLink = request.getParameter("topLink");

%>

<liferay-ui:icon-menu>

	<portlet:renderURL var="openURL">
		<portlet:param name="messageId"
			value="<%=String.valueOf(message.getMessageId())%>" />
		<portlet:param name="targetPage" value="view_question" />
		<portlet:param name="topLink" value="<%=topLink%>"/>
	</portlet:renderURL>

	<liferay-ui:icon image="view" message="Open"
		url="<%=openURL.toString()%>" />

	<c:if
		test="<%=MBMessagePermission.contains(permissionChecker,
							message, ActionKeys.UPDATE) && !message.getThread().isLocked()%>">
		
		<%	PortletURL cancelURL = renderResponse.createRenderURL();
			cancelURL.setParameter("targetPage", "view_main");
			cancelURL.setParameter("topLink", (topLink != null) ? topLink  :"view_main");
		%>
		
		<portlet:renderURL var="editURL">
			<portlet:param name="targetPage" value="edit_question" />
			<portlet:param name="messageId"
				value="<%=String.valueOf(message.getMessageId())%>" />
				<portlet:param name="topLink" value="<%=topLink%>"/>
				<portlet:param name="cancelURL" value="<%=cancelURL.toString()%>"/>
		</portlet:renderURL>

		<liferay-ui:icon image="edit" message="Edit"
			url="<%=editURL.toString()%>" />
	</c:if>
<c:if test="<%= !message.getThread().isLocked() && MBMessagePermission.contains(permissionChecker, message, ActionKeys.DELETE) %>">
	<portlet:actionURL name="deleteMessage" var="deleteURL">
		<portlet:param name="targetPage" value="view_main"></portlet:param>
		<portlet:param name="topLink" value="<%=topLink%>"/>
		<portlet:param name="messageId"
			value="<%=message != null ? String.valueOf(message
							.getMessageId()) : StringPool.BLANK%>" />
	</portlet:actionURL>
	<liferay-ui:icon-delete label="Delete"
			url="<%= deleteURL %>"
		/> 
</c:if>

	<c:if
		test="<%=MBMessagePermission.contains(permissionChecker,
							message, ActionKeys.SUBSCRIBE)
							&& (MBUtil
									.getEmailMessageAddedEnabled(portletPreferences) || MBUtil
									.getEmailMessageUpdatedEnabled(portletPreferences))%>">
		<c:choose>
			<c:when
				test="<%=(threadSubscriptionClassPKs != null)
									&& threadSubscriptionClassPKs
											.contains(message.getThreadId())%>">
				<portlet:actionURL var="unsubscribeURL" name="unsubscribeMessage">
				<portlet:param name="topLink" value="<%=topLink%>"/>
					<portlet:param name="targetPage" value="view_main"></portlet:param>
					<portlet:param name="messageId"
						value="<%=message != null ? String
										.valueOf(message.getMessageId())
										: StringPool.BLANK%>" />
				</portlet:actionURL>

				<liferay-ui:icon image="unsubscribe" url="<%=unsubscribeURL%>"
					message="Unfollow" />
			</c:when>
			<c:otherwise>
				<portlet:actionURL var="subscribeURL" name="subscribeMessage">
					<portlet:param name="targetPage" value="view_main"></portlet:param>
					<portlet:param name="topLink" value="<%=topLink%>"/>
					<portlet:param name="messageId"
						value="<%=message != null ? String
										.valueOf(message.getMessageId())
										: StringPool.BLANK%>" />
				</portlet:actionURL>

				<liferay-ui:icon image="subscribe" url="<%=subscribeURL%>"
					message="Follow" />
			</c:otherwise>
		</c:choose>
	</c:if>
</liferay-ui:icon-menu>