/******************************************************************************
 *                                                                            *
 * ToolsPage.qml                                                              *
 *                                                                            *
 * Page with testing tools e.g. to reset the database or to create dummy      *
 * datasets.                                                                  *
 *                                                                            *
 * (c) 2012-2013 by Christian Lampl                                           *
 *                                                                            *
 ******************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/db.js" as DB
import "../js/util.js" as Util

Dialog {
    id: root

    property string title: qsTr("Tools")

    Column {
        id: column

        width: root.width
        spacing: Theme.paddingLarge

        DialogHeader {
            id: header
            title: root.title
        }

        Button {
            id: btCreateDummyDatasets
            text: qsTr("Create dummy datasets")

            onClicked: {
                console.debug(qsTr("Creating dummy datasets ..."));
                createDummyDatasets();
            }
        }

        Button {
            id: btResetDatabase
            text: qsTr("Reset database")

            onClicked: {
                console.debug(qsTr("Resetting database..."));
                DB.dropTables();
                DB.createTables();
            }
        }
    }

    function createDummyDatasets() {
        // create categories
        for (var i = 0; i < 5; i++) {
            var cat = {
                name: "Category " + (i+1),
                icon: "none"
            }
            DB.insertCategory(cat);
        }
        // create wallet
        var wallet = {
            name: "Default wallet",
            owner: "Me",
            currency: "EUR",
            budget: 100,
            budget_type: 1
        }
        DB.insertWallet(wallet);

        // create expenses
        for (var i = 0; i < 5; i++) {
            var exp = {
                date: Util.currTimeInteger(),
                value: Math.random()*100,
                comment: "Test expense",
                id_category: 1,
                id_wallet: 1
            }
            DB.insertExpense(exp);
        }
    }
}
