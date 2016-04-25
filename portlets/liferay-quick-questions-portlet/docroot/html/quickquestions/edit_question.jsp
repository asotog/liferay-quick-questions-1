<%@include file="/html/quickquestions/init.jsp"%>


<%
	//MBMessage currQuestion = (MBMessage) renderRequest.getAttribute("message");
	long currMessageId = ParamUtil.getLong(request, "messageId");
	MBMessage currQuestion =  null;
	if(currMessageId > 0)
		 currQuestion = MBMessageLocalServiceUtil.getMBMessage(currMessageId);

	List<FileEntry> existingAttachmentsFileEntries = new ArrayList<FileEntry>();
	
	if (currQuestion != null) {
		existingAttachmentsFileEntries = currQuestion.getAttachmentsFileEntries();
	}
	
	String body = ParamUtil.getString(renderRequest, "body");
	/* String title = ParamUtil.getString(renderRequest, "subject");
	String categoryId = ParamUtil.getString(renderRequest, "mbCategoryId"); */
	
	String cancelURL = ParamUtil.getString(request, "cancelURL");
	
	
%>


<liferay-ui:panel title='<%=(currQuestion == null) ? "New Question" : "Edit Question"%>' extended="true" persistState="true">
	<portlet:actionURL name="updateMessage" var="addQuestionURL">
		<portlet:param name="targetPage" value="view_question" />
		<portlet:param name="redirectTo" value="edit_question" />
		<portlet:param name="question" value="true" />
		<portlet:param name="cancelURL" value="<%=cancelURL%>"/>
	</portlet:actionURL>
	
	<aui:model-context bean="<%=currQuestion%>"	model="<%=MBMessage.class%>" />

	<aui:form action="<%=addQuestionURL%>" enctype="multipart/form-data" method="post" name="fm_edit_question"
										   onSubmit='<%=  renderResponse.getNamespace() + "extractCodeFromEditor();" %>'>
		<aui:fieldset>

			<aui:input name="messageId" type="hidden"
				value="<%=currQuestion != null ? currQuestion.getMessageId() : 0%>" />
				
			<aui:input name="parentMessageId" type="hidden"
				value="<%=currQuestion != null ? currQuestion.getParentMessageId() : 0%>" />

			<%-- <aui:input name="title" id="title" type="text"
				value='<%=currQuestion != null ? currQuestion.getSubject() : ""%>' /> --%>
				<aui:input name="subject" label="Title"/>
			
			<aui:input name="threadId" type="hidden"
				value="<%=currQuestion != null ? currQuestion.getThreadId() : StringPool.BLANK%>" />
			<!--
			<aui:select name="mbCategoryId" label="Category" cssClass="chosen" multiple="true" data-placeholder="Select a Category">
				
				<aui:option value="0" label="Default Category"  selected="<%=currQuestion != null && (currQuestion.getCategoryId() == 0)%>" />
				<%
					List<MBCategory> categories = (List<MBCategory>)request.getAttribute("categories");
					for(MBCategory category : categories){
						if(!category.isInTrash() && !category.isInactive()){
				%>
				<aui:option value="<%=category.getCategoryId()%>" label="<%=category.getName()%>"
					selected="<%=(currQuestion != null && (currQuestion.getCategoryId() == category.getCategoryId())) %>" />
				<%
					}} 
				%>
			</aui:select>
			-->
			<c:if test="<%=currQuestion == null%>">
			<label for="mbCategoryId">Categories</label>
			<select name="mbCategoryId" label="Category" cssClass="chosen" data-placeholder="Select a Category">
				<%
					List<MBCategory> categories = (List<MBCategory>)request.getAttribute("categories");
					for(MBCategory category : categories){
						if(!category.isInTrash() && !category.isInactive()){
				%>
				<option value="<%=category.getCategoryId()%>" label="<%=category.getName()%>"
					selected="<%=(currQuestion != null && (currQuestion.getCategoryId() == category.getCategoryId())) %>" />
				<%
					}} 
				%>
			</select>
			</c:if>
			<c:if test="<%=currQuestion == null%>">
				<aui:field-wrapper label="permissions">
					<liferay-ui:input-permissions
						modelName="<%=MBMessage.class.getName()%>" />
				</aui:field-wrapper>
			</c:if>

			<aui:field-wrapper label="Description">
				<liferay-ui:input-editor toolbarSet="liferay" />
				<aui:input name="body" type="hidden"  value="${body}"/>
				<%-- <input name="<portlet:namespace />body" type="hidden"
					value="<%=currQuestion != null ? HtmlUtil.escape(currQuestion.getBody()) : StringPool.BLANK%>" /> --%>
			</aui:field-wrapper>
			
			<c:if test="<%= MBCategoryPermission.contains(permissionChecker, scopeGroupId, (currQuestion != null ? currQuestion.getCategoryId() : 0), ActionKeys.ADD_FILE) %>">
			<liferay-ui:panel cssClass="message-attachments" defaultState="closed" extended="<%= false %>" id="mbMessageAttachmentsPanel" persistState="<%= true %>" title="attachments">
				<c:if test="<%= existingAttachmentsFileEntries.size() > 0 %>">
					<ul>

						<%
						for (int i = 0; i < existingAttachmentsFileEntries.size(); i++) {
							FileEntry fileEntry = existingAttachmentsFileEntries.get(i);

							String taglibDeleteAttachment = "javascript:;";

								taglibDeleteAttachment = "javascript:" + renderResponse.getNamespace() + "deleteAttachment(" + (i + 1) + ");";
						%>

							<li class="message-attachment">
								<span id="<portlet:namespace />existingFile<%= i + 1 %>">
									<aui:input id='<%= "existingPath" + (i + 1) %>' name='<%= "existingPath" + (i + 1) %>' type="hidden" value="<%= fileEntry.getFileEntryId() %>" />

									<liferay-ui:icon
										image='<%= "../file_system/small/" + DLUtil.getFileIcon(fileEntry.getExtension()) %>'
										label="<%= true %>"
										message="<%= fileEntry.getTitle() %>"
									/>
								</span>

								<aui:input cssClass="hide" label="" name='<%= "msgFile" + (i + 1) %>' size="70" title="message-attachment" type="file" />

								<liferay-ui:icon-delete
									id='<%= "removeExisting" + (i + 1) %>'
									label="<%= true %>"
									message='<%= TrashUtil.isTrashEnabled(scopeGroupId) ? "remove" : "delete" %>'
									method="get"
									trash="<%= TrashUtil.isTrashEnabled(scopeGroupId) %>"
									url="<%= taglibDeleteAttachment %>"
								/>
						
							</li>

						<%
						}
						%>

					</ul>
				</c:if>

				<%
				for (int i = existingAttachmentsFileEntries.size() + 1; i <= 5; i++) {
				%>

					<div>
						<aui:input label="" name='<%= "msgFile" + i %>' size="70" title="message-attachment" type="file" />
					</div>

				<%
				}
				%>

			</liferay-ui:panel>
			</c:if>


			<aui:button name="Submit" type="submit" value="Submit" />
			<c:if test="${not empty cancelURL}">
			<aui:button name="cancel" type="cancel" onClick="${cancelURL}" />
			</c:if>

		</aui:fieldset>
	</aui:form>
<aui:script>

AUI().use('aui-base','liferay-form',function(A){
        var rules = {
        <portlet:namespace/>title: {
      required: true,
  },
};
        
var fieldStrings = {
  <portlet:namespace/>title: {
    required: 'Title is mandatory.'
  },
};

var validator = new A.FormValidator(
  {
    boundingBox: '#<portlet:namespace/>fm_edit_question',
    fieldStrings: fieldStrings,
    rules: rules,
    showAllMessages:true
  }
);
}); 
	
function <portlet:namespace />initEditor() {
	    return "<%=currQuestion != null ? UnicodeFormatter.toString(currQuestion.getBody()) : StringPool.BLANK%>";
}
	
function <portlet:namespace />extractCodeFromEditor() {
	    var x = document.<portlet:namespace />fm_edit_question.<portlet:namespace />body.value = window.<portlet:namespace />editor.getHTML();
	    return true;
}


Liferay.provide(
		window,
		'<portlet:namespace />deleteAttachment',
		function(index) {
			var A = AUI();

			var button = A.one('#<portlet:namespace />removeExisting' + index);
			var span = A.one('#<portlet:namespace />existingFile' + index);
			var file = A.one('#<portlet:namespace />msgFile' + index);

			if (button) {
				button.remove();
			}

			if (span) {
				span.remove();
			}

			if (file) {
				file.show();

				file.ancestor('li').addClass('deleted-input');
			}
		},
		['aui-base']
	);
	$('.chosen').chosen({allow_single_deselect:true,max_selected_options:1,display_disabled_options:false});
</aui:script>
</liferay-ui:panel>



