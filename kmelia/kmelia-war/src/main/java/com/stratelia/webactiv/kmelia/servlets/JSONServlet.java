/**
 * Copyright (C) 2000 - 2013 Silverpeas
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * As a special exception to the terms and conditions of version 3.0 of
 * the GPL, you may redistribute this Program in connection with Free/Libre
 * Open Source Software ("FLOSS") applications as described in Silverpeas's
 * FLOSS exception.  You should have received a copy of the text describing
 * the FLOSS exception, and it is also available here:
 * "http://www.silverpeas.org/docs/core/legal/floss_exception.html"
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package com.stratelia.webactiv.kmelia.servlets;

import java.io.IOException;
import java.io.Writer;
import java.rmi.RemoteException;
import java.util.HashMap;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import com.stratelia.silverpeas.silvertrace.SilverTrace;
import com.stratelia.webactiv.SilverpeasRole;
import com.stratelia.webactiv.kmelia.control.KmeliaSessionController;
import com.stratelia.webactiv.kmelia.control.ejb.KmeliaHelper;
import com.stratelia.webactiv.util.node.model.NodeDetail;
import com.stratelia.webactiv.util.node.model.NodePK;

public class JSONServlet extends HttpServlet {

  private static final long serialVersionUID = 1L;

  @Override
  public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException,
          IOException {
    doPost(req, res);
  }

  @Override
  public void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException,
          IOException {
    SilverTrace.info("kmelia", "JSONServlet.doPost", "root.MSG_GEN_ENTER_METHOD");
    res.setContentType("application/json");

    String id = req.getParameter("Id");
    String componentId = req.getParameter("ComponentId");
    String action = req.getParameter("Action");

    KmeliaSessionController kmeliaSC = (KmeliaSessionController) req.getSession().getAttribute(
                "Silverpeas_kmelia_" + componentId);
    if(kmeliaSC == null) {
      return;
    }

    Writer writer = res.getWriter();
    if ("GetOperations".equals(action)) {
      JSONObject operations = getOperations(id, kmeliaSC);
      writer.write(operations.toString());
    }
  }

  private JSONObject getOperations(String id, KmeliaSessionController kmeliaSC) throws
          RemoteException {
    // getting profile
    String profile = kmeliaSC.getUserTopicProfile(id);

    // getting operations of topic according to profile and current
    HashMap<String, Boolean> operations = new HashMap<String, Boolean>(10);

    boolean isAdmin = SilverpeasRole.admin.isInRole(profile);
    boolean isPublisher = SilverpeasRole.publisher.isInRole(profile);
    boolean isWriter = SilverpeasRole.writer.isInRole(profile);
    boolean isRoot = NodePK.ROOT_NODE_ID.equals(id);
    boolean isBasket = NodePK.BIN_NODE_ID.equals(id);
    boolean statisticEnable = kmeliaSC.getSettings().getBoolean("kmelia.stats.enable", false);
    boolean canShowStats =
        isPublisher || SilverpeasRole.supervisor.isInRole(profile) || isAdmin &&
            !KmeliaHelper.isToolbox(kmeliaSC.getComponentId());

    if (isBasket) {
      boolean binOperationsAllowed = isAdmin || isPublisher || isWriter;
      operations.put("emptyTrash", binOperationsAllowed);
      operations.put("exportSelection", binOperationsAllowed);
      operations.put("copyPublications", binOperationsAllowed);
      operations.put("cutPublications", binOperationsAllowed);
      operations.put("deletePublications", binOperationsAllowed);
    } else {
      // general operations
      operations.put("admin", kmeliaSC.isComponentManageable());
      operations.put("pdc", isRoot && kmeliaSC.isPdcUsed() && isAdmin);
      operations.put("predefinedPdcPositions", kmeliaSC.isPdcUsed() && isAdmin);
      operations.put("templates", kmeliaSC.isContentEnabled() && isAdmin);
      operations.put("exporting", kmeliaSC.isExportComponentAllowed()
              && kmeliaSC.isExportZipAllowed() && (isAdmin || kmeliaSC.isExportAllowedToUsers()));
      operations.put("exportPDF", kmeliaSC.isExportComponentAllowed()
              && kmeliaSC.isExportPdfAllowed() && (isAdmin || isPublisher));

      // topic operations
      operations.put("addTopic", isAdmin);
      operations.put("updateTopic", !isRoot && isAdmin);
      operations.put("deleteTopic", !isRoot && isAdmin);
      operations.put("sortSubTopics", isAdmin);
      operations.put("copyTopic", !isRoot && isAdmin);
      operations.put("cutTopic", !isRoot && isAdmin);
      if (!isRoot && isAdmin && kmeliaSC.isOrientedWebContent()) {
        NodeDetail node = kmeliaSC.getNodeHeader(id);
        operations.put("showTopic", NodeDetail.STATUS_INVISIBLE.equalsIgnoreCase(node.getStatus()));
        operations.put("hideTopic", NodeDetail.STATUS_VISIBLE.equalsIgnoreCase(node.getStatus()));
      }
      operations.put("wysiwygTopic", isAdmin && (kmeliaSC.isOrientedWebContent() || kmeliaSC.
              isWysiwygOnTopicsEnabled()));
      operations.put("shareTopic", isAdmin && kmeliaSC.isFolderSharingEnabled());

      // publication operations
      boolean publicationsInTopic = !isRoot || (isRoot && (kmeliaSC.getNbPublicationsOnRoot() == 0
              || !kmeliaSC.isTreeStructure()));
      boolean addPublicationAllowed = !SilverpeasRole.user.isInRole(profile) && publicationsInTopic;
      boolean operationsOnSelectionAllowed = (isAdmin || isPublisher) && publicationsInTopic;

      operations.put("addPubli", addPublicationAllowed);
      operations.put("wizard", addPublicationAllowed && kmeliaSC.isWizardEnabled());
      operations.put("importFile", addPublicationAllowed && kmeliaSC.isImportFileAllowed());
      operations.put("importFiles", addPublicationAllowed && kmeliaSC.isImportFilesAllowed());
      operations.put("copyPublications", operationsOnSelectionAllowed);
      operations.put("cutPublications", operationsOnSelectionAllowed);
      operations.put("paste", addPublicationAllowed);

      operations.put("sortPublications", isAdmin && publicationsInTopic);
      operations.put("updateChain", isAdmin && publicationsInTopic && kmeliaSC.
              isTopicHaveUpdateChainDescriptor(id));

      operations.put("deletePublications", operationsOnSelectionAllowed);

      operations.put("exportSelection", !kmeliaSC.getUserDetail().isAnonymous());
      operations.put("manageSubscriptions", isAdmin);
      operations.put("subscriptions", !isBasket && !kmeliaSC.getUserDetail().isAnonymous());
      operations.put("favorites", !isBasket && !kmeliaSC.getUserDetail().isAnonymous());
      if (statisticEnable && isRoot && canShowStats) {
        operations.put("statistics", true);
      }
      operations.put("mylinks", !kmeliaSC.getUserDetail().isAnonymous());
      operations.put("responsibles", !kmeliaSC.getUserDetail().isAnonymous());
    }

    return new JSONObject(operations);
  }
}
