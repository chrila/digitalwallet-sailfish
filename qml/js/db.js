/******************************************************************************
 *                                                                            *
 * db.js                                                                      *
 *                                                                            *
 * Contains routines to manage database access.                               *
 *                                                                            *
 * (c) 2012-2013 by Christian Lampl                                           *
 *                                                                            *
 ******************************************************************************/

.pragma library
.import QtQuick.LocalStorage 2.0 as Sql

var KEY_ACTIVEWALLETID = "activeWalletId";

var _db;

/* openDB
 *
 * Connects to the database.
 *
 */
function openDB() {
    _db = Sql.LocalStorage.openDatabaseSync("DigitalWalletDB", "1.0", "the database used by DigitalWallet", 1000000);
    createTables();

    initSettings();
}

/* createTables
 *
 * Creates the essential tables, if they don't exist.
 *
 */
function createTables() {
    _db.transaction(
                function(tx) {
                    // wallet
                    tx.executeSql("CREATE TABLE IF NOT EXISTS wallet (id            INTEGER PRIMARY KEY AUTOINCREMENT, \
                                                                      name          TEXT, \
                                                                      owner         TEXT, \
                                                                      currency      TEXT, \
                                                                      budget        REAL, \
                                                                      budget_type   INTEGER)");
                    // category
                    tx.executeSql("CREATE TABLE IF NOT EXISTS category (id          INTEGER PRIMARY KEY AUTOINCREMENT, \
                                                                        name        TEXT, \
                                                                        color       TEXT)");
                    // expense
                    tx.executeSql("CREATE TABLE IF NOT EXISTS expense (id           INTEGER PRIMARY KEY AUTOINCREMENT, \
                                                                       date         INTEGER, \
                                                                       value        REAL, \
                                                                       comment      TEXT, \
                                                                       id_category  INTEGER, \
                                                                       id_wallet    INTEGER)");

                    // setting
                    tx.executeSql("CREATE TABLE IF NOT EXISTS setting (key         TEXT, \
                                                                       value       TEXT, \
                                                                       description TEXT)");
                }
    )
}

/* dropTables
 *
 * Deletes the tables.
 *
 */
function dropTables() {
    _db.transaction(
                function(tx) {
                    // category
                    tx.executeSql("DROP TABLE IF EXISTS category");
                    // expense
                    tx.executeSql("DROP TABLE IF EXISTS expense");
                    // wallet
                    tx.executeSql("DROP TABLE IF EXISTS wallet");
                    // settings
                    tx.executeSql("DROP TABLE IF EXISTS setting");
                }
    )
}

/* initSettings
 *
 * Checks for vital setting values and initializes them if they don't exist.
 *
 */
function initSettings() {
    // ACTIVEWALLETID
    var walletId = getSetting(KEY_ACTIVEWALLETID);

    // if the setting is not present, insert it
    if (!walletId) {
        // create setting entry
        var setting = {
            key: "activeWalletId",
            value: "-1"
        };
        // insert it
        insertSetting(setting);

    } else if (walletId >= 0 && walletCount() <= 0) {
        // if we don't have any wallets but there is an id set, set it to invalid
        updateSetting(KEY_ACTIVEWALLETID, "-1");

    } else if (walletId < 0 && walletCount() > 0) {
        // if the id is invalid but we have wallets, take the highest id and set it to active
        var id;
        // get highest id
        _db.readTransaction(
                    function(tx) {
                        var rs = tx.executeSql("SELECT id FROM wallet ORDER BY id DESC");
                        id = rs.rows.item(0).id;
                    }
        )
        // use this id
        updateSetting(KEY_ACTIVEWALLETID, id);
    }
}

/* getSetting
 *
 * Reads a the setting value for the given key.
 *
 */
function getSetting(key) {
    var setting = {}
    _db.readTransaction(
                function(tx) {
                    var rs = tx.executeSql("SELECT * FROM setting WHERE key = ?", [key]);
                    if (rs.rows.length == 1) {
                        setting = rs.rows.item(0);
                    }
                }
    )
    console.debug("Read settings: { key:" + key + ", value:" + setting.value + " }");
    return setting.value;
}

/* insertSetting
 *
 * Inserts a setting into the database.
 *
 */
function insertSetting(setting) {
    _db.transaction(
                function(tx) {
                    tx.executeSql("INSERT INTO setting (key, value) VALUES(?, ?)", [setting.key, setting.value]);
                }
    )
    console.debug("Inserted setting: { key:" + setting.key + ", value:" + setting.value + " }");
}

/* updateSetting
 *
 * Updates a setting in the database.
 *
 */
function updateSetting(key, value) {
    _db.transaction(
                function(tx) {
                    tx.executeSql("UPDATE setting \
                                      SET value = ? \
                                    WHERE key = ?", [value, key]);
                }
    )
    console.debug("Updated setting: { key:" + key + ", value:" + value + " }");
}

/* readWallets
 *
 * Reads all wallets from the database.
 *
 */
function readWallets(model) {
    model.clear()
    _db.readTransaction(
                function(tx) {
                    var rs = tx.executeSql("SELECT * FROM wallet ORDER BY name ASC");
                    for (var i = 0; i < rs.rows.length; i++) {
                        model.append(rs.rows.item(i));
                    }
                }
    )
}

/* readWallet
 *
 * Reads data for one specific wallet.
 *
 */
function readWallet(id) {
    var data = {}
    _db.readTransaction(
                function(tx) {
                    var rs = tx.executeSql("SELECT * FROM wallet WHERE id = ? ORDER BY name ASC", [id]);
                    if (rs.rows.length == 1) {
                        data = rs.rows.item(0);
                    }
                }
    )
    console.debug("Read details for wallet: { id:" + data.id + ", name:" + data.name + ", owner:" + data.owner + ", currency:" + data.currency + ", budget:" + data.budget + ", budgetType:" + data.budget_type + " }");
    return data;
}

/* walletCount
 *
 * Returns the number of wallets in the database.
 *
 */
function walletCount() {
    var count = 0;
    _db.readTransaction(
                function(tx) {
                    var rs = tx.executeSql("SELECT COUNT(*) as cnt FROM wallet");
                    if (rs.rows.length == 1) {
                        count = rs.rows.item(0).cnt;
                    }
            }
    )
    console.debug("Wallet count=" + count);
    return count;
}

/* readCategories
 *
 * Reads all categories from the database.
 *
 */
function readCategories(model) {
    model.clear()
    _db.readTransaction(
                function(tx) {
                    var rs = tx.executeSql("SELECT * FROM category ORDER BY name ASC");
                    for (var i = 0; i < rs.rows.length; i++) {
                        model.append(rs.rows.item(i));
                    }
                }
    )
}

/* readExpenses
 *
 * Reads all expenses of a given wallet from the database.
 *
 */
function readExpenses(model, id_wallet) {
    model.clear()
    _db.readTransaction(
                function(tx) {
                    var rs = tx.executeSql("SELECT e.id, date, substr(date, 1, 8) as day, cast(value as integer) || '.' || substr(cast(value * 100 + 100 as integer ), -2, 2 ) as value, \
                                                   comment, c.name as category, c.color as color \
                                              FROM expense e JOIN category c ON e.id_category = c.id \
                                             WHERE id_wallet = ? \
                                             ORDER BY date DESC", id_wallet);

                    for (var i = 0; i < rs.rows.length; i++) {
                        model.append(rs.rows.item(i));
                    }
                }
    )
    console.debug("Found " + model.count + " expenses for wallet-id: " + id_wallet + ".");
}

/* readExpense
 *
 * Reads data for one specific expense.
 *
 */
function readExpense(expenseId) {
    var data = {}
    _db.readTransaction(
                function(tx) {
                    var rs = tx.executeSql("SELECT e.id, date, cast(value as integer) || '.' || substr(cast(value * 100 + 100 as integer ), -2, 2 ) as value, \
                                                   comment, c.name as category, c.color as color \
                                              FROM expense e JOIN category c ON e.id_category = c.id \
                                             WHERE e.id = ?", expenseId);
                    if (rs.rows.length == 1) {
                        data = rs.rows.item(0);
                    }
                }
    )
    console.debug("Read details for expense { id:" + data.id + ", date:" + data.date + ", value:" + data.value + ", category:" + data.category + ", comment: " + data.comment + " }");
    return data;
}

/* insertWallet
 *
 * Inserts a wallet into the database.
 *
 */
function insertWallet(wallet) {
    _db.transaction(
                function(tx) {
                    tx.executeSql("INSERT INTO wallet (name, owner, currency, budget, budget_type) \
                                   VALUES(?, ?, ?, ?, ?)", [wallet.name, wallet.owner, wallet.currency, wallet.budget, wallet.budget_type]);
                }
    )

    console.debug("Inserted wallet: { name:" + wallet.name + ", owner:" + wallet.owner + ", currency:" + wallet.currency + ", budget:" + wallet.budget + ", budgetType:" + wallet.budget_type + " }");
    initSettings();

    var id;
    // get highest id
    _db.readTransaction(
                function(tx) {
                    var rs = tx.executeSql("SELECT id FROM wallet ORDER BY ID DESC");
                    id = rs.rows.item(0).id;
                }
    )

    console.debug("ID of inserted wallet: id=" + id);
    return id;
}

/* insertCategory
 *
 * Inserts a category into the database.
 *
 */
function insertCategory(category) {
    _db.transaction(
                function(tx) {
                    tx.executeSql("INSERT INTO category (name, color) VALUES(?, ?)", [category.name, category.color]);
                }
    )
    console.debug("Inserted category: { name:" + category.name + ", color:" + category.color + " }");
}

/* insertExpense
 *
 * Inserts an expense into the database.
 *
 */
function insertExpense(expense) {
    _db.transaction(
                function(tx) {
                    tx.executeSql("INSERT INTO expense (date, value, comment, id_category, id_wallet) \
                                   VALUES(?, ?, ?, ?, ?)",
                                  [expense.date, expense.value, expense.comment, expense.id_category, expense.id_wallet]);
                }
    )
    console.debug("Inserted expense: { date:" + expense.date + ", value:" + expense.value + ", comment:" + expense.comment + ", id_category:" + expense.id_category + ", id_wallet:" + expense.id_wallet + " }");
}

/* updateWallet
 *
 * Updates a wallet in the database.
 *
 */
function updateWallet(wallet) {
    _db.transaction(
                function(tx) {
                    tx.executeSql("UPDATE wallet \
                                      SET name        = ?, \
                                          owner       = ?, \
                                          currency    = ?, \
                                          budget      = ?, \
                                          budget_type = ?  \
                                    WHERE id = ?", [wallet.name, wallet.owner, wallet.currency, wallet.budget, wallet.budget_type, wallet.id]);
                }
    )
    console.debug("Updated wallet: { id:" + wallet.id + ", name:" + wallet.name + ", owner:" + wallet.owner + ", currency:" + wallet.currency + ", budget:" + wallet.budget + ", budgetType:" + wallet.budget_type + " }");
}

/* updateCategory
 *
 * Updates a category in the database.
 *
 */
function updateCategory(category) {
    _db.transaction(
                function(tx) {
                    tx.executeSql("UPDATE category \
                                      SET name = ?, \
                                          color = ? \
                                    WHERE id = ?", [category.name, category.color, category.id]);
                }
    )
    console.debug("Updated category: { id:" + category.id + ", name:" + category.name + ", color:" + category.color + " }");
}

/* readCategory
 *
 * Reads data for one specific category.
 *
 */
function readCategory(id) {
    var data = {}
    _db.readTransaction(
                function(tx) {
                    var rs = tx.executeSql("SELECT * FROM category WHERE id = ? ORDER BY name ASC", [id]);
                    if (rs.rows.length == 1) {
                        data = rs.rows.item(0);
                    }
                }
    )
    console.debug("Read details for category: { id:" + data.id + ", name:" + data.name + ", color:" + data.color + " }");
    return data;
}

/* updateExpense
 *
 * Updates an expense in the database.
 *
 */
function updateExpense(expense) {
    _db.transaction(
                function(tx) {
                    tx.executeSql("UPDATE expense \
                                      SET date        = ?, \
                                          value       = ?, \
                                          comment     = ?, \
                                          id_category = ? \
                                    WHERE id = ?", [expense.date, expense.value, expense.comment, expense.id_category, expense.id]);
                }
    )
    console.debug("Updated expense: { date:" + expense.date + ", value:" + expense.value + ", comment:" + expense.comment + ", id_category:" + expense.id_category + ", id_wallet:" + expense.id_wallet + " }");
}

/* deleteWallet
 *
 * Deletes a wallet from the database.
 *
 */
function deleteWallet(id) {
    _db.transaction(
                function(tx) {
                    tx.executeSql("DELETE FROM wallet WHERE id = ?", id);
                }
    )

    initSettings();
}

/* deleteCategory
 *
 * Deletes a category from the database.
 *
 */
function deleteCategory(id) {
    _db.transaction(
                function(tx) {
                    tx.executeSql("DELETE FROM category WHERE id = ?", id);
                }
    )
}

/* deleteExpense
 *
 * Deletes an expense from the database.
 *
 */
function deleteExpense(id) {
    _db.transaction(
                function(tx) {
                    tx.executeSql("DELETE FROM expense WHERE id = ?", id);
                }
    )
}
