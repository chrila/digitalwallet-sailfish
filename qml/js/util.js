/******************************************************************************
 *                                                                            *
 * util.js                                                                    *
 *                                                                            *
 * Contains static routines which are needed by the app.                      *
 *                                                                            *
 * (c) 2012-2013 by Christian Lampl                                           *
 *                                                                            *
 ******************************************************************************/

.pragma library

var BUDGET_TYPE_DAILY = 0;
var BUDGET_TYPE_WEEKLY = 1;
var BUDGET_TYPE_MONTHLY = 2;
var BUDGET_TYPE_YEARLY = 3;

var BUDGET_TYPESTRING = [ "daily", "weekly", "monthly", "yearly" ];

/* currTimeInteger
 *
 * Returns the current date as an integer number of the format YYYYMMDDHHmm
 *
 */
function currTimeInteger() {
    return dateToInteger(new Date());
}

/* dateToInteger
 *
 * Converts a date object to an integer number of the format YYYYMMDDHHmm
 *
 */
function dateToInteger(date) {
    return date.getFullYear() * 100000000 + (date.getMonth() + 1) * 1000000 + date.getDate() * 10000 + date.getHours() * 100 + date.getMinutes();
}

/* year, month, day, hours, minutes
 *
 * Functions that extract the year/month/day/hours/minutes out of an
 * integer created by currTimeInteger
 */
function year(d) {
    return Math.floor(d/100000000);
}

function month(d) {
    return Math.floor((d%100000000)/1000000);
}

function day(d) {
    return Math.floor((d%1000000)/10000);
}

function hours(d) {
    return Math.floor((d%10000)/100);
}

function minutes(d) {
    return d%100;
}

function format(n) {
    return n < 10 ? "0" + n.toString() : n.toString();
}

/* toTimeString
 *
 * converts a time-integer to a readable string
 *
 */
function toTimeString(d) {
    return formatDate(year(d), month(d), day(d), "-") + " " + formatTime(hours(d), minutes(d));
}

/* currTimeString
 *
 * Returns the current date/time as readable string
 *
 */
function currTimeString() {
    return toTimeString(currTimeInteger());
}

/* currDateString
 *
 * Returns the current date as readable string
 *
 */
function currDateString() {
    var d = currTimeInteger();
    return formatDate(year(d), month(d), day(d), "/");
}

/* budgetTypeToString
 *
 * Returns a string representation of the given budget type
 *
 */
function budgetTypeToString(type) {
    var str;

    switch (type) {
    case BUDGET_TYPE_DAILY:
        str = "daily";
        break;
    case BUDGET_TYPE_WEEKLY:
        str = "weekly";
        break;
    case BUDGET_TYPE_MONTHLY:
        str = "monthly";
        break;
    case BUDGET_TYPE_YEARLY:
        str = "yearly";
        break;
    default:
        str = "unknown";
        break;
    }

    return str;
}

/* budgetTypeNoun
 *
 * Returns the correct noun for the given budget type.
 *
 */
function budgetTypeNoun(type) {
    var str;

    switch (type) {
    case BUDGET_TYPE_DAILY:
        str = "day";
        break;
    case BUDGET_TYPE_WEEKLY:
        str = "week";
        break;
    case BUDGET_TYPE_MONTHLY:
        str = "month";
        break;
    case BUDGET_TYPE_YEARLY:
        str = "year";
        break;
    default:
        str = "unknown";
        break;
    }

    return str;
}

/* budgetTypeValue
 *
 * Returns the correct value for the given budget type string.
 *
 */
function budgetTypeValue(type) {
    var retval;

    switch(type) {
    case "daily":
        retval = BUDGET_TYPE_DAILY;
        break;
    case "weekly":
        retval = BUDGET_TYPE_WEEKLY;
        break;
    case "monthly":
        retval = BUDGET_TYPE_MONTHLY;
        break;
    case "yearly":
        retval = BUDGET_TYPE_YEARLY;
        break;
    default:
        retval = BUDGET_TYPE_DAILY;
        break;
    }

    return retval;
}

/* formatDate
 *
 * Returns a formatted date string: YYYY-MM-dd, where "-" is replaced by separator.
 *
 */
function formatDate(year, month, day, separator) {
    return year + separator + format(month) + separator + format(day);
}

/* formatDateInt
 *
 * Returns a formatted date string: YYYY-MM-dd, where "-" is replaced by separator.
 *
 */
function formatDateInt(date, separator) {
    return formatDate(year(date), month(date), day(date), separator);
}

/* formatTime
 *
 * Returns a formatted time string: hh:mm
 *
 */
function formatTime(hour, minute) {
    return format(hour) + ":" + format(minute);
}
