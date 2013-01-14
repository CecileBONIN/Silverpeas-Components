package com.silverpeas.classifieds.servlets.handler;

import javax.servlet.http.HttpServletRequest;

import com.silverpeas.classifieds.control.ClassifiedsSessionController;
import com.silverpeas.classifieds.servlets.FunctionHandler;
import com.silverpeas.form.DataRecord;
import com.silverpeas.form.Form;
import com.silverpeas.form.RecordSet;
import com.silverpeas.publicationTemplate.PublicationTemplate;

/**
 * Use Case : for all users, show all adds of given category
 * @author Ludovic Bertin
 */
public class ClassifiedCreationFormHandler extends FunctionHandler {

  @Override
  public String getDestination(ClassifiedsSessionController classifiedsSC,
      HttpServletRequest request) throws Exception {

    // Retrieves parameters
    String fieldKey = request.getParameter("FieldKey");

    // Get form template and data
    Form formUpdate = null;
    DataRecord data = null;
    PublicationTemplate pubTemplate = getPublicationTemplate(classifiedsSC);
    if (pubTemplate != null) {
      formUpdate = pubTemplate.getUpdateForm();
      RecordSet recordSet = pubTemplate.getRecordSet();
      data = recordSet.getEmptyRecord();
    }

    // Stores objects in request
    request.setAttribute("ImagesDirectory", classifiedsSC.getSettings().getString("imagesSubDirectory"));
    request.setAttribute("Classified", null);
    request.setAttribute("UserName", classifiedsSC.getUserDetail().getDisplayedName());
    request.setAttribute("UserEmail", classifiedsSC.getUserDetail().geteMail());
    request.setAttribute("Form", formUpdate);
    request.setAttribute("Data", data);
    request.setAttribute("FieldKey", fieldKey);
    request.setAttribute("FieldName", classifiedsSC.getSearchFields1());

    // Returns jsp to redirect to
    return "classifiedManager.jsp";
   }

}
