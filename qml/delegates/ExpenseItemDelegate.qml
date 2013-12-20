/******************************************************************************
 *                                                                            *
 * ExpenseItemDelegate.qml                                                    *
 *                                                                            *
 * This delegate is used for displaying expenses.                             *
 *                                                                            *
 * (c) 2012-2013 by Christian Lampl                                           *
 *                                                                            *
 ******************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {

    property alias text: label.text
    property alias subtext: sublabel.text
    property alias dateText: dateLabel.text
    property alias categoryText: categoryLabel.text
    property int contentHeight: label.height + sublabel.height

    width: parent.width

    Label {
        id: label
        text: "text"
        font.pixelSize: Theme.fontSizeMedium
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
    }

    Label {
        id: categoryLabel
        text: "category"
        font.pixelSize:  Theme.fontSizeMedium
        color: Theme.secondaryHighlightColor
        horizontalAlignment: Text.AlignRight

        anchors.left: label.right
        anchors.right: parent.right
    }

    Label {
        id: sublabel
        text: "subtext"
        anchors.top: label.bottom
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.highlightColor
    }

    Label {
        id: dateLabel
        text: "date"
        anchors.top: label.bottom
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.secondaryHighlightColor
        horizontalAlignment: Text.AlignRight

        anchors.left: sublabel.right
        anchors.right: parent.right
    }
}
