/******************************************************************************
 *                                                                            *
 * CoverPage.qml                                                              *
 *                                                                            *
 * This is the cover that is displayed in the multi-tasking view.             *
 *                                                                            *
 * (c) 2012-2013 by Christian Lampl                                           *
 *                                                                            *
 ******************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    property alias text: label.text
    property alias textColor: label.color
    //property alias coverActionsEnabled: coverActionList.enabled

    property bool walletActive: false

    anchors.fill: parent

    CoverPlaceholder {
        anchors.fill: parent
        icon.source: Qt.resolvedUrl("../images/background.png")
        icon.verticalAlignment: Image.AlignVCenter
        opacity: 0.15
    }

    Column {
        id: column

        width: parent.width
        spacing: Theme.paddingLarge

        Label {
            id: title

            width: parent.width
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.primaryColor

            text: qsTr("Wallet")
        }

        Label {
            id: label

            width: parent.width
            font.family: Theme.fontFamilyHeading
            font.pixelSize: 80
            lineHeightMode: Text.ProportionalHeight
            lineHeight: 0.6
            wrapMode: walletActive ? Text.WrapAnywhere : Text.WordWrap

            text: qsTr("No active wallet")
            color: Theme.secondaryHighlightColor
        }
    }

    CoverActionList {
        id: coverActionList
        enabled: walletActive

        CoverAction {
            iconSource: "image://theme/icon-cover-new"

            onTriggered: {
                if (!app.applicationActive) {
                    manageExpensesPage.createExpense();
                    app.activate();
                }
            }
        }
    }
}


