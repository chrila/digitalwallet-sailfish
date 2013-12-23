# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-digitalwallet

CONFIG += sailfishapp

SOURCES += \
    src/harbour-digitalwallet.cpp \
    src/expense.cpp \
    src/wallet.cpp

OTHER_FILES += \
    rpm/harbour-digitalwallet.spec \
    rpm/harbour-digitalwallet.yaml \
    harbour-digitalwallet.desktop \
    qml/harbour-digitalwallet.qml \
    qml/pages/ToolsPage.qml \
    qml/pages/ManageWalletsPage.qml \
    qml/pages/ManageExpensesPage.qml \
    qml/pages/ManageCategoriesPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/EditWalletPage.qml \
    qml/pages/EditExpensePage.qml \
    qml/pages/EditCategoryPage.qml \
    qml/js/util.js \
    qml/js/db.js \
    qml/delegates/WalletItemDelegate.qml \
    qml/delegates/ExpenseItemDelegate.qml \
    qml/delegates/CategoryItemDelegate.qml \
    qml/cover/CoverPage.qml \
    qml/images/background.png \
    qml/delegates/ExpenseSectionDelegate.qml

HEADERS += \
    src/expense.h \
    src/wallet.h

