#include "expense.h"

Expense::Expense(const QDate &date, const float value, const QString &comment, const QString category)
    : date(date), value(value), comment(comment), category(category)
{
}

QDate Expense::getDate()
{
    return date;
}

float Expense::getValue()
{
    return value;
}

QString Expense::getComment()
{
    return comment;
}

QString Expense::getCategory()
{
    return category;
}
