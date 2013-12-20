/******************************************************************************
 *                                                                            *
 * harbour-digitalwallet.qml                                                  *
 *                                                                            *
 * Contains the ApplicationWindow element.                                    *
 *                                                                            *
 * (c) 2012-2013 by Christian Lampl                                           *
 *                                                                            *
 ******************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "cover"
import "js/util.js" as Util
import "js/db.js" as DB

ApplicationWindow
{
    id: app

    initialPage: MainPage {
        id: mainPage
    }

    cover: CoverPage {
        id: coverpage
    }

    ManageExpensesPage {
        id: manageExpensesPage
    }

    ManageWalletsPage {
        id: manageWalletsPage
    }

    EditWalletPage {
        id: editWalletPage
    }

    EditExpensePage {
        id: editExpensePage
    }

    EditCategoryPage {
        id: editCategoryPage
    }

    ToolsPage {
        id: toolsPage
    }
}
