<%@ include file="/html/quickquestions/init.jsp" %>

<%
ResultRow row = (ResultRow)request.getAttribute(WebKeys.SEARCH_CONTAINER_RESULT_ROW);

MBCategory category = (MBCategory)row.getObject();


boolean defaultParentCategory = false;

if (category.getCategoryId() == MBCategoryConstants.DEFAULT_PARENT_CATEGORY_ID) {
	defaultParentCategory = true;
}

String modelResource = null;
String modelResourceDescription = null;
String resourcePrimKey = null;


if (!defaultParentCategory) {
	modelResource = MBCategory.class.getName();
	modelResourceDescription = category.getName();
	resourcePrimKey = String.valueOf(category.getCategoryId());

}
else {
	modelResource = "com.liferay.portlet.messageboards";
	modelResourceDescription = themeDisplay.getScopeGroupName();
	resourcePrimKey = String.valueOf(scopeGroupId);

}
%>

<liferay-ui:icon-menu>
	<c:if test="<%= !defaultParentCategory && MBCategoryPermission.contains(permissionChecker, category, ActionKeys.UPDATE) %>">
		<portlet:renderURL var="editURL">
			<portlet:param name="targetPage" value="view_main"/>
			<portlet:param name="topLink" value="categories"/>
			<portlet:param name="subtargetPage" value="edit_category"/>
			<portlet:param name="mbCategoryId" value="<%= String.valueOf(category.getCategoryId()) %>" />
		</portlet:renderURL>

		<liferay-ui:icon
			image="edit"
			url="<%= editURL %>"
		/>

	</c:if>

	<%
		long categorySubscriptionClassPK = 0;

		boolean hasSubscriptionPermission = false;

		if (!defaultParentCategory) {
			categorySubscriptionClassPK = category.getCategoryId();

			hasSubscriptionPermission = MBCategoryPermission.contains(permissionChecker, category, ActionKeys.SUBSCRIBE);
		}
		else {
			categorySubscriptionClassPK = scopeGroupId;

			hasSubscriptionPermission = MBPermission.contains(permissionChecker, scopeGroupId, ActionKeys.SUBSCRIBE);
		}
		%>

		<c:if test="<%= hasSubscriptionPermission && (MBUtil.getEmailMessageAddedEnabled(portletPreferences) || MBUtil.getEmailMessageUpdatedEnabled(portletPreferences)) %>">
			<c:choose>
				<c:when test="<%= (categorySubscriptionClassPKs != null) && categorySubscriptionClassPKs.contains(categorySubscriptionClassPK) %>">
					<portlet:actionURL var="unsubscribeURL" name="unsubscribeCategory">
						<portlet:param name="targetPage" value="view_main"/>
						<portlet:param name="topLink" value="categories"/>
						<portlet:param name="subtargetPage" value="view_category_list"/>
						<portlet:param name="mbCategoryId" value="<%= String.valueOf(category.getCategoryId()) %>" />
					</portlet:actionURL>

					<liferay-ui:icon
						image="unsubscribe"
						url="<%= unsubscribeURL %>"
					/>
				</c:when>
				<c:otherwise>
					<portlet:actionURL var="subscribeURL" name="subscribeCategory">
						<portlet:param name="targetPage" value="view_main"/>
						<portlet:param name="topLink" value="categories"/>
						<portlet:param name="subtargetPage" value="view_category_list"/>
						<portlet:param name="mbCategoryId" value="<%= String.valueOf(category.getCategoryId()) %>" />
					</portlet:actionURL>

					<liferay-ui:icon
						image="subscribe"
						url="<%= subscribeURL %>"
					/>
				</c:otherwise>
			</c:choose>
		</c:if>

	<c:if test="<%= !defaultParentCategory && MBCategoryPermission.contains(permissionChecker, category, ActionKeys.DELETE) %>">
		<portlet:actionURL var="deleteURL" name="deleteCategories">
			<portlet:param name="targetPage" value="view_main"/>
			<portlet:param name="topLink" value="categories"/>
			<portlet:param name="subtargetPage" value="view_category_list"/>
			<portlet:param name="mbCategoryId" value="<%= String.valueOf(category.getCategoryId()) %>" />
		</portlet:actionURL>

		<liferay-ui:icon-delete label="Delete"
			url="<%= deleteURL %>"
		/> 
	</c:if>
</liferay-ui:icon-menu>