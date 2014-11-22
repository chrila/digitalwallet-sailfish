/******************************************************************************
 *                                                                            *
 * WalletItemDelegate.qml                                                     *
 *                                                                            *
 * This delegate is used for displaying wallets.                              *
 *                                                                            *
 * (c) 2012-2013 by Christian Lampl                                           *
 *                                                                            *
 ******************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {

    property alias text: label.text
    property alias subtext: sublabel.text
    property int contentHeight: label.height + sublabel.height
    property bool activeWallet: false

    width: parent.width

    Rectangle {
        id: highlightRect

        color: Theme.primaryColor
        anchors.fill: parent

        opacity: activeWallet ? 0.2 : 0.0
    }

    Label {
        id: label
        text: "text"
        font.pixelSize: Theme.fontSizeMedium
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
    }

    Label {
        id: sublabel
        text: "subtext"
        anchors.top: label.bottom
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.highlightColor
    }

    Label {
        id: activeLabel
        text: isActiveWallet ? "(" + qsTr("active") + ")" : ""
        font.pixelSize:  Theme.fontSizeMedium
        color: Theme.highlightColor
        horizontalAlignment: Text.AlignRight

        anchors.left: label.right
        anchors.right: parent.right
    }
}
