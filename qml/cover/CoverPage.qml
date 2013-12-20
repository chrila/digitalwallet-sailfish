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

    property alias text: lbValue.text
    property alias textColor: lbValue.color

    property bool walletActive: false
    property string walletName: ""

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
        spacing: Theme.paddingMedium

        Label {
            id: lbTitle

            width: parent.width
            font.family: Theme.fontFamilyHeading
            fontSizeMode: Text.HorizontalFit
            minimumPixelSize: 20
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.primaryColor

            text: walletActive ? walletName : "";

            visible: walletActive
        }

        Label {
            id: lbValue

            width: parent.width
            font.family: Theme.fontFamilyHeading
            fontSizeMode: Text.VerticalFit
            minimumPixelSize: 20
            font.pixelSize: 100
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


