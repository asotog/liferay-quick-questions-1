package com.rivetlogic.quickquestions.portlet;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.servlet.SessionErrors;
import com.liferay.portal.kernel.servlet.SessionMessages;
import com.liferay.portal.kernel.upload.UploadPortletRequest;
import com.liferay.portal.kernel.util.GetterUtil;
import com.liferay.portal.kernel.util.ObjectValuePair;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.StreamUtil;
import com.liferay.portal.kernel.util.StringUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.security.permission.ActionKeys;
import com.liferay.portal.security.permission.PermissionChecker;
import com.liferay.portal.service.ServiceContext;
import com.liferay.portal.service.ServiceContextFactory;
import com.liferay.portal.theme.ThemeDisplay;
import com.liferay.portal.util.PortalUtil;
import com.liferay.portlet.documentlibrary.DuplicateFileException;
import com.liferay.portlet.messageboards.model.MBCategory;
import com.liferay.portlet.messageboards.model.MBMessage;
import com.liferay.portlet.messageboards.model.MBMessageConstants;
import com.liferay.portlet.messageboards.model.MBThread;
import com.liferay.portlet.messageboards.service.MBCategoryServiceUtil;
import com.liferay.portlet.messageboards.service.MBMessageServiceUtil;
import com.liferay.portlet.messageboards.service.MBThreadLocalServiceUtil;
import com.liferay.portlet.messageboards.service.MBThreadServiceUtil;
import com.liferay.util.bridges.mvc.MVCPortlet;
import com.rivetlogic.quickquestions.action.QuestionTitleException;
import com.rivetlogic.quickquestions.action.util.MBUtil;
import com.rivetlogic.quickquestions.model.permissions.MBMessagePermission;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletException;
import javax.portlet.PortletPreferences;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

/**
 * Portlet implementation class quickquestionsPortlet
 */
public class QuickQuestionsPortlet extends MVCPortlet {
	
	
	private static final Log LOG = LogFactoryUtil
			.getLog(QuickQuestionsPortlet.class);


	
	public void unsubscribeMessage(ActionRequest actionRequest,ActionResponse actionResponse)
			throws Exception {

			long messageId = ParamUtil.getLong(actionRequest, "messageId");

			MBMessageServiceUtil.unsubscribeMessage(messageId);
			MBUtil.setRenderParams(actionRequest, actionResponse);
	}
	
	public void subscribeMessage(ActionRequest actionRequest,ActionResponse actionResponse)
			throws Exception {

			long messageId = ParamUtil.getLong(actionRequest, "messageId");

			MBMessageServiceUtil.subscribeMessage(messageId);
			MBUtil.setRenderParams(actionRequest, actionResponse);
	}
 
		public void render(RenderRequest request, RenderResponse response)
			throws PortletException, IOException {
		
		
		String targetPage = request.getParameter("targetPage");
		String subtargetPage = request.getParameter("subtargetPage");
		String cancelURL = request.getParameter("cancelURL");
		
		if(targetPage != null)
			request.setAttribute("targetPage", targetPage);
		else
			targetPage = "";
		
		if(subtargetPage != null)
			request.setAttribute("subtargetPage", subtargetPage);
		else
			subtargetPage = "";
		
		if(cancelURL != null)
			request.setAttribute("cancelURL", cancelURL);
		else
			cancelURL = "";
		
		
		/*if(targetPage.equalsIgnoreCase("view_question")){
			Long messageId = ParamUtil.getLong(request,"messageId");
			if(messageId <= 0)
				throw new PortletException("message id cannot be 0");

			try {
				MBMessage message = MBMessageLocalServiceUtil.getMBMessage(messageId);
				request.setAttribute("message", message);
			} catch (PortalException | SystemException e) {
				e.printStackTrace();
			}
		}else if(targetPage.equalsIgnoreCase("edit_question") && !isNew ){
			Long messageId = ParamUtil.getLong(request,"messageId");
			if(messageId <= 0)
				throw new PortletException("message id cannot be 0");

			try {
				MBMessage message = MBMessageLocalServiceUtil.getMBMessage(messageId);
				request.setAttribute("message", message);
			} catch (PortalException | SystemException e) {
				e.printStackTrace();
			}
		}*/
		
	    super.render(request, response);

	}
	
	
	
	public void updateMessage(
			ActionRequest actionRequest, ActionResponse actionResponse) throws Exception
		 {

		PortletPreferences portletPreferences = actionRequest.getPreferences();

		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(
			WebKeys.THEME_DISPLAY);
		actionResponse.setRenderParameters(actionRequest.getParameterMap());
		UploadPortletRequest uploadPortletRequest =
				PortalUtil.getUploadPortletRequest(actionRequest);
		
		String targetpage = uploadPortletRequest.getParameter("targetPage");
		uploadPortletRequest.setAttribute("targetPage", targetpage);
		
		String redirectTo = uploadPortletRequest.getParameter("redirectTo");
		
		
		
		long messageId = ParamUtil.getLong(uploadPortletRequest, "messageId");

		long groupId = themeDisplay.getScopeGroupId();
		long categoryId = ParamUtil.getLong(uploadPortletRequest, "mbCategoryId");
		long threadId = ParamUtil.getLong(uploadPortletRequest, "threadId");
		long parentMessageId = ParamUtil.getLong(
				uploadPortletRequest, "parentMessageId");
		String subject = ParamUtil.getString(uploadPortletRequest, "subject");
		
		boolean isPost = ParamUtil.getBoolean(uploadPortletRequest, "isPost");
		
		
		
		if((subject  == null || subject.trim().length() <= 0) && !isPost){
			actionResponse.setRenderParameter("targetPage", redirectTo);
			SessionErrors.add(actionRequest, "title-is-required");
			actionResponse.setRenderParameter("mbCategoryId", String.valueOf(categoryId));
			actionResponse.setRenderParameter("body", "body");
			actionResponse.setRenderParameter("parentMessageId", String.valueOf(parentMessageId));
			SessionMessages.add(actionRequest, PortalUtil.getPortletId(actionRequest) + SessionMessages.KEY_SUFFIX_HIDE_DEFAULT_ERROR_MESSAGE);
			return;
		}
		
		String body = ParamUtil.getString(uploadPortletRequest, "body");

		String format = GetterUtil.getString(
			portletPreferences.getValue("messageFormat", null),
			MBMessageConstants.DEFAULT_FORMAT);

		List<ObjectValuePair<String, InputStream>> inputStreamOVPs =
			new ArrayList<ObjectValuePair<String, InputStream>>(5);

		try {
	
			for (int i = 1; i <= 5; i++) {
				String fileName = uploadPortletRequest.getFileName(
					"msgFile" + i);
				InputStream inputStream = uploadPortletRequest.getFileAsStream(
					"msgFile" + i);

				if ((inputStream == null) || Validator.isNull(fileName)) {
					continue;
				}

				ObjectValuePair<String, InputStream> inputStreamOVP =
					new ObjectValuePair<String, InputStream>(
						fileName, inputStream);

				inputStreamOVPs.add(inputStreamOVP);
			}

			boolean question = ParamUtil.getBoolean(actionRequest, "question");
			boolean anonymous = ParamUtil.getBoolean(
				actionRequest, "anonymous");
			double priority = ParamUtil.getDouble(actionRequest, "priority");
			boolean allowPingbacks = ParamUtil.getBoolean(
				actionRequest, "allowPingbacks");

			ServiceContext serviceContext = ServiceContextFactory.getInstance(
				MBMessage.class.getName(), actionRequest);

			boolean preview = ParamUtil.getBoolean(actionRequest, "preview");

			serviceContext.setAttribute("preview", preview);

			MBMessage message = null;

			if (messageId <= 0) {
				if (threadId <= 0) {

					// Post new thread

					message = MBMessageServiceUtil.addMessage(
						groupId, categoryId, subject, body, format,
						inputStreamOVPs, anonymous, priority, true,
						serviceContext);

					if (question) {
						MBThreadLocalServiceUtil.updateQuestion(
							message.getThreadId(), true);
					}
				}
				else {

					// Post reply

					message = MBMessageServiceUtil.addMessage(
						parentMessageId, subject, body, format, inputStreamOVPs,
						anonymous, priority, true, serviceContext);//allowing ping back defaultly true;
				}
			}
			else {
				List<String> existingFiles = new ArrayList<String>();

				for (int i = 1; i <= 5; i++) {
					String path = ParamUtil.getString(
							uploadPortletRequest, "existingPath" + i);

					if (Validator.isNotNull(path)) {
						existingFiles.add(path);
					}
				}

				// Update message

				message = MBMessageServiceUtil.updateMessage(
					messageId, subject, body, inputStreamOVPs, existingFiles,
					priority, allowPingbacks, serviceContext);

				if (message.isRoot()) {
					MBThreadLocalServiceUtil.updateQuestion(
						message.getThreadId(), question);
				}
			}

			PermissionChecker permissionChecker =
				themeDisplay.getPermissionChecker();

			
			
			if(threadId == 0)
				threadId = message.getThreadId();
			
			MBThread thread = MBThreadLocalServiceUtil.getThread(threadId);

			if(message.getCategoryId() != thread.getCategoryId()){ // if current category is not equal to existing category update move thread to 
				MBThreadServiceUtil.moveThread(categoryId, threadId);//specified category.
			}
			
			if (themeDisplay.isSignedIn() && // subscribe is by defaultly true.
					MBMessagePermission.contains(
						permissionChecker, message, ActionKeys.SUBSCRIBE)) {

					MBMessageServiceUtil.subscribeMessage(message.getMessageId());
			}

			
			actionResponse.setRenderParameter("messageId", String.valueOf(message.getRootMessageId()));
			
			SessionMessages.add(actionRequest, "message-add-success");
			
		}catch (DuplicateFileException e) {
			Map parameterMap = actionRequest.getParameterMap();
			actionResponse.setRenderParameters(actionRequest.getParameterMap());
			actionResponse.setRenderParameter("targetPage", redirectTo);
			actionResponse.setRenderParameter("isNew", "true");
			SessionErrors.add(actionRequest, "duplicate-file");
			actionResponse.setRenderParameter("subject", subject);
			actionResponse.setRenderParameter("body", body);
			actionResponse.setRenderParameter("mbCategoryId", String.valueOf(categoryId));
			actionResponse.setRenderParameter("parentMessageId", String.valueOf(parentMessageId));
			
			
			SessionMessages.add(actionRequest, PortalUtil.getPortletId(actionRequest) + SessionMessages.KEY_SUFFIX_HIDE_DEFAULT_ERROR_MESSAGE);
			throw e;
		}catch(Exception e){
			e.printStackTrace();
			throw e;
		}finally {
			for (ObjectValuePair<String, InputStream> inputStreamOVP :
					inputStreamOVPs) {

				InputStream inputStream = inputStreamOVP.getValue();

				StreamUtil.cleanUp(inputStream);
			}
		}
	}
	
	
	public void deleteMessage(ActionRequest actionRequest,ActionResponse response) throws Exception {
		long messageId = ParamUtil.getLong(actionRequest, "messageId");
		long parentMessageId = ParamUtil.getLong(actionRequest, "parentMessageId");
		

		try{
			
			MBMessageServiceUtil.deleteMessage(messageId);
			
			if(parentMessageId > 0){
				response.setRenderParameter("messageId", String.valueOf(parentMessageId));
				response.setRenderParameter("targetPage", "view_question");
			}else{
				response.setRenderParameter("targetPage", "view_main");
			}
			
			
		}catch(Exception e){
			SessionErrors.add(actionRequest, e.getClass());
			SessionMessages.add(actionRequest, PortalUtil.getPortletId(actionRequest) + SessionMessages.KEY_SUFFIX_HIDE_DEFAULT_ERROR_MESSAGE);
			response.setRenderParameter("messageId", String.valueOf(messageId));
			response.setRenderParameter("targetPage", "view_question");
			throw e;
		}
		
		SessionMessages.add(actionRequest, "message-delete-success");
		
	}

	
	public void updateCategory(ActionRequest actionRequest, ActionResponse actionResponse)
			throws Exception {

			long categoryId = ParamUtil.getLong(actionRequest, "mbCategoryId");

			long parentCategoryId = ParamUtil.getLong(
				actionRequest, "parentCategoryId");
			String name = ParamUtil.getString(actionRequest, "name");
			String description = ParamUtil.getString(actionRequest, "description");
			String displayStyle = ParamUtil.getString(
				actionRequest, "displayStyle");

			String emailAddress = ParamUtil.getString(
				actionRequest, "emailAddress");
			String inProtocol = ParamUtil.getString(actionRequest, "inProtocol");
			String inServerName = ParamUtil.getString(
				actionRequest, "inServerName");
			int inServerPort = ParamUtil.getInteger(actionRequest, "inServerPort");
			boolean inUseSSL = ParamUtil.getBoolean(actionRequest, "inUseSSL");
			String inUserName = ParamUtil.getString(actionRequest, "inUserName");
			String inPassword = ParamUtil.getString(actionRequest, "inPassword");
			int inReadInterval = ParamUtil.getInteger(
				actionRequest, "inReadInterval");
			String outEmailAddress = ParamUtil.getString(
				actionRequest, "outEmailAddress");
			boolean outCustom = ParamUtil.getBoolean(actionRequest, "outCustom");
			String outServerName = ParamUtil.getString(
				actionRequest, "outServerName");
			int outServerPort = ParamUtil.getInteger(
				actionRequest, "outServerPort");
			boolean outUseSSL = ParamUtil.getBoolean(actionRequest, "outUseSSL");
			String outUserName = ParamUtil.getString(actionRequest, "outUserName");
			String outPassword = ParamUtil.getString(actionRequest, "outPassword");
			boolean allowAnonymous = ParamUtil.getBoolean(
				actionRequest, "allowAnonymous");
			boolean mailingListActive = ParamUtil.getBoolean(
				actionRequest, "mailingListActive");

			boolean mergeWithParentCategory = ParamUtil.getBoolean(
				actionRequest, "mergeWithParentCategory");
			
			
			allowAnonymous = true; // keeping annonymous mailing list to send mails to everyone.
			
			
			ServiceContext serviceContext = ServiceContextFactory.getInstance(
				MBCategory.class.getName(), actionRequest);
			MBCategory category = null;
			if (categoryId <= 0) {
				// Add category

				category = MBCategoryServiceUtil.addCategory(
					parentCategoryId, name, description, displayStyle, emailAddress,
					inProtocol, inServerName, inServerPort, inUseSSL, inUserName,
					inPassword, inReadInterval, outEmailAddress, outCustom,
					outServerName, outServerPort, outUseSSL, outUserName,
					outPassword, allowAnonymous, mailingListActive, serviceContext);
			}
			else {

				// Update category

				category =  MBCategoryServiceUtil.updateCategory(
					categoryId, parentCategoryId, name, description, displayStyle,
					emailAddress, inProtocol, inServerName, inServerPort, inUseSSL,
					inUserName, inPassword, inReadInterval, outEmailAddress,
					outCustom, outServerName, outServerPort, outUseSSL, outUserName,
					outPassword, allowAnonymous, mailingListActive,
					mergeWithParentCategory, serviceContext);
			}
			
			actionRequest.setAttribute("edit-category.jsp.category", category);

			MBUtil.setRenderParams(actionRequest, actionResponse);
			
			actionResponse.setRenderParameter("categoryId", String.valueOf(category.getCategoryId()));
			actionResponse.setRenderParameter("parentCategoryId", String.valueOf(category.getParentCategoryId()));
			
		}
	
	
	
	public void deleteCategories(
			ActionRequest actionRequest, ActionResponse actionResponse)
		throws Exception {

		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(
			WebKeys.THEME_DISPLAY);


		long[] deleteCategoryIds = null;

		long categoryId = ParamUtil.getLong(actionRequest, "mbCategoryId");

		if (categoryId > 0) {
			deleteCategoryIds = new long[] {categoryId};
		}
		else {
			deleteCategoryIds = StringUtil.split(
				ParamUtil.getString(actionRequest, "deleteCategoryIds"), 0L);
		}

		for (int i = 0; i < deleteCategoryIds.length; i++) {
			long deleteCategoryId = deleteCategoryIds[i];
				MBCategoryServiceUtil.deleteCategory(
					themeDisplay.getScopeGroupId(), deleteCategoryId);
		}
		
		MBUtil.setRenderParams(actionRequest, actionResponse);
	}

	public void subscribeCategory(ActionRequest actionRequest, ActionResponse actionResponse)
		throws Exception {

		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(
			WebKeys.THEME_DISPLAY);

		long categoryId = ParamUtil.getLong(actionRequest, "mbCategoryId");

		MBCategoryServiceUtil.subscribeCategory(
			themeDisplay.getScopeGroupId(), categoryId);
		
		MBUtil.setRenderParams(actionRequest, actionResponse);
	}

	public void unsubscribeCategory(ActionRequest actionRequest, ActionResponse actionResponse)
		throws Exception {

		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(
			WebKeys.THEME_DISPLAY);

		long categoryId = ParamUtil.getLong(actionRequest, "mbCategoryId");

		MBCategoryServiceUtil.unsubscribeCategory(
			themeDisplay.getScopeGroupId(), categoryId);
		
		//actionResponse.setRenderParameters(actionRequest.getParameterMap());
		MBUtil.setRenderParams(actionRequest, actionResponse);
		
	}
	

}
