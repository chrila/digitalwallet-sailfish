/******************************************************************************
 *                                                                            *
 * CategoryItemDelegate.qml                                                   *
 *                                                                            *
 * This delegate is used for displaying categories.                           *
 *                                                                            *
 * (c) 2012-2013 by Christian Lampl                                           *
 *                                                                            *
 ******************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {

    property alias text: label.text
    property int contentHeight: label.height

    width: parent.width

    Label {
        id: label
        text: "text"
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: Theme.fontSizeMedium
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
        //height: font.pixelSize * 1.5
    }
}
