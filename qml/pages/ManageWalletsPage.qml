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
                text: qsTr("Create new wallet")
                onClicked: {
                    createWallet();
                }
            }
        }

        delegate: WalletItemDelegate {
            id: myListItem

            property bool menuOpen: walletView.contextMenu != null && walletView.contextMenu.parent === myListItem
            property int walletId: model.id

            height: menuOpen ? walletView.contextMenu.height + contentHeight : contentHeight * 1.1

            text: model.name
            subtext: model.currency + " " + model.budget + " " + qsTr("per") + " " + Util.budgetTypeNoun(model.budget_type)
            activeWallet: model.id == mainPage.activeWalletId

            onClicked: {
                if (!walletView.contextMenu) {
                    walletView.contextMenu = contextMenuComponent.createObject(walletView)
                }
                selectedItem = myListItem
                walletView.contextMenu.show(myListItem)
            }
        }

        ViewPlaceholder {
            enabled: walletView.count == 0
            text: qsTr("Welcome! Use the pulldown menu to create your first wallet")
        }
    }

    Component {
        id: contextMenuComponent
        ContextMenu {
            MenuItem {
                text: qsTr("Set as active wallet")
                onClicked: mainPage.setActiveWallet(selectedItem.walletId);
                visible: !selectedItem.activeWallet
            }

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

        if (walletId == mainPage.activeWalletId) {
            mainPage.setActiveWallet(-1);
        }

        updateUi();
    }
}
