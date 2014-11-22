/******************************************************************************
 *                                                                            *
 * SettingsPage.qml                                                           *
 *                                                                            *
 * Page with which contains access to settings and also management of         *
 * wallets, categories, etc.                                                  *
 *                                                                            *
 * (c) 2014 by Christian Lampl                                                *
 *                                                                            *
 ******************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/db.js" as DB
import "../js/util.js" as Util

Page {

    id: root
    property string title: qsTr("Settings")

    ListModel {
        id: pagesModel

        ListElement {
            page: "ManageWalletsPage.qml"
            title: "Manage wallets"
            subtitle: "Create a new wallet or modify your existing ones"
            section: "Management"
        }
        ListElement {
            page: "ManageCategoriesPage.qml"
            title: "Categories"
            subtitle: "Manage the categories to organise your expenses"
            section: "Management"
        }
        ListElement {
            page: "ToolsPage.qml"
            title: "Tools"
            subtitle: "Misc. tools for testing the application"
            section: "Debug"
        }
    }

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: pagesModel
        header: PageHeader { title: root.title }
        section {
            property: 'section'
            delegate: SectionHeader {
                text: section
            }
        }

        delegate: BackgroundItem {
            width: listView.width
            Label {
                id: firstName
                text: model.title
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                anchors.verticalCenter: parent.verticalCenter
                x: Theme.paddingLarge
            }
            onClicked: pageStack.push(Qt.resolvedUrl(page))
        }

        VerticalScrollDecorator {}
    }
}
