/******************************************************************************
 *                                                                            *
 * EditCategoryDialog.qml                                                     *
 *                                                                            *
 * This dialog is used to edit or create a category.                          *
 *                                                                            *
 * (c) 2012-2013 by Christian Lampl                                           *
 *                                                                            *
 ******************************************************************************/


import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/db.js" as DB

Dialog {
    id: root

    property int categoryId: -1
    property alias name: txtName.text
    property string title: (categoryId < 0) ? qsTr("Create new category") : qsTr("Edit category")

    Column {
        id: column
        width: parent.width
        spacing: Theme.paddingLarge

        DialogHeader {
            title: root.title
            acceptText: qsTr("Ok")
        }

        TextField {
            id: txtName
            width: parent.width
            label: qsTr("Name")
            placeholderText: label
            focus: true

            errorHighlight: text == ""

            EnterKey.enabled: text || inputMethodComposing
            EnterKey.iconSource: "image://theme/icon-m-enter-next"
            EnterKey.onClicked: accept()
        }

        ValueButton {
            id: btColor
            label: qsTr("Color");
            value: colorPickerDialog.color == null ? qsTr("(none)") : colorPickerDialog.color.name

            onClicked: {
                colorPickerDialog.open();
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            updateUi();
        }
    }

    onDone: {
        // check if all necessary fields have been filled
        checkFields();

        if (canAccept) {
            var cat = {
                id: categoryId,
                name: txtName.text,
                icon: "none"
            }

            if (categoryId < 0) {
                // creation mode
                DB.insertCategory(cat);
            } else {
                // edit mode
                DB.updateCategory(cat);
            }
        }
    }

    ColorPickerDialog {
        id: colorPickerDialog
    }

    function checkFields() {
        if (txtName.errorHighlight) {
            canAccept = false;
            console.debug("EditCategoryPage::checkFields says something is wrong!");
        } else {
            canAccept = true;
        }
    }

    function updateUi() {
        if (categoryId >= 0) {
            // read existing category
            var cat = DB.readCategory(categoryId);
            txtName.text = cat.name;
        } else {
            clearFields();
        }
    }

    function clearFields() {
        txtName.text = "";
    }
}
