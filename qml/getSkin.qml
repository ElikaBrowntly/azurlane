// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Fk
import Fk.Components.LunarLTK
import Fk.Pages.LunarLTK
import Fk.Components.Common

GraphicsBox {
  id: root
  property string general: ""
  property string deputy: ""
  width: 1
  height: 1
  visible: false

  function pathToSkinName(path) { // 解析路径，返回名称
    if (!path) return root.general;
    var normalizedPath = path.replace(/\\/g, "/");
    var pathParts = normalizedPath.split("/");
    var fileName = pathParts[pathParts.length - 1];

    var fileParts = fileName.split(".");
    return fileParts[0];
  }

  function loadData(data) {
    root.general = data[0];
    const enabledSkins = Config.enabledSkins ?? {}
    if (enabledSkins[general] !== undefined && enabledSkins[general] !== "") {
      root.general = enabledSkins[root.general]
    }
    var result = root.general;
    if (result && (result.indexOf("/") !== -1 || result.indexOf("\\") !== -1)) { // 不是路径不解析
      result = pathToSkinName(result);
    }
    if (data.length > 1) {
      root.deputy = data[1];
      if (enabledSkins[deputy] !== undefined && enabledSkins[deputy] !== "") {
        root.deputy = enabledSkins[root.deputy]
      }
      if (root.deputy.indexOf("/") !== -1 || root.deputy.indexOf("\\") !== -1) { // 不是路径不解析
        root.deputy = pathToSkinName(root.deputy);
      }
    }
    if (root.deputy == "") {
      ClientInstance.replyToServer("", result);
    } else {
      ClientInstance.replyToServer("", [result, root.deputy]);
    }

  }
}