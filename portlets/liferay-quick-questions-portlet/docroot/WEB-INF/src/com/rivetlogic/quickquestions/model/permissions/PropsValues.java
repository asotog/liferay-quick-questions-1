package com.rivetlogic.quickquestions.model.permissions;

import com.liferay.portal.kernel.util.GetterUtil;
import com.liferay.portal.kernel.util.PropsKeys;
import com.liferay.portal.kernel.util.PropsUtil;

public class PropsValues {
	public static boolean PERMISSIONS_VIEW_DYNAMIC_INHERITANCE = GetterUtil
			.getBoolean(PropsUtil
					.get(PropsKeys.PERMISSIONS_VIEW_DYNAMIC_INHERITANCE));

	public static final boolean DISCUSSION_COMMENTS_ALWAYS_EDITABLE_BY_OWNER = GetterUtil
			.getBoolean(PropsUtil
					.get(PropsKeys.DISCUSSION_COMMENTS_ALWAYS_EDITABLE_BY_OWNER));
	public static final boolean MESSAGE_BOARDS_ANONYMOUS_POSTING_ENABLED = GetterUtil
			.getBoolean(PropsUtil
					.get(PropsKeys.MESSAGE_BOARDS_ANONYMOUS_POSTING_ENABLED));
	public static final String POP_SERVER_SUBDOMAIN = PropsUtil
			.get(PropsKeys.POP_SERVER_SUBDOMAIN);
	public static final String MESSAGE_BOARDS_EMAIL_FROM_ADDRESS = PropsUtil
			.get(PropsKeys.MESSAGE_BOARDS_EMAIL_FROM_ADDRESS);
	public static final String MESSAGE_BOARDS_EMAIL_FROM_NAME = PropsUtil
			.get(PropsKeys.MESSAGE_BOARDS_EMAIL_FROM_NAME);
	public static final boolean MESSAGE_BOARDS_EMAIL_HTML_FORMAT = GetterUtil
			.getBoolean(PropsUtil
					.get(PropsKeys.MESSAGE_BOARDS_EMAIL_HTML_FORMAT));

	public static final String MESSAGE_BOARDS_EMAIL_MESSAGE_ADDED_BODY = PropsUtil
			.get(PropsKeys.MESSAGE_BOARDS_EMAIL_MESSAGE_ADDED_BODY);

	public static final boolean MESSAGE_BOARDS_EMAIL_MESSAGE_ADDED_ENABLED = GetterUtil
			.getBoolean(PropsUtil
					.get(PropsKeys.MESSAGE_BOARDS_EMAIL_MESSAGE_ADDED_ENABLED));

	public static final String MESSAGE_BOARDS_EMAIL_MESSAGE_ADDED_SIGNATURE = PropsUtil
			.get(PropsKeys.MESSAGE_BOARDS_EMAIL_MESSAGE_ADDED_SIGNATURE);

	public static final String MESSAGE_BOARDS_EMAIL_MESSAGE_ADDED_SUBJECT = PropsUtil
			.get(PropsKeys.MESSAGE_BOARDS_EMAIL_MESSAGE_ADDED_SUBJECT);

	public static final String MESSAGE_BOARDS_EMAIL_MESSAGE_UPDATED_BODY = PropsUtil
			.get(PropsKeys.MESSAGE_BOARDS_EMAIL_MESSAGE_UPDATED_BODY);

	public static final boolean MESSAGE_BOARDS_EMAIL_MESSAGE_UPDATED_ENABLED = GetterUtil
			.getBoolean(PropsUtil
					.get(PropsKeys.MESSAGE_BOARDS_EMAIL_MESSAGE_UPDATED_ENABLED));

	public static final String MESSAGE_BOARDS_EMAIL_MESSAGE_UPDATED_SIGNATURE = PropsUtil
			.get(PropsKeys.MESSAGE_BOARDS_EMAIL_MESSAGE_UPDATED_SIGNATURE);

	public static final String MESSAGE_BOARDS_EMAIL_MESSAGE_UPDATED_SUBJECT = PropsUtil
			.get(PropsKeys.MESSAGE_BOARDS_EMAIL_MESSAGE_UPDATED_SUBJECT);

}
