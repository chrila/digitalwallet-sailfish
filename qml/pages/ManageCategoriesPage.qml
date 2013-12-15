/******************************************************************************
 *                                                                            *
 * ManageCategoriesPage.qml                                                   *
 *                                                                            *
 * This page is used to manage the categories.                                *
 *                                                                            *
 * (c) 2012-2013 by Christian Lampl                                           *
 *                                                                            *
 ******************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/db.js" as DB
import "../delegates"

Dialog {
    property string title: qsTr("Select category")
    property alias model: categoryView.model
    property int selectedCategoryId
    property CategoryItemDelegate selectedItem

    canAccept: false

    id: root

    ListModel {
        id: categoryModel
    }

    SilicaListView {
        id: categoryView
        model: categoryModel
        anchors.fill: parent

        property Item contextMenu

        VerticalScrollDecorator {}

        header: PageHeader {
            title: root.title
        }

        PullDownMenu {
            id: pmCategoriesMenu

            MenuItem {
                text: qsTr("Create new category")
                onClicked: {
                    createCategory();
                }
            }
        }

        delegate: CategoryItemDelegate {
            id: myListItem
            property bool menuOpen: categoryView.contextMenu != null && categoryView.contextMenu.parent === myListItem
            property int categoryId: model.id

            height: menuOpen ? categoryView.contextMenu.height + contentHeight : contentHeight

            text: model.name

            onClicked: {
                selectedCategoryId = model.id;
                canAccept = true;
                accept();
            }

            onPressAndHold: {
                if (!categoryView.contextMenu) {
                    categoryView.contextMenu = contextMenuComponent.createObject(categoryView)
                }
                selectedItem = myListItem
                categoryView.contextMenu.show(myListItem)
            }
        }
    }

    Label {
        text: qsTr("Use the pulldown menu to add categories")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: Theme.fontFamilyHeading
        font.pixelSize: Theme.fontSizeLarge
        color: Theme.secondaryHighlightColor
        width: parent.width
        wrapMode: Text.WordWrap
        lineHeightMode: Text.ProportionalHeight
        lineHeight: 1.5

        anchors.bottom: categoryView.bottom
        height: categoryView.height - categoryView.contentHeight

        visible: !pmCategoriesMenu.active && (categoryView.count == 0)
    }

    Component {
        id: contextMenuComponent
        ContextMenu {
            MenuItem {
                text: qsTr("Edit")
                onClicked: editCategory(selectedItem.categoryId)
            }
            MenuItem {
                text: qsTr("Delete")
                onClicked: {
                    remorseDelete.execute(selectedItem, qsTr("Deleting") + "'" + selectedItem.text + "'", function() {
                        deleteCategory(selectedItem.categoryId);
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
    }

    function updateUi() {
        categoryView.model = 0;
        DB.readCategories(categoryModel);
        categoryView.model = categoryModel;
    }

    function createCategory() {
        console.debug("ManageCategoriesPage.qml::createCategory()");
        pageStack.push(editCategoryPage, { categoryId: -1 });
    }

    function editCategory(categoryId) {
        console.debug("ManageCategoriesPage.qml::editCategory()");
        pageStack.push(editCategoryPage, { categoryId: categoryId });
    }

    function deleteCategory(categoryId) {
        console.debug("ManageCategoriesPage.qml::deleteCategory()");
        DB.deleteCategory(categoryId);

        updateUi();
    }
}
