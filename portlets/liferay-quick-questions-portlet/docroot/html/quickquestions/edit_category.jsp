<%@ include file="/html/quickquestions/init.jsp"%>

<%
	MBCategory category = (MBCategory) request
			.getAttribute("edit-category.jsp.category");

	if (category == null) {
		long mbCategoryId = ParamUtil.getLong(renderRequest,
				"mbCategoryId");
		if(mbCategoryId != 0)
			category = MBCategoryServiceUtil.getCategory(mbCategoryId);
	}

	long categoryId = MBUtil.getCategoryId(request, category);

	long parentCategoryId = BeanParamUtil.getLong(category, request,
			"parentCategoryId",
			MBCategoryConstants.DEFAULT_PARENT_CATEGORY_ID);

	if ((category == null) && (parentCategoryId > 0)) {
		MBCategory parentCategory = MBCategoryLocalServiceUtil
				.getCategory(parentCategoryId);
	}
%>

<portlet:actionURL var="editCategoryURL" name="updateCategory">
	<portlet:param name="targetPage" value="view_main" />
	<portlet:param name="topLink" value="categories" />
	<portlet:param name="subtargetPage" value="view_category_list" />
</portlet:actionURL>

<portlet:renderURL var="cancelURL">
	<portlet:param name="targetPage" value="view_main" />
	<portlet:param name="topLink" value="categories" />
	<portlet:param name="subtargetPage" value="view_category_list" />
</portlet:renderURL>

<aui:form action="<%=editCategoryURL%>" method="post"
	name="categoryfm">
	<aui:input name="<%=Constants.CMD%>" type="hidden" />
	<aui:input name="mbCategoryId" type="hidden" value="<%=categoryId%>" />
	<aui:input name="parentCategoryId" type="hidden"
		value="<%=parentCategoryId%>" />
	<aui:model-context bean="<%=category%>"
		model="<%=MBCategory.class%>" />

	<aui:fieldset>
		<aui:input name="name" />

		<aui:input name="description" />

		<c:if test="<%=category == null%>">
			<aui:field-wrapper label="permissions">
				<liferay-ui:input-permissions
					modelName="<%=MBCategory.class.getName()%>" />
			</aui:field-wrapper>
		</c:if>

		<br />
	</aui:fieldset>

	<br />

	<aui:button-row>
		<aui:button type="submit" />
		<aui:button value="cancel" onClick="<%=cancelURL%>" />
	</aui:button-row>
</aui:form>
