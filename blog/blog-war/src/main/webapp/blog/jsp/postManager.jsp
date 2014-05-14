<%--

    Copyright (C) 2000 - 2013 Silverpeas

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    As a special exception to the terms and conditions of version 3.0 of
    the GPL, you may redistribute this Program in connection with Free/Libre
    Open Source Software ("FLOSS") applications as described in Silverpeas's
    FLOSS exception.  You should have recieved a copy of the text describing
    the FLOSS exception, and it is also available here:
    "http://www.silverpeas.org/docs/core/legal/floss_exception.html"

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
	isELIgnored="false"%>
<%@ include file="check.jsp" %>
<%@page import="com.stratelia.webactiv.beans.admin.UserDetail"%>

<%
	response.setHeader("Cache-Control", "no-store"); //HTTP 1.1
	response.setHeader("Pragma", "no-cache"); //HTTP 1.0
	response.setDateHeader("Expires", -1); //prevents caching at the proxy server
%>
<fmt:setLocale value="${requestScope.Language}"/>
<view:setBundle bundle="${requestScope.resources.multilangBundle}"/>

<% 
	PostDetail 	post			= (PostDetail) request.getAttribute("Post"); //never null
	Collection<NodeDetail> 	categories		= (Collection) request.getAttribute("AllCategories");
	UserDetail  updater			= (UserDetail) request.getAttribute("Updater");
	
	String 		         title			= "";
	String				 content		= "";
	String 		         postId			= "";
	String 		         categoryId		= "";
	String 		         creationDate	= resource.getOutputDate(new Date());
	String 		         creatorId		= "";
	Date		         dateEvent		= new Date();
	String 		         updateDate		= null;
	
	String 		action 			= "CreatePost";
	browseBar.setExtraInformation(resource.getString("blog.newPost"));
	
	title 			= post.getPublication().getName();
	content			= post.getContent();
	postId			= post.getPublication().getPK().getId();
	if (post.getCategory() != null) {
		categoryId	= post.getCategory().getNodePK().getId();
	}
	creationDate 	= resource.getOutputDate(post.getPublication().getCreationDate());
	updateDate		= resource.getOutputDate(post.getPublication().getUpdateDate());
	creatorId 		= post.getPublication().getCreatorId();
	dateEvent 		= post.getDateEvent();
	if(updater != null) {
	  	action 			= "UpdatePost";
		browseBar.setExtraInformation(resource.getString("blog.updatePost"));
	}
	
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title><fmt:message key="GML.popupTitle"/></title>
	<link type="text/css" href="<%=m_context%>/util/styleSheets/fieldset.css" rel="stylesheet" />
    <view:looknfeel/>
    <view:includePlugin name="datepicker"/>
    <view:includePlugin name="wysiwyg"/>
	<script type="text/javascript" src="<%=m_context%>/util/javaScript/animation.js"></script>
	<script type="text/javascript" src="<%=m_context%>/util/javaScript/checkForm.js"></script>
    <script type="text/javascript">
		function sendData() {
			if (isCorrectForm()) {
				<view:pdcPositions setIn="document.postForm.Positions.value"/>
				document.postForm.action = "UpdatePost";
				document.postForm.submit();
    		}
		}
		
		function isCorrectForm() {
	     	var errorMsg = "";
	     	var errorNb = 0;
	     	var title = stripInitialWhitespace(document.postForm.Title.value);

	     	if (title == "") { 
				errorMsg+="  - '<%=resource.getString("GML.title")%>'  <%=resource.getString("GML.MustBeFilled")%>\n";
	           	errorNb++;
	     	}
	     	
	     	<view:pdcValidateClassification errorCounter="errorNb" errorMessager="errorMsg"/>
	   				     			     				    
	     	switch(errorNb) {
	        	case 0 :
	            	result = true;
	            	break;
	        	case 1 :
	            	errorMsg = "<%=resource.getString("GML.ThisFormContains")%> 1 <%=resource.getString("GML.error")%> : \n" + errorMsg;
	            	window.alert(errorMsg);
	            	result = false;
	            	break;
	        	default :
	            	errorMsg = "<%=resource.getString("GML.ThisFormContains")%> " + errorNb + " <%=resource.getString("GML.errors")%> :\n" + errorMsg;
	            	window.alert(errorMsg);
	            	result = false;
	            	break;
	     	} 
	     	return result;
		}
		
		function sendDataAndDraftOut() {
			if (isCorrectForm()) {
				<view:pdcPositions setIn="document.postForm.Positions.value"/>
				document.postForm.action = "UpdatePostAndDraftOut";
				document.postForm.submit();
    		}
		}
		
		function deletePost()
		{
	    	document.postForm.action = "DeletePost";
	    	document.postForm.PostId.value = <%=postId%>;
			document.postForm.submit();
		}
		
		function cancel()
		{
	    	document.postForm.action = "ViewPost";
			document.postForm.submit();
		}
		
		$(document).ready(function() {
			<view:wysiwyg replace="Content" language="${language}" width="600" height="300" toolbar="Default"/>
		});
	</script>
</head>
<body id="blog">
<div id="<%=instanceId %>">
<view:browseBar componentId="${instanceId}" />
<view:window>
<view:frame>
<div id="header">
<form name="postForm" action="<%=action%>" method="post">
	<input type="hidden" name="PostId" value="<%=postId%>"/>
	<input type="hidden" name="Positions" value=""/>
	
<fieldset id="infoFieldset" class="skinFieldset">
  <legend><%=resource.getString("blog.header.fieldset.main") %></legend>
  <div class="fields">
    
    <div class="field" id="titleArea">
      <label class="txtlibform" for="titleName"><%=resource.getString("GML.title")%></label>
      <div class="champs">
        <input type="text" name="Title" size="60" maxlength="150" value="<%=title%>" />&nbsp;<img alt="mandatory" src="<%=resource.getIcon("blog.obligatoire")%>" width="5" height="5" border="0"/>
      </div>
    </div>
    
    <div class="field" id="contentArea">
		<label for="Content" class="txtlibform"><fmt:message key='blog.content'/></label>
		<div class="champs">
			<textarea rows="5" cols="10" name="Content" id="Content"><%=content %></textarea>
		</div>
	</div>
    
    <div class="field" id="dateArea">
      <label class="txtlibform" for="DateEvent"><%=resource.getString("blog.dateEvent")%></label>
      <div class="champs">
        <input type="text" class="dateToPick" id="eventDate" name="DateEvent" size="12" maxlength="10" value="<%=resource.getOutputDate(dateEvent)%>"/><span class="txtnote">(<%=resource.getString("GML.dateFormatExemple")%>)</span>
      </div>
    </div>
    
    <div class="field" id="categoryArea">
      <label class="txtlibform" for="CategoryId"><%=resource.getString("GML.category")%></label>
      <div class="champs">
        <select name="CategoryId">
			<option value="" selected="selected"><%=resource.getString("GML.category")%></option>
			<option value="">-------------------------------</option>
			<% if (categories != null) {
				String selected = "";
      			for (NodeDetail uneCategory : categories) {
      				if (categoryId.equals(uneCategory.getNodePK().getId()))
      					selected = "selected=\"selected\"";
      				%>
      				<option value="<%=uneCategory.getNodePK().getId()%>" <%=selected%>><%=uneCategory.getName()%></option>
      				<%
      				selected = "";
		  			}
      			}
			%>
		</select>
      </div>
    </div>
    
   	<div class="field" id="updateArea">
		<label class="txtlibform"><%=resource.getString("blog.header.contributors") %></label>
		<% if (StringUtil.isDefined(updateDate) && updater != null) {%>
		<div class="champs">
			<%=resource.getString("GML.updateDate")%> <br /><b><%=updateDate%></b> <%=resource.getString("GML.By")%> <view:username userId="<%=updater.getId()%>"/>
			<div class="profilPhoto"><img src="<%=m_context+updater.getAvatar() %>" alt="" class="defaultAvatar"/></div>
		</div>
		<% } %>
	</div>
	<div class="field" id="creationArea">
		<div class="champs">
			<%=resource.getString("GML.creationDate")%> <br /><b><%=creationDate%></b> <%=resource.getString("GML.By")%> <view:username userId="<%=post.getCreator().getId()%>"/>
			<div class="profilPhoto"><img src="<%=m_context+post.getCreator().getAvatar() %>" alt="" class="defaultAvatar"/></div>
		</div>
	</div>

  </div>
</fieldset>

<view:pdcClassification componentId="<%=instanceId%>" contentId="<%=post.getId() %>" editable="true" />

<div class="legend">
	<img alt="mandatory" border="0" src="<%=resource.getIcon("blog.obligatoire")%>" width="5" height="5"/> : <%=resource.getString("GML.requiredField")%>
</div>

</form>
</div>
	<br/>
	<center>
	<fmt:message key="GML.validate" var="validateLabel"/>
    <fmt:message key="GML.publish" var="publishLabel"/>
    <fmt:message key="blog.draftPost" var="draftLabel"/>
    <fmt:message key="GML.cancel" var="cancelLabel"/>
    <view:buttonPane>
    <% if("CreatePost".equals(action) || 
        ("UpdatePost".equals(action) && PublicationDetail.DRAFT.equals(post.getPublication().getStatus()))) { 
    %>
		<view:button action="javascript:onClick=sendDataAndDraftOut();" disabled="false"
                   label="${publishLabel}"/>
		<view:button action="javascript:onClick=sendData();" disabled="false"
                   label="${draftLabel}"/>    
    <%
    } else if ("UpdatePost".equals(action) && PublicationDetail.VALID.equals(post.getPublication().getStatus())) {
    %>
		<view:button action="javascript:onClick=sendData();" disabled="false"
                   label="${validateLabel}"/>
    <%
    }
    %>
	  
	<% if ("CreatePost".equals(action)) {
    %>               
		<view:button action="javascript:onClick=deletePost();" disabled="false" label="${cancelLabel}"/>
	<%
    } else {
    %>
		<view:button action="javascript:onClick=cancel();" disabled="false" label="${cancelLabel}"/>
	<%
	}
	%>
    </view:buttonPane>
    </center>
</view:frame>
</view:window>
</div>
</body>
</html>