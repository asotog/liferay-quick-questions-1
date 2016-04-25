<%@ taglib uri="http://alloy.liferay.com/tld/aui" prefix="aui" %>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="theme" %>
<%@ taglib uri="http://java.sun.com/portlet" prefix="portlet" %>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@page import="com.liferay.portal.kernel.dao.orm.PropertyFactoryUtil"%>
<%@ page import="com.liferay.portal.kernel.parsers.bbcode.BBCodeTranslatorUtil" %>
<%@ page import="com.liferay.portal.kernel.repository.model.FileEntry"%>
<%@ page import="com.liferay.portal.kernel.workflow.*" %>
<%@ page import="com.liferay.portal.theme.ThemeDisplay" %>
<%@ page import="com.liferay.portal.kernel.util.MimeTypesUtil" %>
<%@ page import="com.liferay.portal.kernel.language.LanguageUtil" %>
<%@ page import="com.liferay.portal.kernel.util.ParamUtil" %>
<%@ page import="com.liferay.portal.kernel.util.*" %>
<%@ page import="com.liferay.portal.kernel.dao.search.RowChecker" %>
<%@ page import="com.liferay.portal.kernel.dao.search.ResultRow" %>
<%@ page import="com.liferay.portal.kernel.log.Log" %>
<%@ page import="com.liferay.portal.kernel.log.LogFactoryUtil" %>
<%@ page import="com.liferay.portal.kernel.util.WebKeys" %>
<%@ page import="com.liferay.portlet.messageboards.NoSuchMessageException" %>
<%@ page import="com.liferay.portlet.messageboards.model.MBCategory" %>
<%@ page import="com.liferay.portlet.messageboards.model.MBMessage" %>
<%@ page import="com.liferay.portlet.messageboards.model.MBCategoryConstants" %>
<%@ page import="com.liferay.portlet.messageboards.model.MBMessageConstants" %>
<%@ page import="com.liferay.portlet.messageboards.model.*" %>
<%@ page import="com.liferay.portlet.messageboards.RequiredMessageException" %>
<%@ page import="com.liferay.portlet.messageboards.model.MBThreadConstants" %>
<%@ page import="com.liferay.portlet.messageboards.service.MBMessageServiceUtil" %> 
<%@ page import="com.liferay.portlet.messageboards.service.MBThreadLocalServiceUtil" %>
<%@ page import="com.liferay.portlet.messageboards.service.MBThreadServiceUtil" %>
<%@ page import="com.liferay.portlet.messageboards.service.MBMessageLocalServiceUtil" %>
<%@ page import="com.liferay.portlet.messageboards.service.MBCategoryLocalServiceUtil" %>

<%@ page import="com.liferay.portlet.messageboards.service.MBCategoryServiceUtil" %>
<%@ page import="com.liferay.util.*" %>
<%@ page import="com.liferay.portlet.asset.service.AssetEntryServiceUtil" %>
<%@ page import="com.liferay.portal.util.*" %>
<%@ page import="com.liferay.portlet.trash.util.TrashUtil" %>
<%@page import="com.liferay.portlet.asset.service.persistence.AssetEntryQuery" %>
<%@page import="javax.portlet.PortletURL" %>
<%@page import="com.liferay.portal.kernel.upload.*"%>
<%@ page import="com.liferay.portlet.documentlibrary.util.DLUtil" %>
<%@ page import="com.liferay.support.tomcat.loader.PortalClassLoaderFactory" %>



<%@ page import="com.rivetlogic.quickquestions.action.util.MBUtil" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.Format" %>
<%@ page import="java.text.SimpleDateFormat" %>


<%@ page import="com.liferay.portlet.asset.service.AssetEntryLocalServiceUtil" %>
<%@ page import="com.liferay.portlet.asset.service.AssetTagLocalServiceUtil" %>

<%@ page import="com.liferay.portlet.asset.model.AssetEntry" %>
<%@ page import="com.liferay.portlet.asset.model.AssetTag" %>

<%@ page import="com.liferay.portal.kernel.util.ListUtil" %>


<%@ page import="com.liferay.portal.kernel.dao.search.SearchEntry" %>
<%@ page import="com.liferay.portal.kernel.dao.search.ResultRow" %>
<%@ page import="com.liferay.portal.security.permission.ActionKeys" %>

<%@page import="com.liferay.portal.kernel.dao.orm.DynamicQueryFactoryUtil"%>
<%@page import="com.liferay.portal.kernel.dao.orm.DynamicQuery"%>
<%@page import="com.liferay.portal.kernel.dao.orm.RestrictionsFactoryUtil"%>
<%@page import="com.liferay.portal.kernel.dao.orm.ProjectionFactoryUtil"%>
<%@page import="com.liferay.portal.portletfilerepository.PortletFileRepositoryUtil"%>


<%@page import="com.rivetlogic.quickquestions.model.permissions.*"%>



<portlet:defineObjects />
<theme:defineObjects/>

<%

String recentPostsDateOffset = portletPreferences.getValue("recentPostsDateOffset", "7");
Format dateFormatDate = FastDateFormatFactoryUtil.getDate(locale, timeZone);
Format dateFormatDateTime = FastDateFormatFactoryUtil.getDateTime(locale, timeZone);

Set<Long> categorySubscriptionClassPKs = null;
Set<Long> threadSubscriptionClassPKs = null;

if (themeDisplay.isSignedIn()) {
	categorySubscriptionClassPKs = MBUtil.getCategorySubscriptionClassPKs(user.getUserId());
	threadSubscriptionClassPKs = MBUtil.getThreadSubscriptionClassPKs(user.getUserId());
}

SimpleDateFormat dateFormat =new SimpleDateFormat ("MMM dd yyyy"); 
%>