/******************************************************************************
 *                                                                            *
 * ShowExpensePage.qml                                                        *
 *                                                                            *
 * This page is used to display the already taken expenses for the selected   *
 * wallet.                                                                    *
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

    property string title: qsTr("My expenses")
    property int walletId
    property string currency
    property int selectedIndex
    property ExpenseItemDelegate selectedItem

    ListModel {
        id: expenseModel
    }

    SilicaListView {
        id: expenseView
        model: expenseModel
        anchors.fill: parent

        property Item contextMenu

        VerticalScrollDecorator {}

        header:  PageHeader {
            title: root.title
        }

        PullDownMenu {
            id: pmExpenseMenuTop

            MenuItem {
                text: qsTr("New expense")
                onClicked: {
                    createExpense();
                }
            }
        }

        PushUpMenu {
            id: pmExpenseMenuBottom

            MenuItem {
                text: qsTr("Back to top")
                onClicked: {
                    expenseView.scrollToTop();
                }
            }
        }

        // sections
        section.property: "day"
        section.criteria: ViewSection.FullString
        section.delegate: ExpenseSectionDelegate {
            text: (new Date(Util.year(section*10000), Util.month(section*10000) - 1, Util.day(section*10000))).toLocaleDateString(Qt.locale(), Locale.ShortFormat)
            //text: section
        }

        delegate: ExpenseItemDelegate {
            id: myListItem
            property bool menuOpen: expenseView.contextMenu != null && expenseView.contextMenu.parent === myListItem
            property int expenseId: model.id

            height: menuOpen ? expenseView.contextMenu.height + contentHeight : contentHeight

            text: model.comment
            categoryText: model.category
            subtext: currency + " " + model.value;
            dateText: qsTr("on") + " " + Util.formatDateInt(model.date, "-");

            onClicked: viewExpense(model.id)

            onPressAndHold: {
                if (!expenseView.contextMenu) {
                    expenseView.contextMenu = contextMenuComponent.createObject(expenseView)
                }
                selectedItem = myListItem
                expenseView.contextMenu.show(myListItem)
            }
        }

        ViewPlaceholder {
            enabled: expenseView.count == 0
            text: qsTr("Use the pulldown menu to create a new expense");
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            updateUi();
        }
    }

    Component {
        id: contextMenuComponent
        ContextMenu {
            MenuItem {
                text: qsTr("Edit")
                onClicked: editExpense(selectedItem.expenseId)
            }
            MenuItem {
                text: qsTr("Delete")
                onClicked: {
                    remorseDelete.execute(selectedItem, qsTr("Deleting expense"), function() {
                        deleteExpense(selectedItem.expenseId);
                    })
                }
            }
        }
    }

    RemorseItem {
        id: remorseDelete
    }

    function updateUi() {
        console.debug("ShowExpensesPage.qml::updateUi()");
        expenseView.model = 0;
        DB.readExpenses(expenseModel, walletId);
        expenseView.model = expenseModel;
    }

    function createExpense() {
        console.debug("ShowExpensesPage.qml::createExpense()");
        pageStack.push(editExpensePage, { expenseId: -1, clear: true, editmode: true });
    }

    function deleteExpense(expenseId) {
        console.debug("ShowExpensesPage.qml::deleteExpense()");
        DB.deleteExpense(expenseId)
        updateUi();
    }

    function editExpense(expenseId) {
        console.debug("ShowExpensesPage.qml::editExpense()");
        pageStack.push(editExpensePage, { expenseId: expenseId, clear: false, editmode: true });
    }

    function viewExpense(expenseId) {
        console.debug("ShowExpensesPage.qml::viewExpense()");
        pageStack.push(editExpensePage, { expenseId: expenseId, clear: false, editMode: false });
    }
}
