/******************************************************************************
 *                                                                            *
 * MainPage.qml                                                               *
 *                                                                            *
 * This is the initial page and shows an overview of the active wallet.       *
 * It also provides navigation to all other functions of the app.             *
 *                                                                            *
 * (c) 2012-2013 by Christian Lampl                                           *
 *                                                                            *
 ******************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/db.js" as DB
import "../js/util.js" as Util


Page {
    id: mainPage

    property string title: qsTr("My digital wallet")
    property int activeWalletId: 1
    property bool firststart: true
    property variant wallet

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Tools")
                onClicked: pageStack.push(toolsPage)
            }
            MenuItem {
                text: qsTr("Manage wallets")
                onClicked: pageStack.push(manageWalletsPage)
            }
            MenuItem {
                text: qsTr("Show expenses")
                onClicked: pageStack.push(manageExpensesPage, { walletId: activeWalletId, currency: wallet.currency })
            }
            MenuItem {
                text: qsTr("New expense")
                onClicked: manageExpensesPage.createExpense()
            }
        }

        contentHeight: column.height

        Column {
            id: column

            width: parent.width
            spacing: Theme.paddingLarge * 1.5

            PageHeader { title: mainPage.title }

            BackgroundItem {
                width: parent.width

                onClicked: pageStack.push(manageExpensesPage, { walletId: activeWalletId, currency: wallet.currency })

                Label {
                    id: lbWalletCaption
                    text: qsTr("currently active:") + "   "
                    font.family: Theme.fontFamilyHeading
                    font.pixelSize: Theme.fontSizeSmall
                    width: parent.width
                    horizontalAlignment: Text.AlignRight
                    color: Theme.secondaryHighlightColor
                }

                Label {
                    id: lbWalletName
                    text: "Wallet name"
                    font.family: Theme.fontFamilyHeading
                    font.pixelSize: Theme.fontSizeLarge
                    width: parent.width
                    horizontalAlignment: Text.AlignRight
                    anchors.top: lbWalletCaption.bottom
                }

                Label {
                    id: lbWalletDetails
                    text: qsTr("details about the wallet") + "   "
                    font.family: Theme.fontFamilyHeading
                    font.pixelSize: Theme.fontSizeSmall
                    textFormat: Text.RichText
                    width: parent.width
                    horizontalAlignment: Text.AlignRight
                    color: Theme.secondaryHighlightColor
                    anchors.top: lbWalletName.bottom
                }
            }

            Rectangle {
                width: parent.width
                height: 50
                color: "transparent"
            }

            Rectangle {
                width: parent.width
                height: 100
                color: "transparent"

                Label {
                    id: lbSpentCaption
                    text: qsTr("Spent:")
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeMedium
                    font.family: Theme.fontFamilyHeading
                }
                Label {
                    id: lbSpentValue
                    x: Theme.paddingLarge
                    text: qsTr("€ XX.XX")
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeExtraLarge * 1.5
                    font.family: Theme.fontFamilyHeading
                    anchors.top: lbSpentCaption.bottom
                }
            }

            Rectangle {
                width: parent.width
                height: 100
                color: "transparent"

                Label {
                    id: lbLeftCaption
                    text: qsTr("Left:")
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeMedium
                    font.family: Theme.fontFamilyHeading
                }
                Label {
                    id: lbLeftValue
                    text: qsTr("€ XX.XX")
                    x: Theme.paddingLarge
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeExtraLarge * 1.5
                    font.family: Theme.fontFamilyHeading
                    anchors.top: lbLeftCaption.bottom
                }
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            updateUi();
        }

        if (status == PageStatus.Active) {
            // if we have no valid active wallet, redirect to wallet managing page
            if (activeWalletId < 0) {
                pageStack.replace(manageWalletsPage, { initial: true }, PageStackAction.Immediate);
            }
        }
    }

    function initCoverPage() {
        if (activeWalletId < 0) {
            coverpage.walletActive = false;
            coverpage.text = qsTr("No active wallet");
            coverpage.textColor = Theme.secondaryHighlightColor
        } else {
            coverpage.walletActive = true;
        }
    }

    function updateUi() {
        // open DB upon initial startup
        if (firststart) {
            firststart = false;
            DB.openDB();
        }

        activeWalletId = DB.getSetting(DB.KEY_ACTIVEWALLETID);
        initCoverPage();

        if (activeWalletId >= 0) {
            setActiveWallet(activeWalletId);
        }
    }

    ListModel {
        id: listExpenses;
    }

    function setActiveWallet(walletId) {
        console.debug("MainPage.qml::setActiveWallet(); walletId=" + walletId);
        activeWalletId = walletId;

        // update setting in DB
        DB.updateSetting(DB.KEY_ACTIVEWALLETID, walletId);

        // read wallet
        wallet = DB.readWallet(activeWalletId);

        // recalculate values and display them
        var sum = getExpenseThisPeriod();
        var left = (wallet.budget - sum);

        lbWalletName.text = wallet.name + "   ";
        lbWalletDetails.text = qsTr("you have") + "<b> " + wallet.currency + " " + wallet.budget + "</b> " + qsTr("per") + " " + Util.budgetTypeNoun(wallet.budget_type) + "   ";
        lbSpentCaption.text = qsTr("Spent this") + " " + Util.budgetTypeNoun(wallet.budget_type);
        lbLeftCaption.text = qsTr("Left for this") + " " + Util.budgetTypeNoun(wallet.budget_type);
        lbSpentValue.text = wallet.currency + " " + sum.toFixed(2);
        lbLeftValue.text = wallet.currency + " " + (wallet.budget - sum).toFixed(2);

        // format the remaining value
        var percent = (left / sum) * 100;

        if (percent > 80) {
            lbLeftValue.color = "green";
            app.coverColor = "green";
        } else if (percent > 60) {
            lbLeftValue.color = "yellow";
            app.coverColor = "yellow";
        } else if (percent > 40) {
            lbLeftValue.color = "orange";
            app.coverColor = "orange";
        } else {
            lbLeftValue.color = "red";
            app.coverColor = "red";
        }

        // set cover text
        app.coverText = qsTr("Left:") + " " + wallet.currency + " " + left;
    }

    function getExpenseThisPeriod() {
        switch (wallet.budget_type) {
        case Util.BUDGET_TYPE_DAILY:
            return sumPeriodValues(0, 8);
        case Util.BUDGET_TYPE_MONTHLY:
            return sumPeriodValues(0, 6);
        case Util.BUDGET_TYPE_YEARLY:
            return sumPeriodValues(0, 4);
        default:
            return 0;
        }
    }

    function sumPeriodValues(startIndex, endIndex) {
        var sum = 0;
        var now = Util.currTimeInteger().toString();
        var expDate;
        DB.readExpenses(listExpenses, activeWalletId);

        console.debug("Current date: " + now);
        console.debug("Criterium: start=" + startIndex + "; end=" + endIndex);

        for (var i=0; i<listExpenses.count; i++) {
            expDate = listExpenses.get(i).date.toString();
            if (expDate.substring(startIndex, endIndex) == now.substring(startIndex, endIndex)) {
                sum += Math.round(listExpenses.get(i).value*100)/100;
            }
        }

        console.debug("Sum=" + sum);
        return sum;
    }
}


