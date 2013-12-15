/******************************************************************************
 *                                                                            *
 * EditWalletPage.qml                                                         *
 *                                                                            *
 * This page is used to create a new or edit an existing wallet.              *
 *                                                                            *
 * (c) 2012-2013 by Christian Lampl                                           *
 *                                                                            *
 ******************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/db.js" as DB
import "../js/util.js" as Util
import "../delegates"
import "../dialogs"

Dialog {

    id: root

    property int walletId
    property alias walletName: txtName.text
    property alias walletOwner: txtOwner.text
    property int walletBudgetType
    property alias walletBudgetTypeString: cmbBudgetType.value
    property alias walletBudget: txtBudget.text
    property alias walletCurrency: txtCurrency.text

    property string title: (walletId < 0) ? qsTr("Create new wallet") : qsTr("Edit wallet")

    property bool walletCreated: false

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        Column {
            id: column

            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                id: header

                title: root.title
                acceptText: "Ok"
            }

            TextField {
                id: txtName
                width: parent.width
                label: qsTr("Name of the wallet")
                placeholderText: label
                focus: true

                errorHighlight: text == ""

                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: txtOwner.focus = true
            }

            TextField {
                id: txtOwner
                width: parent.width
                label: qsTr("Owner")
                placeholderText: label

                errorHighlight: text == ""

                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: cmbBudgetType.focus = true
            }

            ComboBox {
                id: cmbBudgetType
                width: parent.width
                label: qsTr("Budget type:")

                menu: ContextMenu {
                    MenuItem { text: qsTr("daily") }
                    MenuItem { text: qsTr("monthly") }
                    MenuItem { text: qsTr("yearly") }
                }
            }

            TextField {
                id: txtBudget
                width: parent.width
                label: qsTr("Budget")
                placeholderText: label

                errorHighlight: text == ""

                inputMethodHints: Qt.ImhDigitsOnly
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: txtCurrency.focus = true
            }

            TextField {
                id: txtCurrency
                width: parent.width
                label: qsTr("Currency")
                placeholderText: label

                errorHighlight: text == ""

                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: accept()
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            updateUi();
        }
    }

    onAccepted: {
        // check if all necessary fields have been filled
        checkFields();

        if (canAccept) {
            // read values
            var wallet = {
                id: walletId,
                name: walletName,
                owner: walletOwner,
                budget_type: Util.budgetTypeValue(walletBudgetTypeString),
                budget: walletBudget,
                currency: walletCurrency
            }

            if (walletId < 0) {
                // creation mode
                DB.insertWallet(wallet);
            } else {
                // edit mode
                DB.updateWallet(wallet);
            }

            walletCreated= true;
        }
    }

    function checkFields() {
        if (txtOwner.text == "" ||
                txtName.text == "" ||
                cmbBudgetType.value == "" ||
                txtBudget.text == "" ||
                txtCurrency.text == "") {
            canAccept = false;
            console.debug("EditWalletPage::checkFields says something is wrong!");
        } else {
            canAccept = true;
        }
    }

    function updateUi() {
        if (walletId >= 0) {
            // read wallet to edit
            var wallet = DB.readWallet(walletId);
            txtName.text = wallet.name;
            txtOwner.text = wallet.owner;
            walletBudgetType = wallet.budget_type;
            txtBudget.text = wallet.budget;
            txtCurrency.text = wallet.currency;
        } else {
            clearFields();
        }
    }

    function clearFields() {
        txtName.text = "";
        txtOwner.text = "";
        txtBudget.text = "";
        txtCurrency.text = "";
    }
}
