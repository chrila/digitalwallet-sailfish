/******************************************************************************
 *                                                                            *
 * ExpenseSectionDelegate.qml                                                 *
 *                                                                            *
 * This delegate is used for displaying sections.                             *
 *                                                                            *
 * (c) 2012-2013 by Christian Lampl                                           *
 *                                                                            *
 ******************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {

    property alias text: label.text

    width: parent.width
    height: childrenRect.height
    color: "transparent"

    Label {
        id: label
        text: "text"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.secondaryHighlightColor
    }
}
