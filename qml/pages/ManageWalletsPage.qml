/******************************************************************************
 *                                                                            *
 * ManageWalletsPage.qml                                                      *
 *                                                                            *
 * This page is used to display, add, edit and remove wallets.                *
 *                                                                            *
 * (c) 2012-2013 by Christian Lampl                                           *
 *                                                                            *
 ******************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/db.js" as DB
import "../js/util.js" as Util
import "../delegates"

Page {

    id: root

    property string title: qsTr("My wallets")
    property bool initial: false
    property WalletItemDelegate selectedItem

    ListModel {
        id: walletModel
    }

    SilicaListView {
        id: walletView
        model: walletModel
        anchors.fill: parent

        VerticalScrollDecorator {}

        property Item contextMenu

        header: PageHeader {
            title: root.title
        }

        PullDownMenu {
            id: pmWalletsMenu

            MenuItem {
                text: "Create new wallet"
                onClicked: {
                    createWallet();
                }
            }
        }

        delegate: WalletItemDelegate {
            id: myListItem
            property bool menuOpen: walletView.contextMenu != null && walletView.contextMenu.parent === myListItem
            property int walletId: model.id

            height: menuOpen ? walletView.contextMenu.height + contentHeight : contentHeight

            text: "#" + model.id + ": " + model.name
            subtext: model.currency + " " + model.budget + " " + qsTr("per") + " " + Util.budgetTypeNoun(model.budget_type)

            onClicked: {
                mainPage.setActiveWallet(model.id);
                pageStack.pop();
            }

            onPressAndHold: {
                if (!walletView.contextMenu) {
                    walletView.contextMenu = contextMenuComponent.createObject(walletView)
                }
                selectedItem = myListItem
                walletView.contextMenu.show(myListItem)
            }
        }
    }

    Label {
        text: walletView.model.count > 0 ? qsTr("Click a wallet to activate, long-press for context menu") : qsTr("Welcome! Use the pulldown menu to create your first wallet")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: Theme.fontFamilyHeading
        font.pixelSize: Theme.fontSizeLarge
        color: Theme.secondaryHighlightColor
        width: parent.width
        wrapMode: Text.WordWrap
        lineHeightMode: Text.ProportionalHeight
        lineHeight: 1.5

        anchors.bottom: walletView.bottom
        height: walletView.height - walletView.contentHeight

        visible: !pmWalletsMenu.active
    }

    Component {
        id: contextMenuComponent
        ContextMenu {
            MenuItem {
                text: qsTr("Edit")
                onClicked: editWallet(selectedItem.walletId)
            }
            MenuItem {
                text: qsTr("Delete")
                onClicked: {
                    remorseDelete.execute(selectedItem, qsTr("Deleting wallet"), function() {
                        deleteWallet(selectedItem.walletId);
                    })
                }
            }
        }
    }

    RemorseItem {
        id: remorseDelete
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            updateUi();
        }

        if (status == PageStatus.Active && initial && editWalletPage.walletCreated) {
            initial = false;
            pageStack.replace(mainPage, {}, PageStackAction.Immediate);
        }
    }

    function updateUi() {
        console.debug("ManageWalletsPage.qml::updateUi()");
        walletView.model = 0;
        DB.readWallets(walletModel);
        walletView.model = walletModel;
        mainPage.initCoverPage();
    }

    function createWallet() {
        console.debug("ManageWalletsPage.qml::createWallet()");
        pageStack.push(editWalletPage, { walletId: -1 });
    }

    function editWallet(walletId) {
        console.debug("ManageWalletsPage.qml::editWallet()");
        pageStack.push(editWalletPage, { walletId: walletId });
    }

    function deleteWallet(walletId) {
        console.debug("ManageWalletsPage.qml::deleteWallet()");
        DB.deleteWallet(walletId);

        updateUi();
    }
}
