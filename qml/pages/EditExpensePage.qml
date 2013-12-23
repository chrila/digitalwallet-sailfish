/******************************************************************************
 *                                                                            *
 * EditExpensePage.qml                                                        *
 *                                                                            *
 * This page is used to create a new or edit an existing expense.             *
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

    property int expenseId: -1
    property int categoryId: -1
    property alias categoryString: btCategory.value
    property alias year: dateDialog.year
    property alias month: dateDialog.month
    property alias day: dateDialog.day
    property alias hour: timeDialog.hour
    property alias minute: timeDialog.minute
    property alias value: txtValue.text
    property alias comment: txtComment.text

    property bool clear: false
    property string defaultCategoryString: qsTr("Select")
    property bool editmode: true

    property string title: {
        if (editmode) {
            if (expenseId < 0) {
                return qsTr("Create new expense")
            } else {
                return qsTr("Edit expense")
            }
        } else {
            return qsTr("Expense details");
        }
    }

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
                id: txtValue
                label: qsTr("Value")
                placeholderText: label
                width: parent.width
                readOnly: !editmode

                errorHighlight: text == ""

                inputMethodHints: Qt.ImhDigitsOnly
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: txtComment.focus = true
            }

            TextField {
                id: txtComment
                label: qsTr("Comment")
                placeholderText: label
                width: parent.width
                readOnly: !editmode

                errorHighlight: text == ""

                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: accept()
            }

            ValueButton {
                id: btCategory
                label: qsTr("Category:")
                value: defaultCategoryString
                enabled: editmode

                onClicked: {
                    pageStack.push(manageCategoriesPage, { canAccept: false });
                }
            }

            ValueButton {
                id: btDate
                label: qsTr("Date:")
                value: dateDialog.date.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
                enabled: editmode

                onClicked: {
                    dateDialog.open();
                }
            }

            ValueButton {
                id: btTime
                label: qsTr("Time:")
                value: timeDialog.time.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                enabled: editmode

                onClicked: {
                    timeDialog.open();
                }
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            updateUi();
        }
    }

    onDone: {
        // read entered values
        var d = new Date(year, month-1, day, hour, minute, 0, 0);
        var dint = Util.dateToInteger(d);
        console.debug("Util.dateToInteger() = " + dint);

        // check if all necessary fields have been filled
        checkFields();

        if (canAccept) {
            var exp = {
                id: expenseId,
                date: dint,
                value: value,
                comment: comment,
                id_category: categoryId,
                id_wallet: mainPage.activeWalletId
            }

            if (expenseId < 0) {
                // creation mode
                DB.insertExpense(exp);
            } else {
                // edit mode
                DB.updateExpense(exp);
            }
        } else {

        }
    }

    function checkFields() {
        if (txtValue.text == "" ||
                categoryId == -1 ||
                txtComment.text == "") {
            canAccept = false;
            console.debug("EditExpensePage::checkFields says something is wrong!");
        } else {
            canAccept = true;
        }
    }

    function updateUi() {
        // update categories
        updatemanageCategoriesPage();

        if (expenseId >= 0) {
            // read existing expense
            var exp = DB.readExpense(expenseId);
            dateDialog.date = new Date(Util.year(exp.date), Util.month(exp.date)-1, Util.day(exp.date));
            timeDialog.hour = Util.hours(exp.date);
            timeDialog.minute = Util.minutes(exp.date);
            txtValue.text = exp.value;
            btCategory.value = exp.category;
            txtComment.text = exp.comment;
        } else {
            clearFields();
        }
    }

    function clearFields() {
        if (clear) {
            txtValue.text = "";
            txtComment.text = "";
            // set current date and time
            dateDialog.date = new Date();
            timeDialog.hour = Util.hours(Util.currTimeInteger());
            timeDialog.minute = Util.minutes(Util.currTimeInteger());

            clear = false;
        }
    }

    function updatemanageCategoriesPage() {
        manageCategoriesPage.model = 0;
        DB.readCategories(categoryListModel);
        manageCategoriesPage.model = categoryListModel;
    }

    DatePickerDialog {
        id: dateDialog
    }

    TimePickerDialog {
        id: timeDialog
    }

    ListModel {
        id: categoryListModel
    }

    ManageCategoriesPage {
        id: manageCategoriesPage

        onAccepted: {
            var cat = DB.readCategory(selectedCategoryId);
            root.categoryId = selectedCategoryId;
            console.debug("categoryId=" + categoryId);
            console.debug("cat.name=" + cat.name);
            console.debug("cat.color=" + cat.color);
            btCategory.value = cat.name;
        }
    }
}
